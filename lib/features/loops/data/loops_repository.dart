import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../domain/commitment.dart';

/// Persistence seam for open loops (ADR-0009). UI and controllers depend on
/// this interface only; tests run the Drift implementation over an in-memory
/// database.
abstract class LoopsRepository {
  /// Open, non-deleted loops. Ordering is refined by derived status in T05.
  Stream<List<Commitment>> watchOpenLoops();

  Future<Commitment> createCommitment({
    required String title,
    required Direction direction,
  });
}

class DriftLoopsRepository implements LoopsRepository {
  DriftLoopsRepository(this._db);

  final AppDatabase _db;

  @override
  Stream<List<Commitment>> watchOpenLoops() {
    return (_db.select(_db.commitments)
          ..where((c) => c.status.equalsValue(CommitmentStatus.open))
          ..where((c) => c.deletedAt.isNull())
          ..orderBy([(c) => OrderingTerm.desc(c.id)]))
        .watch();
  }

  @override
  Future<Commitment> createCommitment({
    required String title,
    required Direction direction,
  }) {
    return _db.transaction(() async {
      final commitment = await _db
          .into(_db.commitments)
          .insertReturning(
            CommitmentsCompanion.insert(
              title: title,
              direction: direction,
              status: CommitmentStatus.open,
            ),
          );
      await _db
          .into(_db.loopEvents)
          .insert(LoopEventsCompanion.insert(commitmentId: commitment.id, type: LoopEventType.created));
      return commitment;
    });
  }
}
