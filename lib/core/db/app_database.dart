import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/commitment.dart';

part 'app_database.g.dart';

/// Local-first persistence (ADR-0001).
///
/// Every mutable table carries `updatedAt`/`deletedAt` (soft delete) so a
/// future sync engine has the metadata it needs. The event log records every
/// state transition from day one.
@DriftDatabase(tables: [Commitments, LoopEvents, People])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Versioned from release 1 (ADR-0001): every schema bump adds a step
        // here and a drift schema snapshot for migration tests.
        onUpgrade: (m, from, to) async {},
      );

  static LazyDatabase _openConnection() => LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, 're_mind.sqlite'));
        return NativeDatabase.createInBackground(file);
      });
}

/// One hanging commitment between the user and another person.
///
/// Stored state is deliberately minimal (CONTEXT.md): direction, status,
/// optional dates. Everything shown in the UI beyond this is derived.
class Commitments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get direction => textEnum<Direction>()();
  TextColumn get status => textEnum<CommitmentStatus>()();
  IntColumn get personId => integer()
      .nullable()
      .references(People, #id)();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get followUpAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Append-only history of state transitions (created / followed up / done).
class LoopEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get commitmentId =>
      integer().references(Commitments, #id)();
  TextColumn get type => textEnum<LoopEventType>()();
  DateTimeColumn get occurredAt => dateTime().withDefault(currentDateAndTime)();
}

/// A counterparty, lazily created from free text during capture (CONTEXT.md).
/// `normalizedName` is the dedupe key; `name` preserves what the user typed.
@DataClassName('Person')
class People extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}
