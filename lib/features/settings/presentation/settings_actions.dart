import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../loops/data/providers.dart';
import '../../loops/presentation/home_screen.dart' show samplesProvider;
import '../data/backup_service.dart';

/// User's chosen daily check-in time as (hour, minute); null = never set.
/// Lives here so SettingsActions can read it after restore/import.
final digestTimeProvider = FutureProvider<(int, int)?>((ref) async {
  final db = ref.watch(databaseProvider);
  final raw = await db.getSetting(SettingsDao.digestKey);
  if (raw == null) return null;
  final parts = raw.split(':');
  return (int.parse(parts[0]), int.parse(parts[1]));
});

/// Side-effects for the Settings screen's Data group (T12).
class SettingsActions {
  const SettingsActions._();

  /// Builds the versioned backup and hands it to the OS share sheet.
  static Future<void> export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final json = await exportJson(ref.read(databaseProvider));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/remind-backup.json');
    await file.writeAsString(json);
    try {
      await Share.shareXFiles([XFile(file.path)], text: l10n.exportLabel);
    } catch (_) {}
  }

  /// Picks a backup file, validates, and destructively restores it.
  static Future<void> importBackup(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'JSON', extensions: ['json']),
      ],
    );
    if (file == null) return;
    try {
      await importJson(
        ref.read(databaseProvider),
        await file.readAsString(),
      );
      _invalidateAll(ref);
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
    } on BackupException catch (e) {
      messenger.showSnackBar(SnackBar(
        content: Text(e.reason == 'unsupported-version'
            ? l10n.backupBadVersion
            : l10n.backupInvalid),
      ));
    }
  }

  /// Bottom sheet listing rolling backups; restoring asks for confirmation.
  static Future<void> showBackupsSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final files = await listBackups();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.backupsLabel,
                  style: Theme.of(sheetContext).textTheme.titleMedium),
            ),
            for (final f in files)
              ListTile(
                title: Text(f.uri.pathSegments.last),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.confirmRestoreTitle),
                      content: Text(l10n.confirmRestoreBody),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, false),
                          child: Text(l10n.cancelLabel),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pop(dialogContext, true),
                          child: Text(l10n.restoreLabel),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true) return;
                  try {
                    await restoreBackupFile(
                      ref.read(databaseProvider),
                      f.path,
                    );
                    _invalidateAll(ref);
                    messenger.showSnackBar(
                        SnackBar(content: Text(l10n.backupRestored)));
                  } on BackupException {
                    messenger.showSnackBar(
                        SnackBar(content: Text(l10n.backupInvalid)));
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  static void _invalidateAll(WidgetRef ref) {
    ref.invalidate(digestTimeProvider);
    ref.invalidate(openLoopsProvider);
    ref.invalidate(samplesProvider);
  }
}
