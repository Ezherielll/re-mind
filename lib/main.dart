import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import 'core/notifications/real_reminder_scheduler.dart';
import 'features/settings/presentation/pro_status.dart';
import 'features/loops/data/reminder_coordinator.dart';
import 'features/loops/data/sample_seed.dart';
import 'features/settings/data/backup_service.dart';
import 'core/db/app_database.dart';
import 'core/theme/app_theme.dart';
import 'features/loops/presentation/home_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();
  final localName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(localName.identifier));
  final bootstrapDb = AppDatabase();
  await seedSampleLoopsOnce(bootstrapDb);
  await writeRollingBackup(bootstrapDb);
  await bootstrapDb.close();
  final scheduler = await RealReminderScheduler.create();
  shadeDbPath = await AppDatabase.filePath();

  final container = ProviderContainer(
    overrides: [
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ],
  );
  final billing = await RealBillingService(
    () => container.read(proStatusProvider.notifier).grant(),
  ).init();
  container.updateOverrides([
    billingProvider.overrideWithValue(billing),
  ]);

  // TODO(#15): re-add Sentry once the Kotlin toolchain is upgraded.
  runApp(UncontrolledProviderScope(
    container: container,
    child: const ReMindApp(),
  ));
}

class ReMindApp extends StatelessWidget {
  const ReMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}
