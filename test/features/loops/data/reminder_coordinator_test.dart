import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/core/notifications/reminder_scheduler.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/data/reminder_coordinator.dart';

class FakeScheduler implements ReminderScheduler {
  final scheduled = <int, DateTime>{};
  final cancelled = <int>[];

  @override
  Future<void> scheduleItemAlert({
    required int loopId,
    required String title,
    required DateTime at,
  }) async {
    scheduled[loopId] = at;
  }

  @override
  Future<void> cancelItemAlert(int loopId) async {
    cancelled.add(loopId);
    scheduled.remove(loopId);
  }

  @override
  Future<void> scheduleDailyDigest({
    required int hour,
    required int minute,
    String? body,
  }) async {
    digestCalls.add((hour, minute, body));
  }

  final digestCalls = <(int, int, String?)>[];

  @override
  Future<void> requestPermission() async {}
}

LoopWithPerson _loop(int id, {DateTime? followUpAt, String title = 't'}) =>
    LoopWithPerson(
      Commitment(
        id: id,
        title: title,
        direction: Direction.outgoing,
        status: CommitmentStatus.open,
        followUpAt: followUpAt,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      null,
    );

void main() {
  late FakeScheduler scheduler;
  late ReminderCoordinator coordinator;
  final future = DateTime.now().add(const Duration(days: 1));

  setUp(() {
    scheduler = FakeScheduler();
    coordinator = ReminderCoordinator(scheduler);
  });

  test('sync schedules alerts for loops with future follow-ups', () async {
    await coordinator.sync([_loop(1, followUpAt: future)]);
    expect(scheduler.scheduled[1], future);
  });

  test('re-planned loop is cancelled and rescheduled', () async {
    await coordinator.sync([_loop(1, followUpAt: future)]);
    final newTime = future.add(const Duration(days: 1));

    await coordinator.sync([_loop(1, followUpAt: newTime)]);

    expect(scheduler.cancelled, contains(1));
    expect(scheduler.scheduled[1], newTime);
  });

  test('done loop disappears from the list and its alert is cancelled',
      () async {
    await coordinator.sync([_loop(1, followUpAt: future)]);

    await coordinator.sync([]); // done → gone from open list

    expect(scheduler.cancelled, contains(1));
    expect(scheduler.scheduled, isNot(contains(1)));
  });

  test('unchanged loops are not re-scheduled', () async {
    await coordinator.sync([_loop(1, followUpAt: future)]);
    scheduler.cancelled.clear();

    await coordinator.sync([_loop(1, followUpAt: future)]);

    expect(scheduler.cancelled, isEmpty);
    expect(scheduler.scheduled[1], future);
  });
}
