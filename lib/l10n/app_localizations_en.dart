// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Re:Mind';

  @override
  String get homeTitle => 'Open loops';

  @override
  String get homeEmptyTitle => 'Nothing hanging right now.';

  @override
  String get homeEmptyCta => 'Capture your first loop';

  @override
  String get homeCaptureLabel => 'Capture';

  @override
  String get captureHint => 'What\'s hanging?';

  @override
  String get directionOutgoing => 'I owe';

  @override
  String get directionIncoming => 'Waiting for';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';
}
