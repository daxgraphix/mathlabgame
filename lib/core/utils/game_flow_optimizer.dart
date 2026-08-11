import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/generated/app_localizations.dart';
import '../math_engine/math_engine.dart';
import '../game_adaptability/dynamic_difficulty_system.dart';
import '../math_engine/math_riddle_engine.dart';
import '../constants/app_constants.dart';
import '../providers.dart';
import '../../features/game/logic/game_session_provider.dart';

class GameFlowOptimizer {
  static final Map<String, Completer<void>> _loadingCompleters = {};
  static final Map<String, dynamic> _preloadCache = {};
  static Timer? _idleTimer;
  // static const Duration _idleThreshold = Duration(seconds: 3);

  // Preload questions for smoother game transitions
  static Future<void> preloadQuestions({
    required dynamic operation, // String or MixedModeConfig
    required int level,
    int count = 10,
    bool isArcade = false,
    int skillRating = 1000,
    double heatIndex = 1.0,
  }) async {
    final opKey = operation is MixedModeConfig ? operation.toCsv() : operation.toString();
    final key = '${opKey}_${level}_${count}_${isArcade}_${skillRating}_$heatIndex';

    if (_loadingCompleters.containsKey(key)) {
      return _loadingCompleters[key]!.future;
    }

    if (_preloadCache.containsKey(key)) return;

    final completer = Completer<void>();
    _loadingCompleters[key] = completer;

    try {
      // Use batch generation for better performance
      final questions = await MathEngine.generateQuestionsBatch(
        operation,
        level,
        count,
        isArcade: isArcade,
        skillRating: skillRating,
        heatIndex: heatIndex,
      );

      _preloadCache[key] = questions;
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    } finally {
      _loadingCompleters.remove(key);
    }

    return completer.future;
  }

  // Preload MathRiddles for Custom Mix
  static Future<void> preloadRiddles({
    required List<String> operations,
    required int level,
    int count = 10,
  }) async {
    final key = 'riddles_${operations.join(',')}_$level';

    if (_loadingCompleters.containsKey(key)) {
      return _loadingCompleters[key]!.future;
    }

    if (_preloadCache.containsKey(key)) return;

    final completer = Completer<void>();
    _loadingCompleters[key] = completer;

    try {
      // Use the refactored mixed challenge generator which handles isolates internally
      final riddles = await MathRiddleEngine.generateMixedChallenges(count, level);

      _preloadCache[key] = riddles;
      completer.complete();
    } catch (e) {
      completer.completeError(e);
    } finally {
      _loadingCompleters.remove(key);
    }

    return completer.future;
  }

  // Idle-time monitoring to trigger proactive pre-calculation
  static void startIdleMonitoring(WidgetRef ref) {
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final session = ref.read(gameSessionProvider);
      
      // Only preload if we are NOT currently in a game session
      if (session == null || session.state == GameState.finished) {
        _runProactivePrecalculation(ref);
      }
    });
  }

  static void stopIdleMonitoring() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  static Future<void> _runProactivePrecalculation(WidgetRef ref) async {
    final performance = ref.read(playerPerformanceProvider);
    final diffConfig = ref.read(dynamicDifficultyProvider);
    final user = ref.read(userSessionProvider);
    
    final skillRating = user?.skillRating ?? 1000;
    final heatIndex = user?.lastHeatIndex ?? 1.0;

    // 1. Predict next operation based on frequency or weak areas
    // Use weighted mixed mode for pre-calculation if multiple weak/frequent areas exist
    final Map<String, double> weights = {};
    
    if (performance.weakOperations.isNotEmpty) {
      // Focus 60% on the weakest operation, 40% on others
      final weakest = performance.weakOperations.first;
      weights[weakest] = 0.6;
      
      final otherOps = AppConstants.operations.keys.where((op) => op != weakest).toList();
      for (var op in otherOps) {
        weights[op] = 0.4 / otherOps.length;
      }
    } else {
      // Pick top 2 most frequent operations
      final sortedOps = performance.operationFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      if (sortedOps.isNotEmpty) {
        final top1 = sortedOps[0].key;
        weights[top1] = 0.5;
        if (sortedOps.length > 1) {
          weights[sortedOps[1].key] = 0.3;
          final remaining = AppConstants.operations.keys
              .where((op) => op != top1 && op != sortedOps[1].key).toList();
          for (var op in remaining) {
            weights[op] = 0.2 / remaining.length;
          }
        } else {
           final remaining = AppConstants.operations.keys.where((op) => op != top1).toList();
           for (var op in remaining) {
             weights[op] = 0.5 / remaining.length;
           }
        }
      } else {
        weights['addition'] = 1.0;
      }
    }

    final mixedConfig = MixedModeConfig(
      operations: weights.keys.toList(),
      weights: weights,
    );

    // 2. Predict next level
    int targetLevel = diffConfig.currentLevel;
    if (performance.recentAccuracy > 0.85) {
      targetLevel = (targetLevel + 1).clamp(1, 100);
    } else if (performance.recentAccuracy < 0.4) {
      targetLevel = (targetLevel - 1).clamp(1, 100);
    }

    // 3. Trigger pre-calculation for predicted mode
    preloadQuestions(
      operation: mixedConfig,
      level: targetLevel,
      count: 20,
      isArcade: false,
      skillRating: skillRating,
      heatIndex: heatIndex,
    );

    // Also preload a standard arcade batch for variety
    preloadQuestions(
      operation: mixedConfig.operations.first,
      level: targetLevel,
      count: 15,
      isArcade: true,
      skillRating: skillRating,
      heatIndex: heatIndex,
    );

    // Riddle/Mixed preloading
    if (targetLevel > 5) {
      preloadRiddles(
        operations: mixedConfig.operations,
        level: targetLevel,
        count: 10,
      );
    }
  }

  // Get preloaded riddles
  static List<dynamic>? getPreloadedRiddles({
    required List<String> operations,
    required int level,
  }) {
    final key = 'riddles_${operations.join(',')}_$level';
    return _preloadCache[key] as List<dynamic>?;
  }

  // Get preloaded questions
  static List<MathQuestion>? getPreloadedQuestions({
    required dynamic operation, // String or MixedModeConfig
    required int level,
    int count = 10,
    bool isArcade = false,
    int skillRating = 1000,
    double heatIndex = 1.0,
  }) {
    final opKey = operation is MixedModeConfig ? operation.toCsv() : operation.toString();
    final key = '${opKey}_${level}_${count}_${isArcade}_${skillRating}_$heatIndex';
    return _preloadCache[key] as List<MathQuestion>?;
  }

  // Clear preload cache to free memory
  static void clearPreloadCache() {
    _preloadCache.clear();
    _loadingCompleters.clear();
  }

  // Smooth transition builder for game screens
  static Widget buildTransition({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
    );
  }

  // Optimized loading indicator with platform-specific styling
  static Widget buildPlatformLoadingIndicator(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return const CircularProgressIndicator();
    } else {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
  }

  // Memory-efficient game session management
  static void optimizeMemoryUsage() {
    // Clear caches periodically
    Timer.periodic(const Duration(minutes: 5), (_) {
      clearPreloadCache();
      MathEngine.clearCache();
    });
  }
}

