import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/db/providers.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/data/providers.dart';
import 'package:re_mind/main.dart';

/// Shared widget-test harness: pumps the real app against an in-memory
/// Drift database.
///
/// The Riverpod container is created manually and disposed via addTearDown
/// so stream subscriptions close BEFORE the caller's tearDown closes the
/// database — otherwise flutter_tester never goes idle and `flutter test`
/// hangs.
Future<void> pumpApp(WidgetTester tester, AppDatabase db) async {
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      loopsRepositoryProvider.overrideWith(
        (ref) => DriftLoopsRepository(db),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const ReMindApp(),
    ),
  );
  await tester.pumpAndSettle();
}

/// Lets real async work (Drift writes) complete inside the fake-async widget
/// environment, then settles frames.
Future<void> settleRealAsync(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

/// Fresh in-memory database per test.
AppDatabase createInMemoryDb() => AppDatabase(NativeDatabase.memory());
