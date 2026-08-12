import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/game_flow_optimizer.dart';
import '../../../core/math_engine/math_engine.dart';
import '../../../core/providers.dart';
import '../../../core/notification_service.dart';
import '../../../core/sound_manager.dart';
import '../../../core/game_adaptability/dynamic_difficulty_system.dart' as difficulty;
import '../../../data/content_library/achievement_system.dart';
import '../../analytics/analytics_provider.dart';
import '../../custom_mix/logic/custom_mix_mode.dart';
import 'session_stats_provider.dart';
import 'player_performance_provider.dart';

enum GameMode {
  campaign,
  practice,
  scoreAttack,
  endless,
  duel,
  flash,
  speedDemon,
  mathMaster,
  marathon,
  customMix,
}

enum GameState { ready, playing, paused, finished }

class GameSession {
  final GameMode mode;
  final GameState state;
  final String operation;
  final int level;
  final int minNumber;
  final int maxNumber;
  final List<MathQuestion> questions;
  final MathQuestion? currentQuestion;
  final int currentQuestionIndex;
  final int score;
  final int correctAnswers;
  final int currentStreak;
  final int bestStreak;
  final int lives;
  final int timeRemaining;
  final int totalQuestions;
  final bool isVisualCounting;
  final int? aiScore;
  final int? aiCorrectAnswers;
  final bool? playerWon;
  final Map<int, dynamic> userAnswers;
  final Map<int, bool> hintsUsed;
  final List<String> revealedHints;
  final int comboMultiplier;
  final DateTime? lastAnswerTime;
  final bool isBossLevel;
  final VisualCountingData? currentVisualData;
  final List<Map<String, dynamic>> pendingStats;
  final int? ghostScore;
  final List<int>? ghostResponseTimes; // Recorded response times in ms
  final List<bool>? ghostCorrectness;  // Recorded correctness
  final double heatIndex;
  final bool feverActive;
  final CustomMixMode? customMixMode;
  final int elapsedSeconds;
  final int? timeTarget;
  final DateTime? startTime;
  final List<int> responseTimes; // Current session response times in ms
  final List<bool> correctnessHistory; // Current session correctness
  final int lastTimeBonus; // Most recent time bonus added
  final Map<String, dynamic> metadata; // For extensibility (e.g., friend ID for challenges)

  GameSession({
    required this.mode,
    this.state = GameState.playing,
    required this.operation,
    required this.level,
    this.minNumber = 1,
    this.maxNumber = 10,
    required this.questions,
    this.currentQuestion,
    this.currentQuestionIndex = 0,
    this.score = 0,
    this.correctAnswers = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.lives = 3,
    this.timeRemaining = 60,
    this.totalQuestions = 45,
    this.isVisualCounting = false,
    this.aiScore,
    this.aiCorrectAnswers,
    this.playerWon,
    this.userAnswers = const {},
    this.hintsUsed = const {},
    this.revealedHints = const [],
    this.comboMultiplier = 1,
    this.lastAnswerTime,
    this.isBossLevel = false,
    this.currentVisualData,
    this.pendingStats = const [],
    this.ghostScore,
    this.ghostResponseTimes,
    this.ghostCorrectness,
    this.heatIndex = 1.0,
    this.feverActive = false,
    this.customMixMode,
    this.elapsedSeconds = 0,
    this.timeTarget,
    this.startTime,
    this.responseTimes = const [],
    this.correctnessHistory = const [],
    this.lastTimeBonus = 0,
    this.metadata = const {},
  });

  int get questionsRemaining => totalQuestions - currentQuestionIndex;

  double get accuracy => totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;
  
  int get stars {
    if (mode == GameMode.campaign) {
      double pct = accuracy;
      int s = 0;
      if (pct >= 90) {
        s = 3;
      } else if (pct >= 80) {
        s = 2;
      } else if (pct >= 70) {
        s = 1;
      }

      if (s > 0 && timeTarget != null && elapsedSeconds > 0) {
        final timeRatio = elapsedSeconds / timeTarget!;
        // More lenient time thresholds for stars
        if (timeRatio <= 0.8) {
          s = max(s, 3);
        } else if (timeRatio <= 1.0) {
          s = max(s, 2);
        } else if (timeRatio <= 1.2) {
          s = max(s, 1);
        } else {
          // If way too slow, cap at 1 star if accuracy was high
          s = min(s, 1);
        }
      }

      return s.clamp(0, 3);
    } else {
      double pct = accuracy;
      if (pct >= 90) return 3;
      if (pct >= 80) return 2;
      if (pct >= 70) return 1;
      return 0;
    }
  }

  bool get passed {
    switch (mode) {
      case GameMode.campaign:
        // More encouraging: 70% accuracy and more flexible time limit
        final accuracyMet = accuracy >= 70.0;
        final timeMet = timeTarget == null || elapsedSeconds <= (timeTarget! * 1.5);
        return accuracyMet && timeMet;
      case GameMode.duel:
        return playerWon ?? false;
      case GameMode.scoreAttack:
      case GameMode.speedDemon:
      case GameMode.flash:
      case GameMode.customMix:
        // Higher threshold for timed modes: 70% accuracy + positive score
        // For Speed Demon, also require at least 10 correct answers
        if (mode == GameMode.speedDemon) {
          return accuracy >= 70.0 && correctAnswers >= 10;
        }
        return accuracy >= 70.0 && score > 0;
      case GameMode.mathMaster:
        // Elite mode: 90% accuracy and at least 20 correct answers
        return accuracy >= 90.0 && correctAnswers >= 20;
      case GameMode.marathon:
        // Endurance: 70% accuracy and at least 50 correct
        return accuracy >= 70.0 && correctAnswers >= 50;
      case GameMode.endless:
        // Endurance: 65% accuracy and at least 15 correct
        return accuracy >= 65.0 && correctAnswers >= 15;
      case GameMode.practice:
        return true;
    }
  }

