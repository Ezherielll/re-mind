import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/main.dart';

void main() {
  testWidgets('home shell renders themed empty state', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReMindApp()));

    expect(find.text('Open loops'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Nothing hanging right now.'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
