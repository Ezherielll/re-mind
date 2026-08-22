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
}