  GameSession copyWith({
    GameMode? mode,
    GameState? state,
    String? operation,
    int? level,
    List<MathQuestion>? questions,
    MathQuestion? currentQuestion,
    int? currentQuestionIndex,
    int? score,
    int? correctAnswers,
    int? currentStreak,
    int? bestStreak,
    int? lives,
    int? timeRemaining,
    int? totalQuestions,
    bool? isVisualCounting,
    int? aiScore,
    int? aiCorrectAnswers,
    bool? playerWon,
    Map<int, dynamic>? userAnswers,
    Map<int, bool>? hintsUsed,
    List<String>? revealedHints,
    int? comboMultiplier,
    DateTime? lastAnswerTime,
    bool? isBossLevel,
    VisualCountingData? currentVisualData,
    List<Map<String, dynamic>>? pendingStats,
    int? ghostScore,
    double? heatIndex,
    bool? feverActive,
    CustomMixMode? customMixMode,
    int? elapsedSeconds,
    int? timeTarget,
    DateTime? startTime,
    List<int>? responseTimes,
    List<bool>? correctnessHistory,
    int? lastTimeBonus,
    Map<String, dynamic>? metadata,
  }) {
    return GameSession(
      mode: mode ?? this.mode,
      state: state ?? this.state,
      operation: operation ?? this.operation,
      level: level ?? this.level,
      questions: questions ?? this.questions,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lives: lives ?? this.lives,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isVisualCounting: isVisualCounting ?? this.isVisualCounting,
      aiScore: aiScore ?? this.aiScore,
      aiCorrectAnswers: aiCorrectAnswers ?? this.aiCorrectAnswers,
      playerWon: playerWon ?? this.playerWon,
      userAnswers: userAnswers ?? this.userAnswers,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      revealedHints: revealedHints ?? this.revealedHints,
      comboMultiplier: comboMultiplier ?? this.comboMultiplier,
      lastAnswerTime: lastAnswerTime ?? this.lastAnswerTime,
      isBossLevel: isBossLevel ?? this.isBossLevel,
      currentVisualData: currentVisualData ?? this.currentVisualData,
      pendingStats: pendingStats ?? this.pendingStats,
      ghostScore: ghostScore ?? this.ghostScore,
      ghostResponseTimes: ghostResponseTimes ?? ghostResponseTimes,
      ghostCorrectness: ghostCorrectness ?? ghostCorrectness,
      heatIndex: heatIndex ?? this.heatIndex,
      feverActive: feverActive ?? this.feverActive,
      customMixMode: customMixMode ?? this.customMixMode,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      timeTarget: timeTarget ?? this.timeTarget,
      startTime: startTime ?? this.startTime,
      responseTimes: responseTimes ?? this.responseTimes,
      correctnessHistory: correctnessHistory ?? this.correctnessHistory,
      lastTimeBonus: lastTimeBonus ?? this.lastTimeBonus,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mode': mode.name,
      'operation': operation,
      'level': level,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'responseTimes': responseTimes,
      'correctnessHistory': correctnessHistory,
      'ghostScore': score,
      'ghostResponseTimes': responseTimes,
      'ghostCorrectness': correctnessHistory,
      'heatIndex': heatIndex,
      'elapsedSeconds': elapsedSeconds,
      'timeTarget': timeTarget,
      'metadata': metadata,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      mode: GameMode.values.firstWhere((m) => m.name == json['mode']),
      operation: json['operation'] as String,
      level: json['level'] as int,
      questions: [], 
      score: 0,
      correctAnswers: 0,
      totalQuestions: json['totalQuestions'] as int,
      responseTimes: [],
      correctnessHistory: [],
      ghostScore: json['ghostScore'] as int?,
      ghostResponseTimes: List<int>.from(json['ghostResponseTimes'] ?? json['responseTimes'] ?? []),
      ghostCorrectness: List<bool>.from(json['ghostCorrectness'] ?? json['correctnessHistory'] ?? []),
      heatIndex: (json['heatIndex'] as num?)?.toDouble() ?? 1.0,
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      timeTarget: json['timeTarget'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }
}

class VisualCountingData {
  final int targetCount;
  final List<ShapeData> shapes;

  VisualCountingData({required this.targetCount, required this.shapes});
}

class ShapeData {
  final String type;
  final double x;
  final double y;
  final double size;
  final int color;

  ShapeData({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}

final gameSessionProvider =
    StateNotifierProvider<GameSessionNotifier, GameSession?>((ref) {
      return GameSessionNotifier(ref);
    });

class GameSessionNotifier extends StateNotifier<GameSession?> {
  static int getCampaignPassThreshold(int totalQuestions) {
    // Require 70% to pass
    return (totalQuestions * 0.7).ceil();
  }

  static int _calculateCampaignTimeTarget(int level, int totalQuestions) {
    // Dynamic difficulty: Target time decreases as level increases to challenge the player.
    // Base: starts at ~8s/question, tightening to ~5s/question at higher levels.
    double secondsPerQuestion = (8.0 - (level * 0.03)).clamp(5.0, 8.0);
    return (totalQuestions * secondsPerQuestion).round();
  }

  final Ref ref;
  Timer? _timer;
  Timer? _duelTimer;
  final Random _random = Random();
  bool _duelAnswered = false;

  GameSessionNotifier(this.ref) : super(null);

  Future<void> startGame({
    required GameMode mode,
    required String operation,
    int level = 1,
    int minNumber = 1,
    int maxNumber = 10,
    bool isVisualCounting = false,
    int? totalQuestions,
    int? timeLimit,
    List<MathQuestion>? preloadedQuestions,
    CustomMixMode? customMixMode,
    int? ghostScore,
    List<int>? ghostResponseTimes,
    List<bool>? ghostCorrectness,
  }) async {
    _timer?.cancel();
    _duelTimer?.cancel();
    ref.read(sessionStatsProvider.notifier).reset();

    bool isBossLevel = false;
    int calculatedTotalQuestions = totalQuestions ?? 45;
    int timeRemaining = 60;
    int lives = 3;
    int? timeTarget;

    if (mode == GameMode.customMix) {
      switch (customMixMode) {
        case CustomMixMode.standard:
          calculatedTotalQuestions = 20;
          timeRemaining = 120;
          break;
        case CustomMixMode.suddenDeath:
          calculatedTotalQuestions = 50;
          timeRemaining = 45;
          break;
        case CustomMixMode.zen:
          calculatedTotalQuestions = 30;
          timeRemaining = 30;
          break;
        case CustomMixMode.timeAttack:
          calculatedTotalQuestions = 100;
          timeRemaining = 60;
          break;
        case null:
          calculatedTotalQuestions = 20;
          timeRemaining = 120;
          break;
      }
    } else {
      // Mode-specific configuration
      if (mode == GameMode.campaign) {
      timeRemaining = 0;
      calculatedTotalQuestions = level <= 50 ? 50 : 60;
      timeTarget = _calculateCampaignTimeTarget(level, calculatedTotalQuestions);
      if (level % 10 == 0) {
        isBossLevel = true;
      }
    } else if (mode == GameMode.scoreAttack) {
        // Balanced scaling for Arcade: More questions, but tighter base time
        timeRemaining = (60 + (level - 1) * 2.0).round().clamp(60, 180);
        calculatedTotalQuestions = 500; // Effectively endless for the duration
      } else if (mode == GameMode.speedDemon) {
        timeRemaining = (30 + (level - 1) * 1.0).round().clamp(30, 60);
        calculatedTotalQuestions = 500;
      } else if (mode == GameMode.endless) {
        timeRemaining = 0;
        calculatedTotalQuestions = 2000; 
        lives = 3;
      } else if (mode == GameMode.mathMaster) {
        timeRemaining = 0;
        calculatedTotalQuestions = (100 * (1 + level * 0.05)).toInt();
        lives = 999;
      } else if (mode == GameMode.marathon) {
        timeRemaining = 0;
        calculatedTotalQuestions = 1000;
        lives = 999;
      } else if (mode == GameMode.duel) {
        timeRemaining = 0;
        calculatedTotalQuestions = 50;
      } else if (mode == GameMode.flash) {
        timeRemaining = (45 + (level - 1) * 1.0).round().clamp(45, 120);
        calculatedTotalQuestions = (60 * (1 + level * 0.05)).toInt();
      }
    }

    // Explicit overrides
    if (timeLimit != null) timeRemaining = timeLimit;
    if (totalQuestions != null) calculatedTotalQuestions = totalQuestions;

    // Set lives for modes that don't use lives
    if (mode == GameMode.mathMaster || mode == GameMode.marathon) {
      lives = 999; // effectively infinite
    }

    int? aiScore;
    int? aiCorrectAnswers;
    if (mode == GameMode.duel) {
      aiScore = 0;
      aiCorrectAnswers = 0;
    }

    int? ghostScore;
    if (mode == GameMode.scoreAttack) {
      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      ghostScore = await levelProgressRepo.getHighScore(operation, level);
    }

    final user = ref.read(userSessionProvider);
    final skillRating = user?.skillRating ?? 1000;

    final questions = preloadedQuestions ?? <MathQuestion>[];
    
    if (questions.isEmpty) {
      final isArcade =
          mode == GameMode.scoreAttack ||
          mode == GameMode.endless ||
          mode == GameMode.duel ||
          mode == GameMode.flash ||
          mode == GameMode.speedDemon ||
          mode == GameMode.mathMaster ||
          mode == GameMode.marathon ||
          mode == GameMode.customMix;

      final batch = await MathEngine.generateQuestionsBatch(
        operation,
        level,
        calculatedTotalQuestions,
        isArcade: isArcade,
        skillRating: skillRating,
        heatIndex: 1.0, // Initial heat is 1.0
      );
      questions.addAll(batch);
      
      // Shuffle questions for random order for ALL modes to ensure variety
      questions.shuffle();
    }

    // Save session info to user profile for "Quick Resume"
    ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: mode.name,
          lastPlayedOperation: operation,
          lastPlayedLevel: level,
          lastPlayedAt: DateTime.now(),
          lastHeatIndex: user?.lastHeatIndex ?? 1.0,
        );

    state = GameSession(
      mode: mode,
      operation: operation,
      level: level,
      minNumber: minNumber,
      maxNumber: maxNumber,
      questions: questions,
      currentQuestion: questions.isNotEmpty ? questions[0] : null,
      totalQuestions: calculatedTotalQuestions,
      timeRemaining: timeRemaining,
      lives: lives,
      isVisualCounting: isVisualCounting,
      aiScore: aiScore,
      aiCorrectAnswers: aiCorrectAnswers,
      isBossLevel: isBossLevel,
      currentVisualData: isVisualCounting ? _generateVisualCountingData(level) : null,
      ghostScore: (ghostScore ?? 0) > 0 ? ghostScore : null,
      ghostResponseTimes: ghostResponseTimes,
      ghostCorrectness: ghostCorrectness,
      heatIndex: user?.lastHeatIndex ?? 1.0,
      customMixMode: customMixMode,
      elapsedSeconds: 0,
      timeTarget: timeTarget,
      startTime: DateTime.now(),
      lastAnswerTime: DateTime.now(),
    );

    if (mode == GameMode.scoreAttack ||
        mode == GameMode.speedDemon ||
        mode == GameMode.flash ||
        mode == GameMode.campaign ||
        mode == GameMode.practice ||
        (mode == GameMode.customMix && timeRemaining > 0) ||
        (mode == GameMode.customMix && customMixMode == CustomMixMode.zen)) {
      _startTimer();
    } else if (mode == GameMode.duel) {
      _startDuelMode();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) return;

      double newHeat = state!.heatIndex;
      // Periodic decay: reduce heat slightly every 4 seconds to balance difficulty
      if (state!.elapsedSeconds > 0 && state!.elapsedSeconds % 4 == 0) {
        newHeat = (newHeat - 0.06).clamp(1.0, 4.0);
      }

      if (state!.timeRemaining > 0) {
        state = state!.copyWith(
          timeRemaining: state!.timeRemaining - 1,
          heatIndex: newHeat,
          elapsedSeconds: state!.elapsedSeconds + 1,
        );
        ref.read(soundManagerProvider).updateHeat(newHeat);

        if (state!.timeRemaining <= 0) {
          _endGame();
        }
      } else if (state!.mode == GameMode.campaign ||
                 (state!.mode == GameMode.customMix && state!.customMixMode == CustomMixMode.zen) ||
                 state!.mode == GameMode.practice) {
        state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
      } else if (state!.mode == GameMode.scoreAttack ||
                 state!.mode == GameMode.speedDemon ||
                 state!.mode == GameMode.flash ||
                 (state!.mode == GameMode.customMix && state!.timeRemaining <= 0)) {
        _endGame();
      }
    });
  }

  void _startDuelMode() {
    _processDuelTurn();
  }

  void _processDuelTurn() {
    if (state == null || state!.mode != GameMode.duel) return;
    if (state!.currentQuestionIndex >= state!.totalQuestions) {
      _endGame();
      return;
    }

    _duelAnswered = false;
    
    // Check if we have ghost data for this question index
    final int? ghostTime = (state!.ghostResponseTimes != null && state!.ghostResponseTimes!.length > state!.currentQuestionIndex)
        ? state!.ghostResponseTimes![state!.currentQuestionIndex]
        : null;
    final bool? ghostCorrect = (state!.ghostCorrectness != null && state!.ghostCorrectness!.length > state!.currentQuestionIndex)
        ? state!.ghostCorrectness![state!.currentQuestionIndex]
        : null;

    final aiTime = ghostTime ?? MathEngine.getAIAnswerTime(state!.operation, state!.level);

    _duelTimer = Timer(Duration(milliseconds: aiTime), () {
      if (_duelAnswered || state == null) return;

      final bool isCorrect = ghostCorrect ?? (_random.nextDouble() < _getAIAccuracy());
      int newAiScore = state!.aiScore ?? 0;
      int newAiCorrect = state!.aiCorrectAnswers ?? 0;

      if (isCorrect) {
        newAiScore += 10;
        newAiCorrect++;
      }

      state = state!.copyWith(
        aiScore: newAiScore,
        aiCorrectAnswers: newAiCorrect,
      );
    });
  }

  double _getAIAccuracy() {
    final level = state?.level ?? 1;
    final baseAccuracy = 0.7;
    final levelBonus = (level / 50).clamp(0.0, 0.2);
    return (baseAccuracy + levelBonus).clamp(0.5, 0.95);
  }

  void answerQuestion(dynamic answer) {
    if (state == null || state!.currentQuestion == null) return;

    // If question already answered, do not count again (for next/prev feature)
    if (state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      _goToNextOrEnd();
      return;
    }

    final isCorrect = answer.toString() == state!.currentQuestion!.correctAnswer.toString();
    
    // Performance improvement: track stats early
    final now = DateTime.now();
    final timeSpent = now.difference(state!.lastAnswerTime!).inMilliseconds.clamp(1, 300000);
    final timeSpentSeconds = (timeSpent / 1000).ceil().clamp(1, 300);

    int newScore = state!.score;
    int newCorrect = state!.correctAnswers;
    int newLives = state!.lives;
    int newStreak = isCorrect ? state!.currentStreak + 1 : 0;
    int newBestStreak = max(state!.bestStreak, newStreak);

    final newResponseTimes = List<int>.from(state!.responseTimes)..add(timeSpent);
    final newCorrectnessHistory = List<bool>.from(state!.correctnessHistory)..add(isCorrect);

    final hintUsed = state!.hintsUsed[state!.currentQuestionIndex] ?? false;
    final challengeNotifier = ref.read(dailyChallengeProvider.notifier);

    challengeNotifier.incrementProgress('questions', 1);
    challengeNotifier.updateProgressMax('streak', newStreak);

    int newCombo = state!.comboMultiplier;
    bool newFever = state!.feverActive;

    if (state!.lastAnswerTime != null &&
        now.difference(state!.lastAnswerTime!).inSeconds <= 4) {
      newCombo = (newCombo < 4) ? newCombo + 1 : 4;
      if (newCombo >= 4 && !newFever) {
        newFever = true;
        HapticManager.instance.milestonePattern();
        ref.read(soundManagerProvider).playEffect('fever_start');
      }
    } else {
      newCombo = 1;
      if (newFever) {
        newFever = false;
        HapticManager.instance.lightImpact();
        ref.read(soundManagerProvider).playEffect('fever_end');
      }
    }

    int bonusSeconds = 0;
    int questionScore = 0;
    if (isCorrect) {
      HapticManager.instance.correctAnswerPattern();
      ref.read(soundManagerProvider).playCorrect();
      challengeNotifier.incrementProgress('correct', 1);
      final baseScore = _getScoreForMode();
      int multiplier = newCombo;
      if (newFever) multiplier *= 2; // Double points during fever
      
      questionScore = (hintUsed ? (baseScore ~/ 2) : baseScore) * multiplier;
      newScore += questionScore;
      newCorrect++;

      // Dynamic Time Bonuses: Rewarding high Heat and rapid responses
      if (state!.mode == GameMode.scoreAttack) {
        // High heat + fast combo = more time survival
        int heatBonus = state!.heatIndex > 2.0 ? 1 : 0;
        int speedBonus = timeSpent < 2000 ? 2 : (timeSpent < 3500 ? 1 : 0);
        bonusSeconds = 1 + heatBonus + speedBonus;
      } else if (state!.mode == GameMode.speedDemon) {
        // Speed demon is stingy: only rewards sub-1.5s answers
        bonusSeconds = timeSpent < 1500 ? 1 : 0;
      } else if (state!.mode == GameMode.customMix && state!.customMixMode == CustomMixMode.timeAttack) {
        bonusSeconds = timeSpent < 2500 ? 3 : 1;
      }

      if (newCombo == 5) {
        HapticManager.instance.streakPattern(5);
        ref.read(soundManagerProvider).playLevelUp();
        NotificationService().showStreakNotification(
          '5-Question Streak!',
          'Keep going! You\'ve answered 5 in a row.',
        );
      } else if (newCombo == 10) {
        HapticManager.instance.streakPattern(10);
        ref.read(soundManagerProvider).playLevelUp();
        NotificationService().showAchievementNotification(
          '10-Question Streak!',
          'Incredible! Double-digit streak achieved.',
        );
      } else if (newCombo == 15) {
        HapticManager.instance.achievementPattern();
        ref.read(soundManagerProvider).playAchievement();
        NotificationService().showAchievementNotification(
          '15-Question Streak!',
          'Unstoppable! You\'re on fire!',
        );
      }

      if (state!.currentQuestion?.operation == 'division') {
        challengeNotifier.incrementProgress('division', 1);
      }
      if (state!.mode == GameMode.speedDemon) {
        challengeNotifier.incrementProgress('speed', 1);
      }
    } else {
      HapticManager.instance.wrongAnswerPattern();
      ref.read(soundManagerProvider).playIncorrect();
      newCombo = 1;
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
      if (state!.isBossLevel) {
        newLives--;
      }
      ref.read(dailyChallengeProvider.notifier).updateProgressMax('streak', 0);
    }

    final newUserAnswers = Map<int, dynamic>.from(state!.userAnswers);
    newUserAnswers[state!.currentQuestionIndex] = answer;

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    newPendingStats.add({
      'operationId': state!.operation,
      'isCorrect': isCorrect,
      'timeSpent': timeSpent,
      'score': questionScore,
      'mode': state!.mode.name,
      'levelKey': '${state!.operation}_${state!.level}',
      'concepts': state!.currentQuestion?.concepts ?? [],
    });

    // Calculate Heat Index: increases if answering quickly and correctly
    double newHeat = state!.heatIndex;
    if (isCorrect) {
      if (timeSpent <= 2500) { // Under 2.5s
        newHeat += 0.12; 
      } else if (timeSpent <= 4000) { // 2.5s - 4s
        newHeat += 0.05;
      } else if (timeSpent > 7000) { // Over 7s: Slight decay even if correct
        newHeat -= 0.05;
      }
    } else {
      newHeat = (newHeat - 0.30).clamp(1.0, 4.0); // Sharper drop on error
    }

    // Update sound manager heat index
    ref.read(soundManagerProvider).updateHeat(newHeat);
    
    // Endless mode makes heat increase gradually over time to ensure progression
    if (state!.mode == GameMode.endless && isCorrect) {
       newHeat += 0.01;
    }
    
    newHeat = newHeat.clamp(1.0, 4.0);

    // If heat increased significantly, inject a tougher question
    List<MathQuestion> updatedQuestions = List.from(state!.questions);
    if (newHeat > state!.heatIndex + 0.1 && state!.currentQuestionIndex + 1 < state!.totalQuestions) {
       final user = ref.read(userSessionProvider);
       final skillRating = user?.skillRating ?? 1000;
       
       // Optimization: generate next few questions in batch if we are at high heat to avoid frequent injections
       final injectionCount = (newHeat > 2.5) ? 3 : 1;
       final startIndex = state!.currentQuestionIndex + 1;
       final remainingInBatch = state!.totalQuestions - startIndex;
       final count = min(injectionCount, remainingInBatch);

       if (count > 0) {
         // Using future to not block current answer processing, though generateQuestionsBatch handles isolate for small batches too now
         MathEngine.generateQuestionsBatch(
           state!.operation,
           state!.level,
           count,
           isArcade: state!.mode != GameMode.campaign,
           skillRating: skillRating,
           heatIndex: newHeat,
         ).then((newBatch) {
            if (state != null) {
              final currentQuestions = List<MathQuestion>.from(state!.questions);
              for (int i = 0; i < newBatch.length; i++) {
                if (startIndex + i < currentQuestions.length) {
                  currentQuestions[startIndex + i] = newBatch[i];
                }
              }
              state = state!.copyWith(questions: currentQuestions);
            }
         });
       }
    }



    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      currentStreak: newStreak,
      bestStreak: max(state!.bestStreak, newBestStreak),
      lives: newLives,
      timeRemaining: state!.mode == GameMode.customMix && state!.customMixMode == CustomMixMode.suddenDeath && isCorrect
          ? 7 // Tighter window for sudden death (7 seconds to answer)
          : state!.timeRemaining + bonusSeconds,
      userAnswers: newUserAnswers,
      comboMultiplier: newCombo,
      feverActive: newFever,
      lastAnswerTime: now,
      pendingStats: newPendingStats,
      heatIndex: newHeat,
      questions: updatedQuestions,
      responseTimes: newResponseTimes,
      correctnessHistory: newCorrectnessHistory,
      lastTimeBonus: bonusSeconds,
    );
    ref.read(soundManagerProvider).updateHeat(newHeat);

    // Record per-answer session stats
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      state!.operation,
      isCorrect,
      timeSpentSeconds,
      hintUsed,
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: state!.operation,
      isCorrect: isCorrect,
      responseTimeMs: timeSpent,
      hintsUsed: hintUsed ? 1 : 0,
      concepts: state!.currentQuestion?.concepts ?? [],
    );
    ref.read(difficulty.dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    if (state!.mode == GameMode.duel) {
      _duelAnswered = true;
      _duelTimer?.cancel();
    }

    _goToNextOrEnd();
  }

