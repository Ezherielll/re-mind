import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';

/// A loop row joined with its optional person — the shape the UI consumes.
class LoopWithPerson {
  final Commitment commitment;
  final Person? person;

  const LoopWithPerson(this.commitment, this.person);

  static LoopWithPerson fromRow(AppDatabase db, TypedResult row) =>
      LoopWithPerson(
        row.readTable(db.commitments),
        row.readTableOrNull(db.people),
      );
}

/// Persistence seam for open loops (ADR-0009). UI and controllers depend on
/// this interface only; tests run the Drift implementation over an in-memory
/// database.
abstract class LoopsRepository {
  /// Open, non-deleted loops. Ordering is refined by derived status in T05.
  Stream<List<LoopWithPerson>> watchOpenLoops();

  Stream<List<LoopWithPerson>> watchOpenLoopsByPerson(int personId);

  Future<Person> getPerson(int id);

  /// Lazily creates a person from free text, deduping on normalized name.
  Future<Person> findOrCreatePerson(String rawName);

  /// One-shot prefix search for autocomplete; soft-deleted people excluded.
  Future<List<Person>> searchPeople(String prefix, {int limit});

  Future<Commitment> createCommitment({
    required String title,
    required Direction direction,
    int? personId,
    DateTime? dueDate,
    DateTime? followUpAt,
  });

  /// Re-plans a loop's dates (T04); bumps `updatedAt`.
  Future<void> updateDates(int id, {DateTime? dueDate, DateTime? followUpAt});

  /// One-shot fetch of a loop with its person for the detail screen.
  ///
  /// Note: backed by the OPEN query — archived loops resolve to null until
  /// the detail screen gains an archive-aware fetch (T11).
  Future<LoopWithPerson?> getLoop(int id);

  /// Snooze-cycle action: logs `followedUp` and moves the nudge forward.
  Future<void> markFollowedUp(int id, {required DateTime nextNudgeAt});

  /// Pushes the next nudge without logging an event.
  Future<void> snoozeLoop(int id, {required DateTime until});

  /// Closes the loop (auto-archive) and logs `done`.
  Future<void> markDone(int id);

  /// Un-archives a loop back to open.
  Future<void> reopenLoop(int id);

  /// Done loops for one person (person view "closed" side).
  Stream<List<LoopWithPerson>> watchDoneLoopsByPerson(int personId);

  /// All archived (done) loops — history surface.
  Stream<List<LoopWithPerson>> watchArchivedLoops();

  /// Saves the detail-screen note (T10); bumps updatedAt.
  Future<void> updateNote(int id, String? note);

  /// Live search over commitment titles/notes and person names (T10);
  /// soft-deleted excluded.
  Future<List<LoopWithPerson>> searchLoops(String query, {int limit});

  /// Sample loops currently present (ids + titles) for the T09 banner.
  Future<List<Commitment>> sampleLoops();

  /// Soft-deletes every remaining sample loop (one-tap clear).
  Future<void> removeAllSamples();
}


class DriftLoopsRepository implements LoopsRepository {
  DriftLoopsRepository(this._db);

  final AppDatabase _db;

  static String _normalize(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  JoinedSelectStatement _openLoopsQuery({Expression<bool>? extraWhere}) {
    final query =
        _db.select(_db.commitments).join([
            leftOuterJoin(
              _db.people,
              _db.people.id.equalsExp(_db.commitments.personId),
            ),
          ])
          ..where(_db.commitments.status.equalsValue(CommitmentStatus.open))
          ..where(_db.commitments.deletedAt.isNull());
    if (extraWhere != null) {
      query.where(extraWhere);
    }
    query.orderBy([OrderingTerm.desc(_db.commitments.id)]);
    return query;
  }

  @override
  Stream<List<LoopWithPerson>> watchOpenLoops() {
    return _openLoopsQuery().watch().map(
      (rows) => rows.map((row) => LoopWithPerson.fromRow(_db, row)).toList(),
    );
  }

  @override
  Stream<List<LoopWithPerson>> watchOpenLoopsByPerson(int personId) {
    return _openLoopsQuery(
      extraWhere: _db.commitments.personId.equals(personId),
    ).watch().map(
      (rows) => rows.map((row) => LoopWithPerson.fromRow(_db, row)).toList(),
    );
  }

  @override
  Future<Person> getPerson(int id) {
    return (_db.select(_db.people)..where((p) => p.id.equals(id))).getSingle();
  }

  @override
  Future<Person> findOrCreatePerson(String rawName) {
    final normalized = _normalize(rawName);
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.people)
                ..where((p) => p.normalizedName.equals(normalized))
                ..where((p) => p.deletedAt.isNull()))
              .getSingleOrNull();
      if (existing != null) return existing;

