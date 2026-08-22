import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/domain/commitment.dart';

const sampleFlagKey = 'samples_cleared';

/// Seeds three marked sample loops on first launch (T09) so the home screen
/// demonstrates grouping instead of a dead empty state. Idempotent via the
/// [sampleFlagKey] setting; one-tap removal soft-deletes them.
Future<void> seedSampleLoopsOnce(AppDatabase db) async {
  final cleared = await db.getSetting(sampleFlagKey);
  if (cleared != null) return;
  final existing = await (db.select(db.commitments)
        ..where((c) => c.sample.equals(true)))
      .get();
  if (existing.isNotEmpty) {
    await db.setSetting(sampleFlagKey, 'seeded');
    return;
  }

  final now = DateTime.now();
  DateTime at9(int dayOffset) =>
      DateTime(now.year, now.month, now.day + dayOffset, 9);

  Future<void> add(
    String title,
    Direction direction,
    DateTime? due,
    DateTime? followUp,
  ) =>
      db.into(db.commitments).insert(CommitmentsCompanion.insert(
            title: title,
            direction: direction,
            status: CommitmentStatus.open,
            sample: const Value(true),
            dueDate: Value(due),
            followUpAt: Value(followUp),
          ));

  await add('Confirm logo feedback with Dana', Direction.incoming, null,
      at9(-1)); // Follow-up due
  await add('Send revision to Budi', Direction.outgoing, at9(0),
      null); // Due today
  await add('Prepare portfolio update', Direction.outgoing, at9(9),
      null); // Upcoming
  await db.setSetting(sampleFlagKey, 'seeded');
}