  void skipQuestion() {
    if (state == null || state!.currentQuestion == null) return;

    if (!state!.userAnswers.containsKey(state!.currentQuestionIndex)) {
      final newUserAnswers = Map<int, dynamic>.from(state!.userAnswers);
      newUserAnswers[state!.currentQuestionIndex] = null; // null means skipped
      state = state!.copyWith(userAnswers: newUserAnswers);
      ref.read(dailyChallengeProvider.notifier).updateProgressMax('streak', 0);
    }

    _goToNextOrEnd();
  }

  void previousQuestion() {
    if (state != null && state!.currentQuestionIndex > 0) {
      state = state!.copyWith(
        currentQuestionIndex: state!.currentQuestionIndex - 1,
      );
    }
  }

  void useHint() {
    if (state == null || state!.currentQuestion == null) return;

    // Check if user has enough points
    final user = ref.read(userSessionProvider);
    if (user == null || user.totalPoints < hintCostPoints) return;

    final question = state!.currentQuestion!;
    final currentRevealed = state!.revealedHints.length;
    
    if (currentRevealed >= question.progressiveHints.length) return;

    // Deduct points
    ref.read(userSessionProvider.notifier).addPoints(-hintCostPoints);
    ref.read(soundManagerProvider).playEffect('hint');

    final newHintsUsed = Map<int, bool>.from(state!.hintsUsed);
    newHintsUsed[state!.currentQuestionIndex] = true;
    
    final newRevealed = List<String>.from(state!.revealedHints);
    newRevealed.add(question.progressiveHints[currentRevealed]);

    state = state!.copyWith(
      hintsUsed: newHintsUsed,
      revealedHints: newRevealed,
    );
  }

