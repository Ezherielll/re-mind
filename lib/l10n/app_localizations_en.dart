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
  String get homeEmptyBody => 'Capture a commitment and it will show up here.';

  @override
  String get homeCaptureLabel => 'Capture';
}
