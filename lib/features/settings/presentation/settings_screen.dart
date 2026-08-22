import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/db/providers.dart';
import '../../../l10n/app_localizations.dart';

/// User's chosen daily check-in time as (hour, minute); null = never set.
final digestTimeProvider = FutureProvider<(int, int)?>((ref) async {
  final db = ref.watch(databaseProvider);
  final raw = await db.getSetting(SettingsDao.digestKey);
  if (raw == null) return null;
  final parts = raw.split(':');
  return (int.parse(parts[0]), int.parse(parts[1]));
});

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
              },
            ),
          ],
        ),
      ),
    );
  }
}