  void _goToNextOrEnd() {
    if (state == null) return;

    final newIndex = state!.currentQuestionIndex + 1;
    VisualCountingData? nextVisualData;
    if (state!.isVisualCounting && newIndex < state!.totalQuestions) {
      nextVisualData = _generateVisualCountingData(state!.level);
    }

    if (newIndex >= state!.totalQuestions || state!.lives <= 0) {
      if (state!.mode == GameMode.duel) {
        final playerWon =
            state!.score > (state!.aiScore ?? 0) ||
            (state!.score == (state!.aiScore ?? 0) &&
                state!.correctAnswers > (state!.aiCorrectAnswers ?? 0));
        state = state!.copyWith(
          currentQuestionIndex: newIndex,
          playerWon: playerWon,
        );
      } else {
        state = state!.copyWith(currentQuestionIndex: newIndex);
      }
      _endGame();
    } else {
      state = state!.copyWith(
        currentQuestionIndex: newIndex,
        currentQuestion: state!.questions[newIndex],
        currentVisualData: nextVisualData,
        revealedHints: [], // Reset revealed hints for next question
      );

      if (state!.mode == GameMode.duel) {
        _processDuelTurn();
      }
    }
  }

  int _getScoreForMode() {
    switch (state?.mode) {
      case GameMode.campaign:
        return 10;
      case GameMode.practice:
        return 5; // Practice now gives a small reward
      case GameMode.scoreAttack:
        final level = state?.level ?? 1;
        return (10 + (level ~/ 5)).clamp(10, 50);
      case GameMode.endless:
        final streak = state?.correctAnswers ?? 0;
        return (10 + (streak ~/ 5) * 5).clamp(10, 100);
      case GameMode.duel:
        return 25;
      case GameMode.flash:
        return 20;
      case GameMode.speedDemon:
        return 30; // high points for speed
      case GameMode.mathMaster:
        return 25;
      case GameMode.marathon:
        return 20;
      default:
        return 10;
    }
  }