class GameDynamicsController {
  static const int maxStreakBonus = 5;
  static const double maxPerformanceMultiplier = 2.0;

  // Calculate adaptive difficulty based on recent performance
  static double calculateAdaptiveDifficulty({
    required List<bool> recentAnswers,
    required int currentStreak,
    required double averageResponseTime,
  }) {
    if (recentAnswers.isEmpty) return 1.0;

    final recentAccuracy = recentAnswers.where((answer) => answer).length / recentAnswers.length;

    // Base difficulty from accuracy
    double difficulty = recentAccuracy;

    // Streak bonus
    final streakMultiplier = 1.0 + (currentStreak.clamp(0, maxStreakBonus) * 0.1);

    // Response time factor (faster answers = higher difficulty)
    final timeFactor = (5000 / averageResponseTime.clamp(500, 5000)).clamp(0.5, 1.5);

    difficulty = difficulty * streakMultiplier * timeFactor;

    return difficulty.clamp(0.3, maxPerformanceMultiplier);
  }

  // Adaptive hint system
  static bool shouldShowHint({
    required int hintsUsed,
    required int totalQuestions,
    required double accuracy,
    required int currentStreak,
  }) {
    // Show hints more frequently for struggling players
    if (accuracy < 0.5) return true;
    if (currentStreak < 2) return true;

    // Limit hints for high performers
    final hintRatio = hintsUsed / totalQuestions;
    return hintRatio < 0.3 && accuracy < 0.8;
  }

  // Dynamic scoring based on performance
  static int calculateDynamicScore({
    required bool isCorrect,
    required int basePoints,
    required int currentStreak,
    required double responseTime,
    required DifficultyLevel difficulty,
  }) {
    if (!isCorrect) return 0;

    double score = basePoints.toDouble();

    // Streak multiplier
    score *= (1.0 + currentStreak * 0.1).clamp(1.0, 2.0);

    // Time bonus (faster answers get more points)
    final timeBonus = (3000 / responseTime.clamp(500, 3000)).clamp(1.0, 1.5);
    score *= timeBonus;

    // Difficulty multiplier
    score *= difficulty.scoreMultiplier;

    return score.round();
  }

  // Performance-based encouragement system
  static String getEncouragementMessage({
    required double accuracy,
    required int streak,
    required int totalQuestions,
  }) {
    if (accuracy >= 0.9 && streak >= 5) {
      return "Outstanding! You're a math superstar! 🌟";
    } else if (accuracy >= 0.8 && streak >= 3) {
      return "Excellent work! Keep up the great performance! 🎯";
    } else if (accuracy >= 0.7) {
      return "Good job! You're doing really well! 👍";
    } else if (accuracy >= 0.6) {
      return "Nice effort! Keep practicing and you'll improve! 💪";
    } else if (totalQuestions > 5) {
      return "Don't worry! Every expert was once a beginner. Try again! 🌱";
    } else {
      return "Let's get started! You've got this! 🚀";
    }
  }
}

class CrossPlatformNavigator {
  static Future<T?> navigateWithLoading<T>(
    BuildContext context,
    WidgetBuilder builder, {
    Duration loadingDelay = const Duration(milliseconds: 100),
  }) async {
    // Show loading indicator briefly for better UX
    if (loadingDelay > Duration.zero) {
      await Future.delayed(loadingDelay);
    }

    // Check if context is still mounted after async operation
    if (!context.mounted) return null;

    final l10n = AppLocalizations.of(context)!;
    return Navigator.push<T>(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameFlowOptimizer.buildPlatformLoadingIndicator(context),
                const SizedBox(height: 16),
                Text(l10n.loadingGame),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void navigateSmoothly(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}
