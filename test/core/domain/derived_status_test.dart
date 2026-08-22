import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/domain/derived_status.dart';

void main() {
  // Wednesday, 2026-08-26 10:00 local.
  final now = DateTime(2026, 8, 26, 10);
  DateTime d(int month, int day, [int hour = 9]) =>
      DateTime(2026, month, day, hour);

  group('deriveStatus', () {
    test('follow-up time reached wins over everything', () {
      expect(
        deriveStatus(
          now: now,
          followUpAt: d(8, 25),
          dueDate: d(8, 20), // overdue too — follow-up still wins
        ),
        DerivedStatus.followUpDue,
      );
      expect(
        deriveStatus(now: now, followUpAt: d(8, 25), dueDate: d(9, 30)),
        DerivedStatus.followUpDue,
      );
    });

    test('follow-up exactly now counts as reached', () {
      expect(
        deriveStatus(now: now, followUpAt: now),
        DerivedStatus.followUpDue,
      );
    });

    test('due today at midnight is Due', () {
      expect(
        deriveStatus(now: now, dueDate: DateTime(2026, 8, 26)),
        DerivedStatus.due,
      );
    });

    test('due today late evening is Due', () {
      expect(
        deriveStatus(now: now, dueDate: DateTime(2026, 8, 26, 23, 59)),
        DerivedStatus.due,
      );
    });

    test('overdue (yesterday) is Due', () {
      expect(deriveStatus(now: now, dueDate: d(8, 25)), DerivedStatus.due);
    });

    test('future due date is Upcoming even with future follow-up', () {
      expect(
        deriveStatus(now: now, dueDate: d(8, 27), followUpAt: d(8, 27)),
        DerivedStatus.upcoming,
      );
    });

    test('future due date alone is Upcoming', () {
      expect(deriveStatus(now: now, dueDate: d(9, 1)), DerivedStatus.upcoming);
    });

    test('future follow-up alone is On track', () {
      expect(
        deriveStatus(now: now, followUpAt: d(8, 29)),
        DerivedStatus.onTrack,
      );
    });

    test('no dates at all is On track', () {
      expect(deriveStatus(now: now), DerivedStatus.onTrack);
    });

    test('first second of today is Due; first second of tomorrow is not', () {
      expect(
        deriveStatus(now: now, dueDate: DateTime(2026, 8, 26, 0, 0, 0)),
        DerivedStatus.due,
      );
      expect(
        deriveStatus(now: now, dueDate: DateTime(2026, 8, 27, 0, 0, 0)),
        DerivedStatus.upcoming,
      );
    });
  });
}