      return _db
          .into(_db.people)
          .insertReturning(
            PeopleCompanion.insert(
              name: rawName.trim(),
              normalizedName: normalized,
            ),
          );
    });
  }

  @override
  Future<List<Person>> searchPeople(String prefix, {int limit = 5}) {
    final normalized = _normalize(prefix);
    return (_db.select(_db.people)
          ..where((p) => p.deletedAt.isNull())
          ..where((p) => p.normalizedName.like('$normalized%'))
          ..limit(limit))
        .get();
  }

  @override
  Future<Commitment> createCommitment({
    required String title,
    required Direction direction,
    int? personId,
    DateTime? dueDate,
    DateTime? followUpAt,
  }) {
    return _db.transaction(() async {
      final commitment = await _db
          .into(_db.commitments)
          .insertReturning(
            CommitmentsCompanion.insert(
              title: title,
              direction: direction,
              status: CommitmentStatus.open,
              personId: Value(personId),
              dueDate: Value(dueDate),
              followUpAt: Value(followUpAt),
            ),
          );
      await _db
          .into(_db.loopEvents)
          .insert(
            LoopEventsCompanion.insert(
              commitmentId: commitment.id,
              type: LoopEventType.created,
            ),
          );
      return commitment;
    });
  }

  @override
  Future<void> updateDates(
    int id, {
    DateTime? dueDate,
    DateTime? followUpAt,
  }) async {
    await (_db.update(_db.commitments)..where((c) => c.id.equals(id))).write(
      CommitmentsCompanion(
        dueDate: Value(dueDate),
        followUpAt: Value(followUpAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<LoopWithPerson?> getLoop(int id) async {
    final rows = await _openLoopsQuery(
      extraWhere: _db.commitments.id.equals(id),
    ).get();
    if (rows.isEmpty) return null;
    return LoopWithPerson.fromRow(_db, rows.first);
  }

  Future<void> _logEvent(int commitmentId, LoopEventType type) {
    return _db.into(_db.loopEvents).insert(
          LoopEventsCompanion.insert(commitmentId: commitmentId, type: type),
        );
  }

  @override
  Future<void> markFollowedUp(int id, {required DateTime nextNudgeAt}) async {
    await _db.transaction(() async {
      await (_db.update(_db.commitments)..where((c) => c.id.equals(id)))
          .write(CommitmentsCompanion(
        followUpAt: Value(nextNudgeAt),
        updatedAt: Value(DateTime.now()),
      ));
      await _logEvent(id, LoopEventType.followedUp);
    });
  }

  @override
  Future<void> snoozeLoop(int id, {required DateTime until}) {
    return (_db.update(_db.commitments)..where((c) => c.id.equals(id))).write(
      CommitmentsCompanion(
        followUpAt: Value(until),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> markDone(int id) async {
    await _db.transaction(() async {
      await (_db.update(_db.commitments)..where((c) => c.id.equals(id)))
          .write(CommitmentsCompanion(
        // Keep followUpAt so Reopen restores the loop "with previous dates"
        // (pages/loop-detail.md); done loops never receive nudges because
        // all nudge queries filter on open status.
        status: Value(CommitmentStatus.done),
        updatedAt: Value(DateTime.now()),
      ));
      await _logEvent(id, LoopEventType.done);
    });
  }

  @override
  Future<void> reopenLoop(int id) {
    return (_db.update(_db.commitments)..where((c) => c.id.equals(id))).write(
      CommitmentsCompanion(
        status: Value(CommitmentStatus.open),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Stream<List<LoopWithPerson>> _watchStatus({
    required bool onlyOpen,
    Expression<bool>? extraWhere,
  }) {
    final query = _db.select(_db.commitments).join([
      leftOuterJoin(
        _db.people,
        _db.people.id.equalsExp(_db.commitments.personId),
      ),
    ]);
    query.where(
      onlyOpen
          ? _db.commitments.status.equalsValue(CommitmentStatus.open)
          : _db.commitments.status.equalsValue(CommitmentStatus.done),
    );
    query.where(_db.commitments.deletedAt.isNull());
    if (extraWhere != null) {
      query.where(extraWhere);
    }
    query.orderBy([OrderingTerm.desc(_db.commitments.id)]);
    return query.watch().map(
          (rows) =>
              rows.map((row) => LoopWithPerson.fromRow(_db, row)).toList(),
        );
  }

  @override
  Stream<List<LoopWithPerson>> watchDoneLoopsByPerson(int personId) =>
      _watchStatus(
        onlyOpen: false,
        extraWhere: _db.commitments.personId.equals(personId),
      );

  @override
  Stream<List<LoopWithPerson>> watchArchivedLoops() =>
      _watchStatus(onlyOpen: false);

  @override
  Future<void> updateNote(int id, String? note) {
    return (_db.update(_db.commitments)..where((c) => c.id.equals(id))).write(
      CommitmentsCompanion(note: Value(note), updatedAt: Value(DateTime.now())),
    );
  }

  @override
  Future<List<LoopWithPerson>> searchLoops(String query, {int limit = 50}) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final like = '%${DriftLoopsRepository._normalize(q)}%';
    final query_ = _db.select(_db.commitments).join([
      leftOuterJoin(
        _db.people,
        _db.people.id.equalsExp(_db.commitments.personId),
      ),
    ])
      ..where(_db.commitments.deletedAt.isNull())
      ..limit(limit);
    // Title/note match OR person-name match:
    final titleLike = _db.commitments.title.lower().like(like);
    final noteLike = _db.commitments.note.lower().like(like);
    final personLike = _db.people.normalizedName.like(like);
    query_.where(titleLike | noteLike | personLike);
    final rows = await query_.get();
    return rows.map((row) => LoopWithPerson.fromRow(_db, row)).toList();
  }

  @override
  Future<List<Commitment>> sampleLoops() {
    return (_db.select(_db.commitments)
          ..where((c) => c.sample.equals(true))
          ..where((c) => c.deletedAt.isNull()))
        .get();
  }

  @override
  Future<void> removeAllSamples() {
    return (_db.update(_db.commitments)
          ..where((c) => c.sample.equals(true)))
        .write(CommitmentsCompanion(
      deletedAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));
  }
}
