import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:re_mind/core/db/app_database.dart';
import 'package:re_mind/core/domain/commitment.dart';
import 'package:re_mind/features/loops/data/loops_repository.dart';
import 'package:re_mind/features/settings/data/backup_service.dart';

import '../../../support/app_test_harness.dart';

void main() {
  late AppDatabase db;
  late DriftLoopsRepository repository;

  setUp(() {
    db = createInMemoryDb();
    repository = DriftLoopsRepository(db);
  });
  tearDown(() => db.close());

  test('export → import round-trips faithfully', () async {
    final budi = await repository.findOrCreatePerson('Budi');
    final loop = await repository.createCommitment(
      title: 'Send revision',
      direction: Direction.outgoing,
      personId: budi.id,
      dueDate: DateTime(2026, 9, 1, 9),
      followUpAt: DateTime(2026, 8, 31, 9),
    );
    await repository.updateNote(loop.id, 'v2 by Friday');
    await db
        .into(db.appSettings)
        .insert(AppSettingsCompanion.insert(key: 'digest_time', value: '9:0'));

    final json = await exportJson(db);

    // Restore into a FRESH database and compare.
    final fresh = createInMemoryDb();
    addTearDown(fresh.close);
    await importJson(fresh, json);

    final restored = await fresh.select(fresh.commitments).get();
    expect(restored, hasLength(1));
    expect(restored.single.title, 'Send revision');
    expect(restored.single.personId, budi.id);
    expect(restored.single.note, 'v2 by Friday');
    expect(restored.single.dueDate, DateTime(2026, 9, 1, 9));

    final people = await fresh.select(fresh.people).get();
    expect(people.single.name, 'Budi');

    final events = await fresh.select(fresh.loopEvents).get();
    expect(events.map((e) => e.type), contains(LoopEventType.created));

    final settings = await fresh.select(fresh.appSettings).get();
    expect(settings.single.value, '9:0');
  });

  test('malformed JSON is rejected as malformed', () async {
    expect(
      () => importJson(db, '{not-json'),
      throwsA(
        isA<BackupException>().having(
          (e) => e.reason,
          'reason',
          'malformed',
        ),
      ),
    );
  });

  test('unknown version is rejected as unsupported-version', () async {
    final map = await buildExportMap(db);
    map['version'] = 99;
    expect(
      () => importJson(db, jsonEncode(map)),
      throwsA(
        isA<BackupException>().having(
          (e) => e.reason,
          'reason',
          'unsupported-version',
        ),
      ),
    );
  });

  test('parseBackupJson rejects garbage without a version field', () {
    expect(
      () => parseBackupJson(jsonEncode({'hello': 'world'})),
      throwsA(isA<BackupException>()),
    );
  });

  group('rolling backups', () {
    test('writeRollingBackup prunes to the newest 7', () async {
      final dir =
          Directory.systemTemp.createTempSync('re_mind_bk');
      addTearDown(() => dir.deleteSync(recursive: true));
      for (var i = 0; i < 9; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        await writeRollingBackup(db, dir: dir);
      }
      final files = await listBackups(dir: dir);
      expect(files.length, 7);
    });

    test('listBackups is newest-first and restore works', () async {
      final dir = Directory.systemTemp.createTempSync('re_mind_bk2');
      addTearDown(() => dir.deleteSync(recursive: true));

      final loop = await repository.createCommitment(
        title: 'Send revision',
        direction: Direction.outgoing,
      );
      final f1 = await writeRollingBackup(db, dir: dir);
      await repository.markDone(loop.id);
      final f2 = await writeRollingBackup(db, dir: dir);

      final listed = await listBackups(dir: dir);
      expect(listed.first.path, f2.path);
      expect(listed.last.path, f1.path);

      // Restore the OLDER backup → loop back to open.
      await restoreBackupFile(db, f1.path);
      final open = await repository.watchOpenLoops().first;
      expect(open.single.commitment.id, loop.id);
    });
  });
}