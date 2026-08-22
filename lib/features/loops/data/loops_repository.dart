import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';

/// A loop row joined with its optional person — the shape the UI consumes.
class LoopWithPerson {
  final Commitment commitment;
  final Person? person;

  const LoopWithPerson(this.commitment, this.person);
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
  Future<void> updateDates(
    int id, {
    DateTime? dueDate,
    DateTime? followUpAt,
  });

  /// One-shot fetch of a loop with its person for the detail screen.
  Future<LoopWithPerson?> getLoop(int id);
}

class DriftLoopsRepository implements LoopsRepository {
  DriftLoopsRepository(this._db);

  final AppDatabase _db;

  static String _normalize(String raw) =>
      raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  JoinedSelectStatement _openLoopsQuery({Expression<bool>? extraWhere}) {
    final query = _db.select(_db.commitments).join([
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
          (rows) => rows
              .map((row) => LoopWithPerson(
                    row.readTable(_db.commitments),
                    row.readTableOrNull(_db.people),
                  ))
              .toList(),
        );
  }

  @override
  Stream<List<LoopWithPerson>> watchOpenLoopsByPerson(int personId) {
    return _openLoopsQuery(
      extraWhere: _db.commitments.personId.equals(personId),
    ).watch().map(
          (rows) => rows
              .map((row) => LoopWithPerson(
                    row.readTable(_db.commitments),
                    row.readTableOrNull(_db.people),
                  ))
              .toList(),
        );
  }

  @override
  Future<Person> getPerson(int id) {
    return (_db.select(_db.people)..where((p) => p.id.equals(id)))
        .getSingle();
  }

  @override
  Future<Person> findOrCreatePerson(String rawName) {
    final normalized = _normalize(rawName);
    return _db.transaction(() async {
      final existing = await (_db.select(_db.people)
            ..where((p) => p.normalizedName.equals(normalized))
            ..where((p) => p.deletedAt.isNull()))
          .getSingleOrNull();
      if (existing != null) return existing;

      return _db.into(_db.people).insertReturning(
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
          ..where((p) => p.normalizedName.like('%$normalized%'))
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
          .insert(LoopEventsCompanion.insert(commitmentId: commitment.id, type: LoopEventType.created));
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
    final query = _openLoopsQuery(extraWhere: _db.commitments.id.equals(id));
    final rows = await query.get();
    if (rows.isEmpty) return null;
    return LoopWithPerson(
      rows.first.readTable(_db.commitments),
      rows.first.readTableOrNull(_db.people),
    );
  }
}
