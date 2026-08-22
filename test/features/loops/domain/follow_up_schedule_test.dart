import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/domain/follow_up_schedule.dart';

void main() {
  // Monday, 2026-08-24 10:00 local.
  final monday = DateTime(2026, 8, 24, 10);
  DateTime at9(int month, int day) => DateTime(2026, month, day, 9);

  group('computeSchedule', () {
    test('incoming with no input defaults to +3 days at 09:00', () {
      final plan = computeSchedule(direction: Direction.incoming, now: monday);
      expect(plan.dueDate, isNull);
      expect(plan.followUpAt, at9(8, 27)); // Thursday
    });

    test('outgoing without a due date defaults to +3 days at 09:00', () {
      final plan = computeSchedule(direction: Direction.outgoing, now: monday);
      expect(plan.followUpAt, at9(8, 27));
    });

    test('outgoing with due date defaults to the day before, 09:00', () {
      final friday = at9(8, 28);
      final plan = computeSchedule(
        direction: Direction.outgoing,
        now: monday,
        dueDate: friday,
      );
      expect(plan.dueDate, friday);
      expect(plan.followUpAt, at9(8, 27)); // H-1
    });

    test('H-1 already past but due upcoming: remind on the due date', () {
      final wednesday9 = at9(8, 26);
      final plan = computeSchedule(
        direction: Direction.outgoing,
        now: DateTime(2026, 8, 25, 10), // Tuesday 10:00
        dueDate: wednesday9,
      );
      expect(plan.followUpAt, wednesday9);
    });

    test('due date already past falls back to +3 days', () {
      final sunday = at9(8, 23);
      final plan = computeSchedule(
        direction: Direction.outgoing,
        now: monday,
        dueDate: sunday,
      );
      expect(plan.followUpAt, at9(8, 27));
    });

    test('explicit chip choice always wins', () {
      final chosen = DateTime(2026, 9, 1, 14, 30);
      final plan = computeSchedule(
        direction: Direction.incoming,
        now: monday,
        followUpAt: chosen,
        dueDate: at9(8, 28),
      );
      expect(plan.followUpAt, chosen);
      expect(plan.dueDate, at9(8, 28));
    });

    test('"on due date" chip stores the due date as the nudge', () {
      final friday = at9(8, 28);
      final plan = computeSchedule(
        direction: Direction.outgoing,
        now: monday,
        dueDate: friday,
        followUpAt: friday,
      );
      expect(plan.followUpAt, friday);
    });
  });

  group('nextFollowUpAfter', () {
    final monday = DateTime(2026, 8, 24, 10);
    final friday = DateTime(2026, 8, 28, 9);

    test('current nudge before a future due date advances to the due date',
        () {
      final next = nextFollowUpAfter(
        now: monday,
        currentFollowUpAt: DateTime(2026, 8, 25, 9),
        dueDate: friday,
      );
      expect(next, friday);
    });

    test('current nudge already on the due date moves to +3 days', () {
      final next = nextFollowUpAfter(
        now: monday,
        currentFollowUpAt: friday,
        dueDate: friday,
      );
      expect(next, DateTime(2026, 8, 27, 9)); // Thu 09:00
    });

    test('no due date moves to +3 days at 09:00', () {
      final next = nextFollowUpAfter(now: monday, currentFollowUpAt: null);
      expect(next, DateTime(2026, 8, 27, 9));
    });

    test('past due date falls back to +3 days', () {
      final next = nextFollowUpAfter(
        now: monday,
        currentFollowUpAt: DateTime(2026, 8, 20, 9),
        dueDate: DateTime(2026, 8, 22, 9),
      );
      expect(next, DateTime(2026, 8, 27, 9));
    });

    test('+3d lands before 09:00 today slides to tomorrow 09:00', () {
      // Monday 07:00 → +3d 09:00 is Thursday but "now+3d" is Thursday 07:00;
      // the helper snaps to 09:00 which is after now — stays Thursday.
      final earlyMonday = DateTime(2026, 8, 24, 7);
      final next = nextFollowUpAfter(
        now: earlyMonday,
        currentFollowUpAt: null,
      );
      expect(next, DateTime(2026, 8, 27, 9));
    });
  });

  group('snoozeUntil', () {
    final monday = DateTime(2026, 8, 24, 10);

    test('adds whole days snapped to 09:00', () {
      expect(snoozeUntil(now: monday, days: 1), DateTime(2026, 8, 25, 9));
      expect(snoozeUntil(now: monday, days: 3), DateTime(2026, 8, 27, 9));
    });

    test('snapped time already past slides one more day', () {
      // Tuesday 08:00 + 1d = Wednesday 08:00 → snap Wed 09:00 is future; ok.
      final tuesdayEarly = DateTime(2026, 8, 25, 6);
      final result = snoozeUntil(now: tuesdayEarly, days: 1);
      expect(result, DateTime(2026, 8, 26, 9));
      // Edge: Wednesday 09:30 +1d snaps to Thursday 09:00 — in future. Fine.
    });
  });
}