  void answerVisualCounting(int answer) {
    if (state == null || state!.currentVisualData == null) return;

    final now = DateTime.now();
    final timeSpent = now.difference(state!.lastAnswerTime!).inMilliseconds.clamp(1, 300000);
    final timeSpentSeconds = (timeSpent / 1000).ceil().clamp(1, 300);

    final isCorrect = answer == state!.currentVisualData!.targetCount;
    int newScore = state!.score;
    int newCorrect = state!.correctAnswers;
    int newLives = state!.lives;
    
    final newResponseTimes = List<int>.from(state!.responseTimes)..add(timeSpent);
    final newCorrectnessHistory = List<bool>.from(state!.correctnessHistory)..add(isCorrect);

    if (isCorrect) {
      ref.read(soundManagerProvider).playCorrect();
      newScore += state!.mode == GameMode.practice ? 5 : 15;
      newCorrect++;
    } else {
      ref.read(soundManagerProvider).playIncorrect();
      if (state!.mode == GameMode.endless) {
        newLives--;
      }
    }

    final newPendingStats = List<Map<String, dynamic>>.from(state!.pendingStats);
    newPendingStats.add({
      'operationId': 'visual_counting',
      'isCorrect': isCorrect,
      'timeSpent': timeSpentSeconds,
    });

    state = state!.copyWith(
      score: newScore,
      correctAnswers: newCorrect,
      lives: newLives,
      pendingStats: newPendingStats,
      lastAnswerTime: now,
      responseTimes: newResponseTimes,
      correctnessHistory: newCorrectnessHistory,
    );

    // Record per-answer session stats
    ref.read(sessionStatsProvider.notifier).recordAnswer(
      'visual_counting',
      isCorrect,
      timeSpentSeconds,
      false,
    );

    // Record for dynamic difficulty
    ref.read(playerPerformanceProvider.notifier).recordAnswer(
      operation: 'visual_counting',
      isCorrect: isCorrect,
      responseTimeMs: timeSpent,
      hintsUsed: 0,
    );
    ref.read(difficulty.dynamicDifficultyProvider.notifier).recordAssessment(isCorrect: isCorrect);

    _goToNextOrEnd();
  }

