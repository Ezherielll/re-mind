import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/db/providers.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/loops/data/providers.dart';
import 'package:re_mind/main.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });
  tearDown(() => db.close());

  testWidgets('home shell renders themed empty state', (tester) async {
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

    expect(find.text('Open loops'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Nothing hanging right now.'), findsOneWidget);
    expect(find.text('Capture your first loop'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
