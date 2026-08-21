import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local-first persistence (ADR-0001).
///
/// Schema v1 is intentionally empty: tables arrive with the features that own
/// them (T02 adds commitments + event log). Every mutable table added later
/// must carry `updatedAt`/`deletedAt` columns.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 're_mind.sqlite'));
        return NativeDatabase.createInBackground(file);
      });
}