  VisualCountingData _generateVisualCountingData(int level) {
    final count = MathEngine.generateVisualCount(level);
    final shapes = _generateNonOverlappingShapes(count);
    return VisualCountingData(targetCount: count, shapes: shapes);
  }

  List<ShapeData> _generateNonOverlappingShapes(int count) {
    final shapes = <ShapeData>[];
    final colors = [
      0xFF6366F1, // Indigo
      0xFF22D3EE, // Cyan
      0xFFF472B6, // Pink
      0xFF22C55E, // Green
      0xFFFACC15, // Yellow
      0xFFFB923C, // Orange
      0xFFA855F7, // Purple
    ];
    final types = ['circle', 'triangle', 'star', 'square', 'pentagon', 'diamond'];
    
    // More variety for higher levels
    final level = state?.level ?? 1;
    final activeTypes = level > 40 
        ? types 
        : level > 20 
            ? types.sublist(0, 5) 
            : types.sublist(0, 3);
            
    const containerWidth = 300.0;
    const containerHeight = 300.0;
    const minSize = 25.0;
    const maxSize = 55.0;
    const padding = 8.0;
    const maxAttempts = 150;

    for (int i = 0; i < count; i++) {
      bool placed = false;
      int attempts = 0;

      while (!placed && attempts < maxAttempts) {
        final size = minSize + _random.nextDouble() * (maxSize - minSize);
        final x =
            padding +
            _random.nextDouble() * (containerWidth - size - padding * 2);
        final y =
            padding +
            _random.nextDouble() * (containerHeight - size - padding * 2);

        bool overlaps = false;
        for (final existing in shapes) {
          final dx = (existing.x + existing.size / 2) - (x + size / 2);
          final dy = (existing.y + existing.size / 2) - (y + size / 2);
          final distance = sqrt(dx * dx + dy * dy);
          final minDistance = (existing.size + size) / 2 + padding;

          if (distance < minDistance) {
            overlaps = true;
            break;
          }
        }

        if (!overlaps) {
          shapes.add(
            ShapeData(
              type: activeTypes[_random.nextInt(activeTypes.length)],
              x: x,
              y: y,
              size: size,
              color: colors[_random.nextInt(colors.length)],
            ),
          );
          placed = true;
        }
        attempts++;
      }

      if (!placed) {
        shapes.add(
          ShapeData(
            type: types[_random.nextInt(types.length)],
            x:
                padding +
                _random.nextDouble() * (containerWidth - maxSize - padding * 2),
            y:
                padding +
                _random.nextDouble() *
                    (containerHeight - maxSize - padding * 2),
            size: minSize,
            color: colors[_random.nextInt(colors.length)],
          ),
        );
      }
    }

    return shapes;
  }

