import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';

import 'support/app_test_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createInMemoryDb();
  });
  tearDown(() => db.close());

  testWidgets('home shell renders themed empty state', (tester) async {
    await pumpApp(tester, db);

    expect(find.text('Open loops'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Nothing hanging right now.'), findsOneWidget);
    expect(find.text('Capture your first loop'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
