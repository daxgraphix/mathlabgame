import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'core/providers.dart';
import 'core/accessibility/accessibility_settings.dart';
import 'features/game/logic/session_stats_provider.dart';
import 'core/themes/app_themes.dart';
import 'core/utils/game_flow_optimizer.dart';
import 'core/utils/responsive_utils.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/onboarding/splash_screen.dart';
import 'features/profile_setup/profile_setup_screen.dart';
import 'shared/widgets/main_navigation_scaffold.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  GameFlowOptimizer.optimizeMemoryUsage();

  if (Platform.isAndroid || Platform.isIOS) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFF030712),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MathlabApp(),
  ));
}

class MathlabApp extends ConsumerStatefulWidget {
  const MathlabApp({super.key});

  @override
  ConsumerState<MathlabApp> createState() => _MathlabAppState();
}

class _MathlabAppState extends ConsumerState<MathlabApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Global check for session inactivity when returning to app
      ref.read(sessionStatsProvider.notifier).checkInactivity();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final currentTheme = ref.read(themeProvider);
    final themeData = AdaptiveTheme.getAdaptiveTheme(context, currentTheme);

    if (Platform.isAndroid || Platform.isIOS) {
      final isDark = themeData.brightness == Brightness.dark;
      final isSolar = currentTheme == AppThemeType.solar;
      
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: isSolar 
              ? const Color(0xFF0F172A) 
              : themeData.scaffoldBackgroundColor,
          systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeProvider);
    final currentLocale = ref.watch(localeProvider);
    final startupState = ref.watch(startupProvider);
    final themeData = AdaptiveTheme.getAdaptiveTheme(context, currentTheme);

    // Update UI style when theme changes
    ref.listen(themeProvider, (_, _) => _updateSystemUI());

    Widget getHome() {
      if (!startupState.isReady) {
        return const SplashScreen();
      }
      if (startupState.needsIntro) {
        return const OnboardingScreen();
      }
      if (startupState.needsProfileSetup) {
        return const ProfileSetupScreen(isInitialSetup: true);
      }
      return const MainNavigationScaffold();
    }

    return MaterialApp(
      title: 'mathlab',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      locale: Locale(currentLocale.code),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: getHome(),
      builder: (context, child) {
        final accessibilitySettings = ref.watch(accessibilitySettingsProvider);
        
        Widget result = child!;
        
        if (accessibilitySettings.colorBlindMode != ColorBlindMode.none) {
          result = ColorFiltered(
            colorFilter: _getColorFilter(accessibilitySettings.colorBlindMode),
            child: result,
          );
        }

        if (ResponsiveUtils.isWindows()) {
          result = MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: result,
          );
        }
        
        return AccessibilityWrapper(child: result);
      },
    );
  }

  ColorFilter _getColorFilter(ColorBlindMode mode) {
    switch (mode) {
      case ColorBlindMode.protanopia:
        return const ColorFilter.matrix([
          0.567, 0.433, 0, 0, 0,
          0.558, 0.442, 0, 0, 0,
          0, 0.242, 0.758, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case ColorBlindMode.deuteranopia:
        return const ColorFilter.matrix([
          0.625, 0.375, 0, 0, 0,
          0.7, 0.3, 0, 0, 0,
          0, 0.3, 0.7, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case ColorBlindMode.tritanopia:
        return const ColorFilter.matrix([
          0.95, 0.05, 0, 0, 0,
          0, 0.433, 0.567, 0, 0,
          0, 0.475, 0.525, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case ColorBlindMode.none:
        return const ColorFilter.matrix([
          1, 0, 0, 0, 0,
          0, 1, 0, 0, 0,
          0, 0, 1, 0, 0,
          0, 0, 0, 1, 0,
        ]);
    }
  }
}