  static const int questionsPerLevel = 45;
  static const int correctToPass = 35;

  void _endGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    
    // Clear preload cache when game ends
    GameFlowOptimizer.clearPreloadCache();

    if (state == null) return;

    // Batch update stats
    int? timeToFirstAnswer;
    if (state!.pendingStats.isNotEmpty) {
      final statsRepo = ref.read(statisticsRepositoryProvider);
      
      int sessionTotalTime = 0;
      int sessionCorrect = 0;
      
      for (final stat in state!.pendingStats) {
        sessionTotalTime += stat['timeSpent'] as int;
        if (stat['isCorrect'] as bool) {
          sessionCorrect++;
          timeToFirstAnswer ??= stat['timeSpent'] as int;
        }
        
        statsRepo.updateStatistics(
          operationId: stat['operationId'] as String,
          score: stat['score'] as int,
          isCorrect: stat['isCorrect'] as bool,
          timeSpent: stat['timeSpent'] as int,
          mode: stat['mode'] as String?,
          levelKey: stat['levelKey'] as String?,
          concepts: (stat['concepts'] as List<dynamic>?)?.cast<String>() ?? [],
        );
      }

      // Update Skill Rating based on session performance
      _updateSkillRating(sessionCorrect, state!.totalQuestions, sessionTotalTime);
      
      // Update Performance Trends
      final avgTime = state!.totalQuestions > 0 ? sessionTotalTime / state!.totalQuestions : 0.0;
      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        accuracy: (sessionCorrect / state!.totalQuestions) * 100,
        averageTimeMs: avgTime.toInt(),
        streak: state!.comboMultiplier,
        avgHeatIndex: state!.heatIndex,
        mode: state!.operation,
        timeToFirstAnswer: timeToFirstAnswer,
      );
      ref.read(performanceTrendsProvider.notifier).flush();

