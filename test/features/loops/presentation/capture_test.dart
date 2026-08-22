import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/db/providers.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/data/providers.dart';
import 'package:re_mind/features/loops/domain/commitment.dart';
import 'package:re_mind/main.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  /// Pumps the app against a real in-memory Drift database.
  ///
  /// The Riverpod container is created manually and disposed via
  /// addTearDown so stream subscriptions close BEFORE tearDown closes the
  /// database — otherwise flutter_tester never goes idle and `flutter test`
  /// hangs.
  Future<void> pumpHome(WidgetTester tester) async {
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

  /// Lets real async work (Drift writes) complete inside the fake-async
  /// widget environment, then settles frames.
  Future<void> settleRealAsync(WidgetTester tester) async {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('capture save path persists a loop and shows it on home',
      (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Send revision to Budi');
    await tester.pump(); // rebuild with the Save button enabled
    // Direction defaults to "I owe"; save directly.
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settleRealAsync(tester);

    // Sheet closed, loop visible on home, empty state gone.
    expect(find.widgetWithText(FilledButton, 'Save'), findsNothing);
    expect(find.text('Send revision to Budi'), findsOneWidget);
    expect(find.text('Nothing hanging right now.'), findsNothing);
  });

  testWidgets('save is disabled while the text field is empty',
      (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Save'),
    );
    expect(saveButton.onPressed, isNull);
  });

  testWidgets('toggling direction to Waiting for persists incoming',
      (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'Awaiting data from Budi',
    );
    await tester.pump(); // rebuild with the Save button enabled
    await tester.tap(find.text('Waiting for'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await settleRealAsync(tester);

    final loops = await tester.runAsync(
      () => DriftLoopsRepository(db).watchOpenLoops().first,
    );
    expect(loops!.single.direction, Direction.incoming);
  });
}
