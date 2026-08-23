import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/db/app_database.dart';

/// Thrown when a backup file cannot be trusted.
/// [reason] is a stable machine key: `malformed` | `unsupported-version`.
class BackupException implements Exception {
  const BackupException(this.reason);

  final String reason;

  @override
  String toString() => reason;
}

const backupVersion = 1;

/// Builds the versioned export payload from live tables. Includes
/// soft-deleted rows and samples for full-fidelity restore.
Future<Map<String, Object?>> buildExportMap(AppDatabase db) async {
  final commitments = await db.select(db.commitments).get();
  final people = await db.select(db.people).get();
  final events = await db.select(db.loopEvents).get();
  final settings = await db.select(db.appSettings).get();
  return {
    'version': backupVersion,
    'exportedAt': DateTime.now().toIso8601String(),
    'commitments': commitments.map((c) => c.toJson()).toList(),
    'people': people.map((p) => p.toJson()).toList(),
    'loopEvents': events.map((e) => e.toJson()).toList(),
    'settings': settings.map((s) => s.toJson()).toList(),
  };
}

/// Validates and decodes raw backup text. Throws [BackupException] with a
/// stable reason key on malformed JSON or an unsupported version.
Map<String, Object?> parseBackupJson(String raw) {
  final Object? decoded;
  try {
    decoded = jsonDecode(raw);
  } catch (_) {
    throw const BackupException('malformed');
  }
  if (decoded is! Map || decoded['version'] != backupVersion) {
    throw const BackupException('unsupported-version');
  }
  return Map<String, Object?>.from(decoded);
}

Future<String> exportJson(AppDatabase db) async =>
    jsonEncode(await buildExportMap(db));

/// Destructive restore (pages/settings.md): wipes all tables, then inserts
/// the backup preserving ids and timestamps. People are restored before
/// commitments to satisfy the foreign key.
Future<void> importJson(AppDatabase db, String raw) async {
  final map = parseBackupJson(raw);

  Future<void> wipeAll() async {
    await db.delete(db.loopEvents).go();
    await db.delete(db.commitments).go();
    await db.delete(db.people).go();
    await db.delete(db.appSettings).go();
  }

  try {
    await db.transaction(() async {
      await wipeAll();
      for (final j in (map['people'] as List?) ?? const []) {
        await db
            .into(db.people)
            .insert(Person.fromJson(Map.from(j as Map)),
                mode: InsertMode.insertOrReplace);
      }
      for (final j in (map['commitments'] as List?) ?? const []) {
        await db
            .into(db.commitments)
            .insert(Commitment.fromJson(Map.from(j as Map)),
                mode: InsertMode.insertOrReplace);
      }
      for (final j in (map['loopEvents'] as List?) ?? const []) {
        await db
            .into(db.loopEvents)
            .insert(LoopEvent.fromJson(Map.from(j as Map)),
                mode: InsertMode.insertOrReplace);
      }
      for (final j in (map['settings'] as List?) ?? const []) {
        await db
            .into(db.appSettings)
            .insert(AppSetting.fromJson(Map.from(j as Map)),
                mode: InsertMode.insertOrReplace);
      }
    });
  } on BackupException {
    rethrow;
  } catch (_) {
    // Valid JSON envelope but corrupt row shapes — treat as malformed;
    // the transaction has already rolled back any partial wipe.
    throw const BackupException('malformed');
  }
}

// ---- Rolling local backups (last 7 days) -------------------------------

Future<Directory> _backupDir(Directory? override) async {
  if (override != null) return override;
  final support = await getApplicationSupportDirectory();
  return Directory(p.join(support.path, 'backups')).create(recursive: true);
}

/// Writes one timestamped rolling backup; keeps only the newest 7 files.
Future<File> writeRollingBackup(AppDatabase db, {Directory? dir}) async {
  final target = await _backupDir(dir);
  final stamp =
      DateTime.now().toIso8601String().replaceAll(':', '').replaceAll('-', '');
  final file = File(p.join(target.path, 'backup-$stamp.json'));
  await file.writeAsString(await exportJson(db));

  final files = await listBackups(dir: dir);
  if (files.length > 7) {
    for (final old in files.skip(7)) {
      await old.delete();
    }
  }
  return file;
}

/// Backup files, newest first (filenames embed sortable timestamps).
Future<List<File>> listBackups({Directory? dir}) async {
  final files = (await (await _backupDir(dir)).list().toList())
      .whereType<File>()
      .toList()
        ..sort((a, b) => b.path.compareTo(a.path));
  return files;
}

Future<void> restoreBackupFile(AppDatabase db, String path) async {
  await importJson(db, File(path).readAsStringSync());
}
