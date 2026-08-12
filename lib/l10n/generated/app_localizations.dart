import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw'),
  ];

  ///
  ///
  /// In en, this message translates to:
  /// **'mathlab'**
  String get appTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign'**
  String get campaign;

  ///
  ///
  /// In en, this message translates to:
  /// **'Arcade'**
  String get arcade;

  ///
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start Game'**
  String get startGame;

  ///
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  ///
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  ///
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  ///
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  ///
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  ///
  ///
  /// In en, this message translates to:
  /// **'Levels Completed'**
  String get levelsCompleted;

  ///
  ///
  /// In en, this message translates to:
  /// **'COMMAND CENTER'**
  String get commandCenter;

  ///
  ///
  /// In en, this message translates to:
  /// **'QUICK RESUME'**
  String get quickResume;

  ///
  ///
  /// In en, this message translates to:
  /// **'Today\'s Session'**
  String get todaysSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'{pts} pts to Level {level}'**
  String ptsToLevel(int pts, int level);

  ///
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m left'**
  String timeLeftShort(int hours, int minutes);

  ///
  ///
  /// In en, this message translates to:
  /// **'LEVEL {level}'**
  String levelUppercase(int level);

  ///
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  ///
  ///
  /// In en, this message translates to:
  /// **'VICTORY'**
  String get victory;

  ///
  ///
  /// In en, this message translates to:
  /// **'DEFEAT'**
  String get defeat;

  ///
  ///
  /// In en, this message translates to:
  /// **'LEVEL STABILIZED'**
  String get levelStabilized;

  ///
  ///
  /// In en, this message translates to:
  /// **'INTEGRITY FAILED'**
  String get integrityFailed;

  ///
  ///
  /// In en, this message translates to:
  /// **'CORE SCORE'**
  String get coreScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'PLAY AGAIN'**
  String get playAgain;

  ///
  ///
  /// In en, this message translates to:
  /// **'LEVEL UP!'**
  String get levelUp;

  ///
  ///
  /// In en, this message translates to:
  /// **'REWARD POINTS'**
  String get rewardPoints;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Played'**
  String get timePlayed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Addition'**
  String get addition;

  ///
  ///
  /// In en, this message translates to:
  /// **'Subtraction'**
  String get subtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get multiplication;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division'**
  String get division;

  ///
  ///
  /// In en, this message translates to:
  /// **'Visual Counting'**
  String get visualCounting;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  ///
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  ///
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get lives;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  ///
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get timeUppercase;

  ///
  ///
  /// In en, this message translates to:
  /// **'HEAT'**
  String get heat;

  ///
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streakUppercase;

  ///
  ///
  /// In en, this message translates to:
  /// **'MAX STREAK'**
  String get maxStreak;

  ///
  ///
  /// In en, this message translates to:
  /// **'CORRECT'**
  String get correctAnswersLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Over'**
  String get gameOver;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level Complete!'**
  String get levelComplete;

  ///
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueText;

  ///
  ///
  /// In en, this message translates to:
  /// **'RESUME'**
  String get resume;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Paused'**
  String get gamePaused;

  ///
  ///
  /// In en, this message translates to:
  /// **'Exit Game?'**
  String get exitGame;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Current progress will be lost.'**
  String get exitGameDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  ///
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrect;

  ///
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  ///
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Back to Menu'**
  String get backToMenu;

  ///
  ///
  /// In en, this message translates to:
  /// **'Score Attack'**
  String get scoreAttack;

  ///
  ///
  /// In en, this message translates to:
  /// **'Endless'**
  String get endless;

  ///
  ///
  /// In en, this message translates to:
  /// **'Duel'**
  String get duel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get flash;

  ///
  ///
  /// In en, this message translates to:
  /// **'60 seconds to score as high as possible'**
  String get scoreAttackDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'3 lives - keep playing as long as you can'**
  String get endlessDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Race against the AI'**
  String get duelDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Memory challenge - recall the numbers'**
  String get flashDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Simulation'**
  String get simulation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Solar'**
  String get solar;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cyber'**
  String get cyber;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select Operation'**
  String get selectOperation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  ///
  ///
  /// In en, this message translates to:
  /// **'Number Range'**
  String get numberRange;

  ///
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get timer;

  ///
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  ///
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  ///
  ///
  /// In en, this message translates to:
  /// **'Count the shapes!'**
  String get countTheShapes;

  ///
  ///
  /// In en, this message translates to:
  /// **'Enter your answer'**
  String get enterAnswer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  ///
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get dots;

  ///
  ///
  /// In en, this message translates to:
  /// **'Triangles'**
  String get triangles;

  ///
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  ///
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  ///
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  ///
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get seconds;

  ///
  ///
  /// In en, this message translates to:
  /// **'High Score'**
  String get highScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'New High Score!'**
  String get newHighScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avatar'**
  String get avatar;

  ///
  ///
  /// In en, this message translates to:
  /// **'Shape'**
  String get shape;

  ///
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  ///
  ///
  /// In en, this message translates to:
  /// **'Custom Mix'**
  String get customMix;

  ///
  ///
  /// In en, this message translates to:
  /// **'Custom Mix Arithmetic'**
  String get customMixArithmetic;

  ///
  ///
  /// In en, this message translates to:
  /// **'Operation Matrix'**
  String get operationMatrix;

  ///
  ///
  /// In en, this message translates to:
  /// **'Difficulty Level'**
  String get difficultyLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start Mix'**
  String get initiateMixSequence;

  ///
  ///
  /// In en, this message translates to:
  /// **'Session Metrics'**
  String get sessionMetrics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Session'**
  String get gameSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'Configuration'**
  String get configuration;

  ///
  ///
  /// In en, this message translates to:
  /// **'End Session'**
  String get terminateSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'Request Hint'**
  String get requestHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'System Hint'**
  String get systemHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Acknowledge'**
  String get acknowledge;

  ///
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  ///
  ///
  /// In en, this message translates to:
  /// **'Mix Mode Protocol'**
  String get mixModeProtocol;

  ///
  ///
  /// In en, this message translates to:
  /// **'Core Metrics'**
  String get coreMetrics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Progression Status'**
  String get progressionStatus;

  ///
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Real Time Performance'**
  String get realTimePerformance;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level Completion Stats'**
  String get levelCompletionStats;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reaction Analytics'**
  String get reactionAnalytics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Speed Metrics'**
  String get speedMetrics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Invested'**
  String get temporalInvestment;

  ///
  ///
  /// In en, this message translates to:
  /// **'Real Time Accuracy'**
  String get realTimeAccuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level Mastery'**
  String get levelMastery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Achievement Progress'**
  String get achievementProgress;

  ///
  ///
  /// In en, this message translates to:
  /// **'End of Report'**
  String get endOfReport;

  ///
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  ///
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  ///
  ///
  /// In en, this message translates to:
  /// **'Calc'**
  String get calc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Daily Missions'**
  String get dailyMissions;

  ///
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  ///
  ///
  /// In en, this message translates to:
  /// **'Adventure'**
  String get adventure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Modes'**
  String get gameModes;

  ///
  ///
  /// In en, this message translates to:
  /// **'Puzzle World'**
  String get puzzleWorld;

  ///
  ///
  /// In en, this message translates to:
  /// **'Resources & Tools'**
  String get resourcesTools;

  ///
  ///
  /// In en, this message translates to:
  /// **'Logic Riddles'**
  String get logicRiddles;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cross Numbers'**
  String get crossNumbers;

  ///
  ///
  /// In en, this message translates to:
  /// **'Solve cross number puzzles'**
  String get crossNumbersDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avatar Shop'**
  String get avatarShop;

  ///
  ///
  /// In en, this message translates to:
  /// **'Focus Mode'**
  String get focusMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Simplified UI for concentration'**
  String get focusModeDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Performance Mode'**
  String get performanceMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reduce transparency for better performance'**
  String get performanceModeDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Visual Theme'**
  String get visualTheme;

  ///
  ///
  /// In en, this message translates to:
  /// **'Audio Output'**
  String get audioOutput;

  ///
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  ///
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  ///
  ///
  /// In en, this message translates to:
  /// **'Arithmetic Mix Generator'**
  String get arithmeticMixGenerator;

  ///
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  ///
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  ///
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  ///
  ///
  /// In en, this message translates to:
  /// **'HINT'**
  String get hint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 1'**
  String get level_1;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 2'**
  String get level_2;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 3'**
  String get level_3;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 4'**
  String get level_4;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 5'**
  String get level_5;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 6'**
  String get level_6;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 7'**
  String get level_7;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 8'**
  String get level_8;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 9'**
  String get level_9;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 10'**
  String get level_10;

  ///
  ///
  /// In en, this message translates to:
  /// **'+'**
  String get plus;

  ///
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get minus;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ã—'**
  String get multiply;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ã·'**
  String get divide;

  ///
  ///
  /// In en, this message translates to:
  /// **'HOT STREAK!'**
  String get hotStreak;

  ///
  ///
  /// In en, this message translates to:
  /// **'UNSTOPPABLE!'**
  String get unstoppable;

  ///
  ///
  /// In en, this message translates to:
  /// **'KEEP IT UP!'**
  String get keepItUp;

  ///
  ///
  /// In en, this message translates to:
  /// **'STREAK BROKEN!'**
  String get streakBroken;

  ///
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get streak;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  ///
  ///
  /// In en, this message translates to:
  /// **'Swahili'**
  String get swahili;

  ///
  ///
  /// In en, this message translates to:
  /// **'Swahili (Tanzania)'**
  String get swahiliTanzania;

  ///
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get languageChanged;

  ///
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get exportReport;

  ///
  ///
  /// In en, this message translates to:
  /// **'Accuracy Trends'**
  String get accuracyTrends;

  ///
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get help;

  ///
  ///
  /// In en, this message translates to:
  /// **'Refresh Analytics'**
  String get refreshAnalytics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avg Session'**
  String get avgSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'SYS OP'**
  String get sysOp;

  ///
  ///
  /// In en, this message translates to:
  /// **'NEURAL ACCURACY'**
  String get neuralAccuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'CORE STARS'**
  String get coreStars;

  ///
  ///
  /// In en, this message translates to:
  /// **'UNITS CLEARED'**
  String get unitsCleared;

  ///
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get status;

  ///
  ///
  /// In en, this message translates to:
  /// **'MISSION ACTIVE'**
  String get missionActive;

  ///
  ///
  /// In en, this message translates to:
  /// **'END OF TRANSMISSION'**
  String get endOfTransmission;

  ///
  ///
  /// In en, this message translates to:
  /// **'EXPORT PROTOCOL'**
  String get exportProtocol;

  ///
  ///
  /// In en, this message translates to:
  /// **'DISMISS'**
  String get dismiss;

  ///
  ///
  /// In en, this message translates to:
  /// **'DEBRIEF COPIED TO CLIPBOARD'**
  String get debriefCopied;

  ///
  ///
  /// In en, this message translates to:
  /// **'COPY TO CLIPBOARD'**
  String get copyToClipboard;

  ///
  ///
  /// In en, this message translates to:
  /// **'NEURAL EFFICIENCY INDEX'**
  String get neuralEfficiencyIndex;

  ///
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE SCORE'**
  String get performanceScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avg Speed'**
  String get avgSpeed;

  ///
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get high;

  ///
  ///
  /// In en, this message translates to:
  /// **'MED'**
  String get med;

  ///
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get low;

  ///
  ///
  /// In en, this message translates to:
  /// **'ACCURACY PROGRESSION'**
  String get accuracyProgression;

  ///
  ///
  /// In en, this message translates to:
  /// **'Peak Accuracy'**
  String get peakAccuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'RESPONSE ANALYTICS'**
  String get responseAnalytics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avg Response'**
  String get avgResponse;

  ///
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastest;

  ///
  ///
  /// In en, this message translates to:
  /// **'Improvement'**
  String get improvement;

  ///
  ///
  /// In en, this message translates to:
  /// **'LIVE PERFORMANCE METRICS'**
  String get livePerformanceMetrics;

  ///
  ///
  /// In en, this message translates to:
  /// **'CURRENT ACCURACY'**
  String get currentAccuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'SESSION TIME'**
  String get sessionTime;

  ///
  ///
  /// In en, this message translates to:
  /// **'ACTIVE STREAK'**
  String get activeStreak;

  ///
  ///
  /// In en, this message translates to:
  /// **'CALCULATING...'**
  String get calculating;

  ///
  ///
  /// In en, this message translates to:
  /// **'ADVANCED'**
  String get advanced;

  ///
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE TREND'**
  String get performanceTrend;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reaction Time Analysis'**
  String get reactionTimeAnalysis;

  ///
  ///
  /// In en, this message translates to:
  /// **'Operation Usage'**
  String get operationUsage;

  ///
  ///
  /// In en, this message translates to:
  /// **'LEVEL MASTERY BREAKDOWN'**
  String get levelMasteryBreakdown;

  ///
  ///
  /// In en, this message translates to:
  /// **'PERFECT LEVELS'**
  String get perfectLevels;

  ///
  ///
  /// In en, this message translates to:
  /// **'Levels with 35+ correct'**
  String get levelsWith35Plus;

  ///
  ///
  /// In en, this message translates to:
  /// **'HIGH_PERFORMANCE'**
  String get highPerformance;

  ///
  ///
  /// In en, this message translates to:
  /// **'Levels with 30+ correct'**
  String get levelsWith30Plus;

  ///
  ///
  /// In en, this message translates to:
  /// **'GOOD PROGRESS'**
  String get goodProgress;

  ///
  ///
  /// In en, this message translates to:
  /// **'Levels with 25+ correct'**
  String get levelsWith25Plus;

  ///
  ///
  /// In en, this message translates to:
  /// **'TOTAL ATTEMPTS'**
  String get totalAttempts;

  ///
  ///
  /// In en, this message translates to:
  /// **'Total levels attempted'**
  String get totalLevelsAttempted;

  ///
  ///
  /// In en, this message translates to:
  /// **'PLAYER'**
  String get player;

  ///
  ///
  /// In en, this message translates to:
  /// **'DEL'**
  String get del;

  ///
  ///
  /// In en, this message translates to:
  /// **'MC'**
  String get mc;

  ///
  ///
  /// In en, this message translates to:
  /// **'MR'**
  String get mr;

  ///
  ///
  /// In en, this message translates to:
  /// **'DIV BY ZERO'**
  String get divByZero;

  ///
  ///
  /// In en, this message translates to:
  /// **'All Modes'**
  String get allModes;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Learning Progress'**
  String get mathLearningProgress;

  ///
  ///
  /// In en, this message translates to:
  /// **'Preparing PDF...'**
  String get preparingPdf;

  ///
  ///
  /// In en, this message translates to:
  /// **'PDF shared successfully!'**
  String get pdfSharedSuccessfully;

  ///
  ///
  /// In en, this message translates to:
  /// **'Share failed: {error}'**
  String shareFailed(String error);

  ///
  ///
  /// In en, this message translates to:
  /// **'My mathlab Progress Report'**
  String get mymathlabProgressReport;

  ///
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ready to Challenge?'**
  String get readyToChallenge;

  ///
  ///
  /// In en, this message translates to:
  /// **'Master mathematics through engaging games and track your progress.'**
  String get masterMathematicsDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'📈 Your Progress'**
  String get yourProgress;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stars Earned'**
  String get starsEarned;

  ///
  ///
  /// In en, this message translates to:
  /// **'⚡ Quick Actions'**
  String get quickActions;

  ///
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyChallenge;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete today\'s math challenge to earn extra rewards!'**
  String get completeTodaysChallenge;

  ///
  ///
  /// In en, this message translates to:
  /// **'🔥 5 Problems • 100 XP Reward'**
  String get challengeReward;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete levels progressively'**
  String get completeLevelsProgressively;

  ///
  ///
  /// In en, this message translates to:
  /// **'Fast paced challenges'**
  String get fastPacedChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Improve specific skills'**
  String get improveSpecificSkills;

  ///
  ///
  /// In en, this message translates to:
  /// **'Create your own challenges'**
  String get createYourOwnChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  ///
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  ///
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  ///
  ///
  /// In en, this message translates to:
  /// **'Welcome to mathlab'**
  String get welcomeTomathlab;

  ///
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign Mode'**
  String get campaignMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start your mathematical journey'**
  String get startYourMathematicalJourney;

  ///
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Focus on specific operations'**
  String get focusOnSpecificOperations;

  ///
  ///
  /// In en, this message translates to:
  /// **'Arcade Mode'**
  String get arcadeMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Fast-paced gaming experience'**
  String get fastPacedGamingExperience;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  ///
  ///
  /// In en, this message translates to:
  /// **'CHAPTER'**
  String get chapter;

  ///
  ///
  /// In en, this message translates to:
  /// **'{stars} / {total} STARS'**
  String chapterStarsProgress(int stars, int total);

  ///
  ///
  /// In en, this message translates to:
  /// **'LOCKED - NEED {stars} TOTAL STARS'**
  String lockedNeedStars(int stars);

  ///
  ///
  /// In en, this message translates to:
  /// **'Solve challenging logic puzzles'**
  String get solveLogicChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Push updates'**
  String get pushUpdates;

  ///
  ///
  /// In en, this message translates to:
  /// **'SFX & Music'**
  String get sfxAndMusic;

  ///
  ///
  /// In en, this message translates to:
  /// **'Tactile response'**
  String get tactileResponse;

  ///
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get noLimit;

  ///
  ///
  /// In en, this message translates to:
  /// **'EQUIPPED'**
  String get equipped;

  ///
  ///
  /// In en, this message translates to:
  /// **'ACHIEVEMENT UNLOCKED'**
  String get achievementUnlocked;

  ///
  ///
  /// In en, this message translates to:
  /// **'Protocol \"Star Collector\" has been successfully initialized.'**
  String get protocolInitialized;

  ///
  ///
  /// In en, this message translates to:
  /// **'Three new logic nodes available for processing.'**
  String get newLogicNodesAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'Level 10 clearance granted. New sectors unlocked.'**
  String get levelClearanceGranted;

  ///
  ///
  /// In en, this message translates to:
  /// **'View Streak'**
  String get viewStreak;

  ///
  ///
  /// In en, this message translates to:
  /// **'View Achievement'**
  String get viewAchievement;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start Mission'**
  String get startMission;

  ///
  ///
  /// In en, this message translates to:
  /// **'View Progress'**
  String get viewProgress;

  ///
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterYourName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Error saving profile'**
  String get errorSavingProfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeExclamation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your profile'**
  String get letsSetupYourProfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Customize your profile'**
  String get customizeYourProfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  ///
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avatar Shape'**
  String get avatarShape;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avatar Color'**
  String get avatarColor;

  ///
  ///
  /// In en, this message translates to:
  /// **'Basic Mode'**
  String get basicMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Scientific Mode'**
  String get scientificMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Calculation History'**
  String get calculationHistory;

  ///
  ///
  /// In en, this message translates to:
  /// **'No calculations yet'**
  String get noCalculationsYet;

  ///
  ///
  /// In en, this message translates to:
  /// **'Memory'**
  String get memory;

  ///
  ///
  /// In en, this message translates to:
  /// **'Memory is empty'**
  String get memoryIsEmpty;

  ///
  ///
  /// In en, this message translates to:
  /// **'Switch Language'**
  String get switchLanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Switched to'**
  String get switchedTo;

  ///
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'System Status: Active'**
  String get systemStatusActive;

  ///
  ///
  /// In en, this message translates to:
  /// **'Store & Customization'**
  String get storeAndCustomization;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock new avatars with points'**
  String get unlockNewAvatarsWithPoints;

  ///
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  ///
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  ///
  ///
  /// In en, this message translates to:
  /// **'Audio & Haptics'**
  String get audioAndHaptics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Built-in arithmetic tool'**
  String get builtInArithmeticTool;

  ///
  ///
  /// In en, this message translates to:
  /// **'Quick Language Toggle'**
  String get quickLanguageToggle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stargazer'**
  String get stargazer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sharpshooter'**
  String get sharpshooter;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get timeLord;

  ///
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get scholar;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  ///
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctAnswer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Wrong!'**
  String get wrongAnswer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  ///
  ///
  /// In en, this message translates to:
  /// **'Active Challenges'**
  String get activeChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get speedDemon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer as fast as possible!'**
  String get speedDemonDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Master'**
  String get mathMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Achieve perfect accuracy'**
  String get mathMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Marathon'**
  String get marathon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Endurance challenge'**
  String get marathonDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Practice Lab'**
  String get practiceLab;

  ///
  ///
  /// In en, this message translates to:
  /// **'Configurations'**
  String get configurations;

  ///
  ///
  /// In en, this message translates to:
  /// **'Count shapes and objects'**
  String get visualCountingDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Pressure'**
  String get timePressure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Race against time'**
  String get timePressureDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Adaptive Difficulty'**
  String get adaptiveDifficulty;

  ///
  ///
  /// In en, this message translates to:
  /// **'Difficulty adjusts to your skill'**
  String get adaptiveDifficultyDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get timeLimit;

  ///
  ///
  /// In en, this message translates to:
  /// **'Questions Count'**
  String get questionsCount;

  ///
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  ///
  ///
  /// In en, this message translates to:
  /// **'Addition Mode'**
  String get additionProcedure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Subtraction Mode'**
  String get subtractionProcedure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Multiplication Mode'**
  String get multiplicationProcedure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division Mode'**
  String get divisionProcedure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time\'s Up!'**
  String get timesUp;

  ///
  ///
  /// In en, this message translates to:
  /// **'Your score'**
  String get yourScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get exit;

  ///
  ///
  /// In en, this message translates to:
  /// **'Operation'**
  String get operation;

  ///
  ///
  /// In en, this message translates to:
  /// **'Daily reward claimed!'**
  String get dailyRewardClaimed;

  ///
  ///
  /// In en, this message translates to:
  /// **'CLAIM TODAY\'S REWARD'**
  String get claimTodaysReward;

  ///
  ///
  /// In en, this message translates to:
  /// **'No game session'**
  String get noGameSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'Crossword'**
  String get crossword;

  ///
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get playerLabel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Generating image...'**
  String get generatingImage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Image shared successfully!'**
  String get imageSharedSuccessfully;

  ///
  ///
  /// In en, this message translates to:
  /// **'Image export failed'**
  String get imageExportFailed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Preparing document for printing...'**
  String get preparingDocument;

  ///
  ///
  /// In en, this message translates to:
  /// **'Report saved to: {path}'**
  String reportSaved(String path);

  ///
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String reportSaveFailed(String error);

  ///
  ///
  /// In en, this message translates to:
  /// **'mathlab Performance Report'**
  String get performanceReportTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Generating PDF...'**
  String get generatingPdf;

  ///
  ///
  /// In en, this message translates to:
  /// **'Abort Session'**
  String get abortSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get skip;

  ///
  ///
  /// In en, this message translates to:
  /// **'ACROSS'**
  String get across;

  ///
  ///
  /// In en, this message translates to:
  /// **'DOWN'**
  String get down;

  ///
  ///
  /// In en, this message translates to:
  /// **'All challenges complete!'**
  String get allChallengesComplete;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlimited Time'**
  String get unlimitedTime;

  ///
  ///
  /// In en, this message translates to:
  /// **'Practice without pressure'**
  String get practiceWithoutPressure;

  ///
  ///
  /// In en, this message translates to:
  /// **'Show Feedback'**
  String get showFeedback;

  ///
  ///
  /// In en, this message translates to:
  /// **'See correct answers immediately'**
  String get seeCorrectAnswersImmediately;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer revealed!'**
  String get answerRevealed;

  ///
  ///
  /// In en, this message translates to:
  /// **'SELECT RIDDLE LEVEL'**
  String get selectRiddleLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'SELECT CROSSWORD LEVEL'**
  String get selectCrosswordLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Loading game...'**
  String get loadingGame;

  ///
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  ///
  ///
  /// In en, this message translates to:
  /// **'Not enough points! Keep playing to earn more.'**
  String get notEnoughPoints;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avatar unlocked!'**
  String get avatarUnlocked;

  ///
  ///
  /// In en, this message translates to:
  /// **'Document sent to printer!'**
  String get documentSentToPrinter;

  ///
  ///
  /// In en, this message translates to:
  /// **'Print failed: {error}'**
  String printFailed(String error);

  ///
  ///
  /// In en, this message translates to:
  /// **'No progress data available'**
  String get noProgressDataAvailable;

  ///
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get exportOptions;

  ///
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  ///
  ///
  /// In en, this message translates to:
  /// **'Generate and share detailed PDF report'**
  String get generateDetailedPdfReport;

  ///
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get shareAsImage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Capture and share report as high-quality image'**
  String get captureHighQualityImage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Print Report'**
  String get printReport;

  ///
  ///
  /// In en, this message translates to:
  /// **'Send report to printer'**
  String get sendReportToPrinter;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save PDF to device storage'**
  String get savePdfToDeviceStorage;

  ///
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get firstSteps;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer your first question correctly'**
  String get firstStepsDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get speedDemonTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Master'**
  String get mathMasterTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Weekly Champion'**
  String get weeklyChampion;

  ///
  ///
  /// In en, this message translates to:
  /// **'Streak Master'**
  String get streakMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Puzzle Genius'**
  String get puzzleGenius;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get timeLordTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get onFire;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get 5 correct answers in a row'**
  String get onFireDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Perfect Score'**
  String get perfectScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Weekend Master'**
  String get weekendMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'EQUIP'**
  String get equip;

  ///
  ///
  /// In en, this message translates to:
  /// **'Core Concept'**
  String get coreConcept;

  ///
  ///
  /// In en, this message translates to:
  /// **'ADVENTURE'**
  String get adventureTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign Progression'**
  String get campaignProgression;

  ///
  ///
  /// In en, this message translates to:
  /// **'CHALLENGE'**
  String get challengeTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Arcade + Daily Missions'**
  String get arcadeDailyMissions;

  ///
  ///
  /// In en, this message translates to:
  /// **'PUZZLES'**
  String get puzzlesTitle;

  ///
  ///
  /// In en, this message translates to:
  /// **'Crosswords + Math Riddles'**
  String get crosswordsMathRiddles;

  ///
  ///
  /// In en, this message translates to:
  /// **'First Victory'**
  String get firstVictory;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign Master'**
  String get campaignMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Genius'**
  String get mathGenius;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get 10 correct answers in a row'**
  String get unstoppableDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Maintain a Heat Index above 2.5 for an entire session'**
  String get heatIndexDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Flash Calculator'**
  String get flashCalculator;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 50 questions with an average time under 2 seconds'**
  String get flashCalculatorDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get dedicated;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 500 questions'**
  String get dedicatedDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Earn your first 10 stars'**
  String get stargazerDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 100 questions'**
  String get centuryDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 1000 questions'**
  String get mathGeniusDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get 100% accuracy in any game'**
  String get perfectScoreDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play for 7 days in a row'**
  String get weeklyChampionDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete all campaign levels'**
  String get campaignMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Win 10 duel matches'**
  String get duelMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get 25 correct answers in a row'**
  String get legendDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sharp Mind'**
  String get sharpMind;

  ///
  ///
  /// In en, this message translates to:
  /// **'Achieve {percentage}% accuracy in any game mode'**
  String sharpMindDesc(int percentage);

  ///
  ///
  /// In en, this message translates to:
  /// **'Speed Run'**
  String get speedRun;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 10 questions in under {seconds} seconds'**
  String speedRunDesc(int seconds);

  ///
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get committed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play for 30 days in a row'**
  String get committedDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Master of Operations'**
  String get masterOfOperations;

  ///
  ///
  /// In en, this message translates to:
  /// **'Use all four operations'**
  String get masterOfOperationsDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'High Scorer'**
  String get highScorer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Score {points} points in one game'**
  String highScorerDesc(int points);

  ///
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get earlyBird;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play your first game of the day before 8 AM'**
  String get earlyBirdDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Precision Expert'**
  String get precisionExpert;

  ///
  ///
  /// In en, this message translates to:
  /// **'Accuracy Master'**
  String get accuracyMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get lightningFast;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a level in under {seconds} seconds'**
  String lightningFastDesc(int seconds);

  ///
  ///
  /// In en, this message translates to:
  /// **'Instant Reaction'**
  String get instantReaction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Combo King'**
  String get comboKing;

  ///
  ///
  /// In en, this message translates to:
  /// **'Achieve a {multiplier}x combo multiplier'**
  String comboKingDesc(int multiplier);

  ///
  ///
  /// In en, this message translates to:
  /// **'Achieve 95% accuracy with average time under 15 seconds'**
  String get performanceMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Consistent Player'**
  String get consistentPlayer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Maintain {percentage}% accuracy over {count} consecutive questions'**
  String consistentPlayerDesc(int percentage, int count);

  ///
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get nightOwl;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play a game after 10 PM'**
  String get nightOwlDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Weekend Warrior'**
  String get weekendWarrior;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play on both Saturday and Sunday'**
  String get weekendWarriorDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'First Place'**
  String get firstPlace;

  ///
  ///
  /// In en, this message translates to:
  /// **'Reach #1 on the leaderboard'**
  String get firstPlaceDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Mode Explorer'**
  String get modeExplorer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Play all game modes'**
  String get modeExplorerDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Precision Strike'**
  String get precisionStrike;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a level with 35+ correct answers'**
  String get precisionStrikeDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Master Level'**
  String get masterLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a level with 40+ correct answers'**
  String get masterLevelDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Perfect Level'**
  String get perfectLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a level with all 45 questions correct'**
  String get perfectLevelDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get risingStar;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock 10 campaign levels'**
  String get risingStarDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Warrior'**
  String get mathWarrior;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock 25 campaign levels'**
  String get mathWarriorDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign Conqueror'**
  String get campaignConqueror;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete all 50 campaign levels'**
  String get campaignConquerorDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Question Master'**
  String get questionMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Answer 1000 questions across different categories'**
  String get questionMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lightning Level'**
  String get lightningLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a 45-question level in under 45 seconds'**
  String get lightningLevelDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Consistency Master'**
  String get consistencyMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Star Collector'**
  String get starCollector;

  ///
  ///
  /// In en, this message translates to:
  /// **'Stellar Performer'**
  String get stellarPerformer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Earn 50 stars'**
  String get stellarPerformerDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Celestial Master'**
  String get celestialMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Earn 100 stars'**
  String get celestialMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Riddle Master'**
  String get riddleMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete all 30 riddle levels'**
  String get riddleMasterDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Hint Hoarder'**
  String get hintHoarder;

  ///
  ///
  /// In en, this message translates to:
  /// **'Obtain 50 hints'**
  String get hintHoarderDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Grid Explorer'**
  String get gridExplorer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete 5 Cross Numbers puzzles'**
  String get gridExplorerDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Lightning Grid'**
  String get lightningGrid;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete a 7x7 Cross Numbers puzzle in under 90 seconds'**
  String get lightningGridDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Logic Architect'**
  String get logicArchitect;

  ///
  ///
  /// In en, this message translates to:
  /// **'Complete 50 Cross Numbers puzzles'**
  String get logicArchitectDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Campaign Grinder'**
  String get campaignGrinder;

  ///
  ///
  /// In en, this message translates to:
  /// **'Duel Master'**
  String get duelMaster;

  ///
  ///
  /// In en, this message translates to:
  /// **'Endless Survivor'**
  String get endlessSurvivor;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division Expert'**
  String get divisionExpert;

  ///
  ///
  /// In en, this message translates to:
  /// **'Addition Mastery'**
  String get additionMastery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Single Digit Addition'**
  String get singleDigitAddition;

  ///
  ///
  /// In en, this message translates to:
  /// **'Two Digit Addition'**
  String get twoDigitAddition;

  ///
  ///
  /// In en, this message translates to:
  /// **'Three Digit Addition'**
  String get threeDigitAddition;

  ///
  ///
  /// In en, this message translates to:
  /// **'Addition with Carrying'**
  String get additionWithCarrying;

  ///
  ///
  /// In en, this message translates to:
  /// **'Advanced Addition'**
  String get advancedAddition;

  ///
  ///
  /// In en, this message translates to:
  /// **'Subtraction Mastery'**
  String get subtractionMastery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Single Digit Subtraction'**
  String get singleDigitSubtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Two Digit Subtraction'**
  String get twoDigitSubtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Three Digit Subtraction'**
  String get threeDigitSubtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Subtraction with Borrowing'**
  String get subtractionWithBorrowing;

  ///
  ///
  /// In en, this message translates to:
  /// **'Advanced Subtraction'**
  String get advancedSubtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Word Problems - Subtraction'**
  String get wordProblemsSubtraction;

  ///
  ///
  /// In en, this message translates to:
  /// **'Multiplication Mastery'**
  String get multiplicationMastery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Times Tables 1-5'**
  String get timesTables1to5;

  ///
  ///
  /// In en, this message translates to:
  /// **'Times Tables 6-10'**
  String get timesTables6to10;

  ///
  ///
  /// In en, this message translates to:
  /// **'Two Digit Multiplication'**
  String get twoDigitMultiplication;

  ///
  ///
  /// In en, this message translates to:
  /// **'Three Digit Multiplication'**
  String get threeDigitMultiplication;

  ///
  ///
  /// In en, this message translates to:
  /// **'Word Problems - Multiplication'**
  String get multiplicationWordProblems;

  ///
  ///
  /// In en, this message translates to:
  /// **'Advanced Multiplication'**
  String get advancedMultiplication;

  ///
  ///
  /// In en, this message translates to:
  /// **'Multiplication Patterns'**
  String get multiplicationPatterns;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division Mastery'**
  String get divisionMastery;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division Basics'**
  String get divisionBasics;

  ///
  ///
  /// In en, this message translates to:
  /// **'Division with Remainders'**
  String get divisionWithRemainders;

  ///
  ///
  /// In en, this message translates to:
  /// **'Two Digit Division'**
  String get twoDigitDivision;

  ///
  ///
  /// In en, this message translates to:
  /// **'Three Digit Division'**
  String get threeDigitDivision;

  ///
  ///
  /// In en, this message translates to:
  /// **'Word Problems - Division'**
  String get divisionWordProblems;

  ///
  ///
  /// In en, this message translates to:
  /// **'Long Division'**
  String get longDivision;

  ///
  ///
  /// In en, this message translates to:
  /// **'Legend'**
  String get legend;

  ///
  ///
  /// In en, this message translates to:
  /// **'Century'**
  String get century;

  ///
  ///
  /// In en, this message translates to:
  /// **'MATH EQUATIONS - LVL'**
  String get mathEquationsLevelPrefix;

  ///
  ///
  /// In en, this message translates to:
  /// **'SELECT DIFFICULTY LEVEL'**
  String get selectDifficultyLevel;

  ///
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get levelPrefix;

  ///
  ///
  /// In en, this message translates to:
  /// **'Performance Overview'**
  String get performanceOverview;

  ///
  ///
  /// In en, this message translates to:
  /// **'Current Session'**
  String get currentSession;

  ///
  ///
  /// In en, this message translates to:
  /// **'Real-time Stats'**
  String get realTimeStats;

  ///
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  ///
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Mode Distribution'**
  String get gameModeDistribution;

  ///
  ///
  /// In en, this message translates to:
  /// **'Performance Insights'**
  String get performanceInsights;

  ///
  ///
  /// In en, this message translates to:
  /// **'Best Accuracy'**
  String get bestAccuracy;

  ///
  ///
  /// In en, this message translates to:
  /// **'Avg Response Time'**
  String get averageResponseTime;

  ///
  ///
  /// In en, this message translates to:
  /// **'Completion Rate'**
  String get completionRate;

  ///
  ///
  /// In en, this message translates to:
  /// **'ENGINE INTENSITY'**
  String get engineIntensity;

  ///
  ///
  /// In en, this message translates to:
  /// **'AVG HEAT'**
  String get averageHeat;

  ///
  ///
  /// In en, this message translates to:
  /// **'CURRENT HEAT'**
  String get currentHeat;

  ///
  ///
  /// In en, this message translates to:
  /// **'MAX HEAT'**
  String get maxHeat;

  ///
  ///
  /// In en, this message translates to:
  /// **'Heat Index'**
  String get heatIndex;

  ///
  ///
  /// In en, this message translates to:
  /// **'NORMAL'**
  String get intensityNormal;

  ///
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get intensityMedium;

  ///
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get intensityHigh;

  ///
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get intensityCritical;

  ///
  ///
  /// In en, this message translates to:
  /// **'TOTAL SCORE'**
  String get totalScore;

  ///
  ///
  /// In en, this message translates to:
  /// **'{xp} XP to NEXT LEVEL'**
  String xpToLevelFull(int xp);

  ///
  ///
  /// In en, this message translates to:
  /// **'ACHIEVER'**
  String get achiever;

  ///
  ///
  /// In en, this message translates to:
  /// **'AVATAR UNLOCKS'**
  String get avatarUnlocks;

  ///
  ///
  /// In en, this message translates to:
  /// **'Requires Level {level} and {stars} stars!'**
  String requiresLevelAndStars(int level, int stars);

  ///
  ///
  /// In en, this message translates to:
  /// **'Requires {stars} stars to unlock!'**
  String requiresStarsToUnlock(int stars);

  ///
  ///
  /// In en, this message translates to:
  /// **'Requires Level {level} to unlock!'**
  String requiresLevelToUnlock(int level);

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock Avatar?'**
  String get unlockAvatarQuestion;

  ///
  ///
  /// In en, this message translates to:
  /// **'Do you want to spend {cost} points to unlock the {name} avatar?'**
  String unlockAvatarConfirm(int cost, String name);

  ///
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  ///
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get rarityCommon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get rarityUncommon;

  ///
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarityRare;

  ///
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get rarityEpic;

  ///
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get rarityLegendary;

  ///
  ///
  /// In en, this message translates to:
  /// **'Mythic'**
  String get rarityMythic;

  ///
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String generatedOn(String date);

  ///
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  ///
  ///
  /// In en, this message translates to:
  /// **'Initialize Mix'**
  String get initializeMix;

  ///
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standard;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sudden Death'**
  String get suddenDeath;

  ///
  ///
  /// In en, this message translates to:
  /// **'Zen'**
  String get zen;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Attack'**
  String get timeAttack;

  ///
  ///
  /// In en, this message translates to:
  /// **'Mode Protocols'**
  String get modeProtocols;

  ///
  ///
  /// In en, this message translates to:
  /// **'Standard: Solve problems at your own pace with no time limit.'**
  String get standardDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Sudden Death: One mistake and it\'s game over!'**
  String get suddenDeathDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Zen: Relaxed mode with no scoring, just practice.'**
  String get zenDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time Attack: Solve as many problems as possible in 60 seconds.'**
  String get timeAttackDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Elapsed'**
  String get elapsed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Get Hint'**
  String get getHint;

  ///
  ///
  /// In en, this message translates to:
  /// **'Challenges Summary'**
  String get challengesSummary;

  ///
  ///
  /// In en, this message translates to:
  /// **'Daily Challenges'**
  String get dailyChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Weekly Challenges'**
  String get weeklyChallenges;

  ///
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimed;

  ///
  ///
  /// In en, this message translates to:
  /// **'Math Riddles'**
  String get mathRiddles;

  ///
  ///
  /// In en, this message translates to:
  /// **'Time to First Answer'**
  String get timeToFirstAnswer;

  ///
  ///
  /// In en, this message translates to:
  /// **'Timing by Mode'**
  String get timingByMode;

  ///
  ///
  /// In en, this message translates to:
  /// **'Timing Trend'**
  String get timingTrend;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are you getting faster?'**
  String get areYouGettingFaster;

  /// Title for color-blind mode setting
  ///
  /// In en, this message translates to:
  /// **'Color-Blind Mode'**
  String get colorBlindModeTitle;

  /// No color-blind filter
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get colorBlindModeNone;

  /// Protanopia (Red-Blind)
  ///
  /// In en, this message translates to:
  /// **'Protanopia'**
  String get colorBlindModeProtanopia;

  /// Deuteranopia (Green-Blind)
  ///
  /// In en, this message translates to:
  /// **'Deuteranopia'**
  String get colorBlindModeDeuteranopia;

  /// Tritanopia (Blue-Blind)
  ///
  /// In en, this message translates to:
  /// **'Tritanopia'**
  String get colorBlindModeTritanopia;

  /// Description for color-blind mode setting
  ///
  /// In en, this message translates to:
  /// **'Adjust colors for better visibility'**
  String get colorBlindModeDesc;

  /// Button text to equip an item
  ///
  /// In en, this message translates to:
  /// **'Tap to Equip'**
  String get tapToEquip;

  /// Link to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  ///
  ///
  /// In en, this message translates to:
  /// **'ACCURACY TREND'**
  String get accuracyTrend;

  ///
  ///
  /// In en, this message translates to:
  /// **'PROGRESS BY CATEGORY'**
  String get progressByCategory;

  ///
  ///
  /// In en, this message translates to:
  /// **'Your personal record across all modes.'**
  String get personalRecordDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Average time taken to solve a question.'**
  String get avgResponseTimeDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Average time until your first correct answer. Lower means faster engagement.'**
  String get timeToFirstAnswerDesc;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ratio of correctly solved equations.'**
  String get completionRateDesc;
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
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
