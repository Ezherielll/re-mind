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

  @override
  String groupCount(Object count) {
    return '· $count';
  }

  @override
  String get followedUpLabel => 'Followed up';

  @override
  String get snoozeLabel => 'Snooze';

  @override
  String get doneLabel => 'Done';

  @override
  String get snooze1Day => '1 day';

  @override
  String get snooze3Days => '3 days';

  @override
  String reminderMoved(Object when) {
    return 'Reminder moved to $when';
  }

  @override
  String get archivedToast => 'Archived';

  @override
  String get undo => 'Undo';

  @override
  String get reopen => 'Reopen';

  @override
  String get dailyCheckIn => 'Daily check-in';

  @override
  String get digestNone => 'All clear — nothing hanging.';

  @override
  String digestHanging(Object count) {
    return '$count things hanging';
  }

  @override
  String digestChase(Object count) {
    return ', $count to chase today';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get samplesBanner => 'These are examples — remove them';

  @override
  String get removeSamples => 'Remove';

  @override
  String get sampleTag => 'Sample';

  @override
  String get notesLabel => 'Notes';

  @override
  String get noteHint => 'Add a note…';

  @override
  String get searchHint => 'Search commitments and people';

  @override
  String get searchPeople => 'People';

  @override
  String get searchLoopsLabel => 'Loops';

  @override
  String get noMatches => 'No matches';
}
