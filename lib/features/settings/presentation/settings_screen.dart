import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



import '../../../core/db/providers.dart';
import '../../../core/db/settings_dao.dart';
import '../../../l10n/app_localizations.dart';
import 'pro_sheet.dart';
import 'pro_status.dart';
import 'settings_actions.dart';


import '../../loops/data/providers.dart';

// digestTimeProvider now lives in settings_actions.dart.

/// Minimal settings screen (pages/settings.md, Preferences group only).
/// Data/Pro/About groups arrive with T12/T13.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final digest = ref.watch(digestTimeProvider);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: BackButton(
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: Text(l10n.dailyCheckIn),
              subtitle: digest.maybeWhen<Widget?>(
                data: (t) => t == null
                    ? Text(l10n.noDueDate,
                        style: Theme.of(context).textTheme.bodyMedium)
                    : Text(
                        '${t.$1.toString().padLeft(2, '0')}:'
                        '${t.$2.toString().padLeft(2, '0')}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                orElse: () => null,
              ),
              onTap: () async {
                final current = digest.value;
                final picked = await showTimePicker(
                  context: context,
                  initialTime: current == null
                      ? const TimeOfDay(hour: 9, minute: 0)
                      : TimeOfDay(hour: current.$1, minute: current.$2),
                );
                if (picked == null) return;
                await ref
                    .read(databaseProvider)
                    .setSetting(
                      SettingsDao.digestKey,
                      '${picked.hour}:${picked.minute}',
                    );
                ref.invalidate(digestTimeProvider);
                // Re-sync so the digest is rescheduled with the new time.
                ref.invalidate(openLoopsProvider);
                ref.invalidate(samplesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(content: Text(l10n.saved)));
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dataGroup.toUpperCase(),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.exportLabel),
              onTap: () => SettingsActions.export(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(l10n.importLabel),
              onTap: () => SettingsActions.importBackup(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.history_outlined),
              title: Text(l10n.backupsLabel),
              onTap: () => SettingsActions.showBackupsSheet(context, ref),
            ),            const SizedBox(height: 16),
            Text(
              'PRO',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Consumer(builder: (context, ref2, _) {
              final entitled = ref2.watch(proStatusProvider);
              return ListTile(
                leading: Icon(
                  entitled
                      ? Icons.verified_outlined
                      : Icons.workspace_premium_outlined,
                  color: entitled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.secondary,
                ),
                title: Text(l10n.proTitle),
                subtitle: entitled ? null : Text(l10n.proOneTime),
                trailing: entitled
                    ? const Icon(Icons.check)
                    : const Icon(Icons.chevron_right),
                onTap: () => ProSheet.show(context),
              );
            }),
          ],
        ),
      ),
    );
  }
}