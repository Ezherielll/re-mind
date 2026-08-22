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
  String get homeError => 'Something went wrong. Please try again.';

  @override
  String get captureHint => 'What\'s hanging?';

  @override
  String get capturePersonHint => 'With whom? (optional)';

  @override
  String get directionOutgoing => 'I owe';

  @override
  String get directionIncoming => 'Waiting for';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String personOpenCount(Object count) {
    return '$count open';
  }

  @override
  String personNothingPending(Object name) {
    return 'Nothing pending with $name.';
  }

  @override
  String get dueLabel => 'Due';

  @override
  String get noDueDate => 'No due date';

  @override
  String get remindsLabel => 'Reminds';

  @override
  String get reminderDefault => 'Default';

  @override
  String get reminderTomorrow => 'Tomorrow';

  @override
  String get reminderIn3Days => 'In 3 days';

  @override
  String get reminderOnDue => 'On due date';

  @override
  String get reminderCustom => 'Custom…';

  @override
  String remindExplainer(Object when) {
    return 'Will remind $when';
  }

  @override
  String get clearDate => 'Clear';

  @override
  String get noneLabel => '—';

  @override
  String get filterAll => 'All';

  @override
  String get statusFollowUpDue => 'Follow-up due';

  @override
  String get statusDue => 'Due';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusOnTrack => 'On track';
}
