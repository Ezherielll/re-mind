import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Re:Mind'**
  String get appName;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Open loops'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing hanging right now.'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyCta.
  ///
  /// In en, this message translates to:
  /// **'Capture your first loop'**
  String get homeEmptyCta;

  /// No description provided for @homeCaptureLabel.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get homeCaptureLabel;

  /// No description provided for @homeError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get homeError;

  /// No description provided for @captureHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s hanging?'**
  String get captureHint;

  /// No description provided for @capturePersonHint.
  ///
  /// In en, this message translates to:
  /// **'With whom? (optional)'**
  String get capturePersonHint;

  /// No description provided for @directionOutgoing.
  ///
  /// In en, this message translates to:
  /// **'I owe'**
  String get directionOutgoing;

  /// No description provided for @directionIncoming.
  ///
  /// In en, this message translates to:
  /// **'Waiting for'**
  String get directionIncoming;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @personOpenCount.
  ///
  /// In en, this message translates to:
  /// **'{count} open'**
  String personOpenCount(Object count);

  /// No description provided for @personNothingPending.
  ///
  /// In en, this message translates to:
  /// **'Nothing pending with {name}.'**
  String personNothingPending(Object name);

  /// No description provided for @dueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get dueLabel;

  /// No description provided for @noDueDate.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get noDueDate;

  /// No description provided for @remindsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminds'**
  String get remindsLabel;

  /// No description provided for @reminderDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get reminderDefault;

  /// No description provided for @reminderTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get reminderTomorrow;

  /// No description provided for @reminderIn3Days.
  ///
  /// In en, this message translates to:
  /// **'In 3 days'**
  String get reminderIn3Days;

  /// No description provided for @reminderOnDue.
  ///
  /// In en, this message translates to:
  /// **'On due date'**
  String get reminderOnDue;

  /// No description provided for @reminderCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom…'**
  String get reminderCustom;

  /// No description provided for @remindExplainer.
  ///
  /// In en, this message translates to:
  /// **'Will remind {when}'**
  String remindExplainer(Object when);

  /// No description provided for @clearDate.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearDate;

  /// No description provided for @noneLabel.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get noneLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @statusFollowUpDue.
  ///
  /// In en, this message translates to:
  /// **'Follow-up due'**
  String get statusFollowUpDue;

  /// No description provided for @statusDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get statusDue;

  /// No description provided for @statusUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get statusUpcoming;

  /// No description provided for @statusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On track'**
  String get statusOnTrack;

  /// No description provided for @groupCount.
  ///
  /// In en, this message translates to:
  /// **'· {count}'**
  String groupCount(Object count);

  /// No description provided for @followedUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Followed up'**
  String get followedUpLabel;

  /// No description provided for @snoozeLabel.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snoozeLabel;

  /// No description provided for @doneLabel.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneLabel;

  /// No description provided for @snooze1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get snooze1Day;

  /// No description provided for @snooze3Days.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get snooze3Days;

  /// No description provided for @reminderMoved.
  ///
  /// In en, this message translates to:
  /// **'Reminder moved to {when}'**
  String reminderMoved(Object when);

  /// No description provided for @archivedToast.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedToast;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @reopen.
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get reopen;

  /// No description provided for @dailyCheckIn.
  ///
  /// In en, this message translates to:
  /// **'Daily check-in'**
  String get dailyCheckIn;

  /// No description provided for @digestNone.
  ///
  /// In en, this message translates to:
  /// **'All clear — nothing hanging.'**
  String get digestNone;

  /// No description provided for @digestHanging.
  ///
  /// In en, this message translates to:
  /// **'{count} things hanging'**
  String digestHanging(Object count);

  /// No description provided for @digestChase.
  ///
  /// In en, this message translates to:
  /// **', {count} to chase today'**
  String digestChase(Object count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @samplesBanner.
  ///
  /// In en, this message translates to:
  /// **'These are examples — remove them'**
  String get samplesBanner;

  /// No description provided for @removeSamples.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeSamples;

  /// No description provided for @sampleTag.
  ///
  /// In en, this message translates to:
  /// **'Sample'**
  String get sampleTag;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note…'**
  String get noteHint;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search commitments and people'**
  String get searchHint;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get searchPeople;

  /// No description provided for @searchLoopsLabel.
  ///
  /// In en, this message translates to:
  /// **'Loops'**
  String get searchLoopsLabel;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get noMatches;

  /// No description provided for @historyLabel.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyLabel;

  /// No description provided for @eventCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get eventCreated;

  /// No description provided for @archivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedLabel;

  /// No description provided for @dataGroup.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get dataGroup;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportLabel;

  /// No description provided for @importLabel.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importLabel;

  /// No description provided for @backupsLabel.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get backupsLabel;

  /// No description provided for @restoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restoreLabel;

  /// No description provided for @confirmRestoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this backup?'**
  String get confirmRestoreTitle;

  /// No description provided for @confirmRestoreBody.
  ///
  /// In en, this message translates to:
  /// **'This replaces your current data.'**
  String get confirmRestoreBody;

  /// No description provided for @cancelLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelLabel;

  /// No description provided for @backupRestored.
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupRestored;

  /// No description provided for @backupInvalid.
  ///
  /// In en, this message translates to:
  /// **'This file is not a valid Re:Mind backup'**
  String get backupInvalid;

  /// No description provided for @backupBadVersion.
  ///
  /// In en, this message translates to:
  /// **'Unsupported backup version'**
  String get backupBadVersion;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Re:Mind Pro'**
  String get proTitle;

  /// No description provided for @proBenefit1.
  ///
  /// In en, this message translates to:
  /// **'Custom themes'**
  String get proBenefit1;

  /// No description provided for @proBenefit2.
  ///
  /// In en, this message translates to:
  /// **'Advanced history views'**
  String get proBenefit2;

  /// No description provided for @proBenefit3.
  ///
  /// In en, this message translates to:
  /// **'Lifetime — pay once, keep forever'**
  String get proBenefit3;

  /// No description provided for @proOneTime.
  ///
  /// In en, this message translates to:
  /// **'one time'**
  String get proOneTime;

  /// No description provided for @proBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy lifetime'**
  String get proBuy;

  /// No description provided for @proRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchase'**
  String get proRestorePurchases;

  /// No description provided for @proOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get proOwned;

  /// No description provided for @proError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get proError;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'PRO'**
  String get proBadge;

  /// No description provided for @proLockedToast.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Pro'**
  String get proLockedToast;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