      // Refresh real-time providers
      ref.invalidate(overallAccuracyProvider);
      ref.invalidate(totalTimePlayedProvider);
      ref.invalidate(bestStreakProvider);
    }

    final isCampaign = state!.mode == GameMode.campaign;
    final passed = state!.passed;

    if (isCampaign) {
      final stars = state!.stars;

      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      levelProgressRepo.updateStars(
        state!.operation,
        state!.level,
        stars,
        state!.score,
      );

      ref.read(levelProgressProvider.notifier).refreshProgress();

      // Update Daily Challenge for stars
      if (stars > 0) {
        ref.read(dailyChallengeProvider.notifier).incrementProgress('stars', stars);
        
        final achievements = ref.read(achievementDatabaseProvider);
        final achievementNotifier = ref.read(achievementStateProvider.notifier);
        final currentStars = achievementNotifier.getProgress('total_stars');
        achievementNotifier.checkAndUnlock('total_stars', currentStars + stars, achievements);
      }

      if (passed) {
        _unlockNextLevel(state!.operation, state!.level);
        
        int totalReward = state!.score;
        // Boss Level Bonus
        if (state!.isBossLevel) {
          totalReward += 1000; // Large bonus for boss levels
          NotificationService().showAchievementNotification(
            'Chapter Completed!',
            'You\'ve defeated the boss of Level ${state!.level}!',
          );
        }
        
        ref.read(userSessionProvider.notifier).updateUser(
          totalPoints: (ref.read(userSessionProvider)?.totalPoints ?? 0) + totalReward,
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      } else {
         ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      }
    } else {
      if (state!.score > 0) {
        final userNotifier = ref.read(userSessionProvider.notifier);
        userNotifier.updateUser(
          totalPoints: (ref.read(userSessionProvider)?.totalPoints ?? 0) + state!.score,
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      } else {
        ref.read(userSessionProvider.notifier).updateUser(
          lastPlayedMode: state!.mode.name,
          lastPlayedOperation: state!.operation,
          lastPlayedLevel: state!.level,
          lastHeatIndex: state!.heatIndex,
        );
      }

      // Update Daily Challenges for Arcade modes
      final challengeNotifier = ref.read(dailyChallengeProvider.notifier);
      challengeNotifier.incrementProgress('arcade_sessions', 1);
      
      if (state!.mode == GameMode.duel && (state!.playerWon ?? false)) {
        challengeNotifier.incrementProgress('wins', 1);
      }
      
      if (state!.mode == GameMode.endless) {
        challengeNotifier.updateProgressMax('score', state!.score);
      }

      if (state!.totalQuestions > 0) {
        final accuracy = state!.correctAnswers / state!.totalQuestions;
        if (accuracy >= 1.0 && state!.totalQuestions >= 10) {
          challengeNotifier.incrementProgress('accuracy', 1);
        }
      }
    }

    // Record performance trends for completed sessions
    if (state!.totalQuestions > 0) {
      final accuracy = (state!.correctAnswers / state!.totalQuestions) * 100;
      
      // Calculate total session time from pending stats for more accuracy
      int sessionTotalTime = 0;
      for (final stat in state!.pendingStats) {
        sessionTotalTime += stat['timeSpent'] as int;
      }
      
      // Fallback for modes where timer might be used but no pending stats (unlikely)
      final durationSeconds = sessionTotalTime > 0 
          ? sessionTotalTime 
          : (state!.mode == GameMode.scoreAttack || state!.mode == GameMode.speedDemon 
              ? (state!.timeRemaining == 0 ? 60 : 60 - state!.timeRemaining) 
              : (state!.elapsedSeconds > 0 ? state!.elapsedSeconds : 0));
              
      final avgTime = state!.totalQuestions > 0 ? durationSeconds / state!.totalQuestions : 0.0;
      final hintsUsed = state!.hintsUsed.values.where((used) => used).length;

      ref.read(performanceTrendsProvider.notifier).addDataPoint(
        accuracy: accuracy,
        averageTimeMs: avgTime.toInt(),
        streak: state!.correctAnswers.toInt(), 
        avgHeatIndex: state!.heatIndex,
      );

      // Check Achievements
      final achievements = ref.read(achievementDatabaseProvider);
      final achievementNotifier = ref.read(achievementStateProvider.notifier);
      
      achievementNotifier.checkAndUnlock('accuracy', accuracy.toInt(), achievements);
      achievementNotifier.checkAndUnlock('speed_run', state!.correctAnswers.toInt(), achievements, timeValue: durationSeconds.toInt());
      achievementNotifier.checkAndUnlock('questions', state!.totalQuestions, achievements);
      achievementNotifier.checkAndUnlock('streak', state!.bestStreak, achievements);
      achievementNotifier.checkAndUnlock('score', state!.score, achievements);
      
      if (accuracy >= 100 && state!.totalQuestions >= 10) {
        achievementNotifier.checkAndUnlock('perfect', 1, achievements);
      }

      if (state!.heatIndex >= 2.5) {
        achievementNotifier.checkAndUnlock('heat', 250, achievements);
      }

      if (avgTime < 2.0 && state!.totalQuestions >= 50) {
        achievementNotifier.checkAndUnlock('avg_time', 50, achievements, timeValue: avgTime.toInt());
      }
      
      if (state!.mode == GameMode.campaign && state!.level == 50 && passed) {
         achievementNotifier.checkAndUnlock('campaign_levels_unlocked', 50, achievements);
      }

      if (state!.mode == GameMode.duel && (state!.playerWon ?? false)) {
        final currentWins = achievementNotifier.getProgress('duel_wins');
        achievementNotifier.checkAndUnlock('duel_wins', currentWins + 1, achievements);
      }

      // Unify analytics recording
      ref.read(analyticsProvider.notifier).recordSession(
        state!.operation,
        durationSeconds.toInt(),
        state!.totalQuestions,
        state!.correctAnswers.toInt(),
        hintsUsed,
        mode: state!.mode.name,
        timeToFirstAnswer: timeToFirstAnswer,
      );
    }

    state = state!.copyWith(
      state: GameState.finished,
      playerWon: passed,
    );
  }

  void _unlockNextLevel(String operation, int currentLevel) {
    try {
      final levelProgressRepo = ref.read(levelProgressRepositoryProvider);
      final nextLevel = currentLevel + 1;
      
      if (nextLevel <= 100) {
        levelProgressRepo.unlockLevel(operation, nextLevel);
      }
    } catch (e) {
      // Repository might not be initialized yet
    }
  }

  void _updateSkillRating(int correct, int total, int totalTime) {
    if (total == 0) return;
    
    final user = ref.read(userSessionProvider);
    if (user == null) return;

    final accuracy = correct / total;
    final avgTime = totalTime / total;
    
    // Skill rating logic:
    // Base gain/loss from accuracy
    double delta = (accuracy - 0.7) * 50; 
    
    // Time-based adjustment (bonus for speed)
    if (accuracy > 0.8) {
      if (avgTime < 3.0) {
        delta += 15;
      } else if (avgTime < 5.0) {
        delta += 10;
      } else if (avgTime > 10.0) {
        delta -= 5;
      }
    }

    // Heat Bonus: If the player sustained high heat, give a rating boost
    if (state != null && state!.heatIndex > 2.0) {
      delta += (state!.heatIndex - 2.0) * 20;
    }

    final newRating = (user.skillRating + delta).toInt().clamp(100, 3000);
    ref.read(userSessionProvider.notifier).updateUser(skillRating: newRating);
  }

  void pauseGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    if (state != null) {
      state = state!.copyWith(state: GameState.paused);
    }
  }

  void resumeGame() {
    if (state != null) {
      state = state!.copyWith(state: GameState.playing);
      if (state!.mode == GameMode.scoreAttack ||
          state!.mode == GameMode.speedDemon ||
          state!.mode == GameMode.flash ||
          state!.mode == GameMode.campaign ||
          state!.mode == GameMode.practice ||
          (state!.mode == GameMode.customMix && state!.timeRemaining > 0) ||
          (state!.mode == GameMode.customMix && state!.customMixMode == CustomMixMode.zen)) {
        _startTimer();
      } else if (state!.mode == GameMode.duel) {
        _processDuelTurn();
      }
    }
  }

  void endGame() {
    _timer?.cancel();
    _duelTimer?.cancel();
    state = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _duelTimer?.cancel();
    super.dispose();
  }
}
