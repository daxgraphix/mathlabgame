import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';
import '../../../core/themes/app_themes.dart';
import '../../../core/providers.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/accessibility/accessibility_settings.dart';
import '../../../core/sound_manager.dart';
import '../logic/game_session_provider.dart';

class GameTimer extends ConsumerWidget {
  const GameTimer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final timeRemaining = ref.watch(gameSessionProvider.select((session) => session?.timeRemaining ?? 0));
    final mode = ref.watch(gameSessionProvider.select((session) => session?.mode ?? GameMode.campaign));

    if (timeRemaining <= 0 && mode != GameMode.scoreAttack) {
      return const SizedBox.shrink();
    }

    final color = timeRemaining < 10 ? theme.colorScheme.error : theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'TIME',
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$timeRemaining s',
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (mode == GameMode.scoreAttack || mode == GameMode.speedDemon)
              _TimeBonusIndicator(mode: mode),
          ],
        ),
      ],
    );
  }
}

class _TimeBonusIndicator extends ConsumerWidget {
  final GameMode mode;

  const _TimeBonusIndicator({required this.mode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    if (session == null || session.lastTimeBonus <= 0) return const SizedBox.shrink();

    // Use a unique key to trigger animation reset on every new bonus
    return KeyedSubtree(
      key: ValueKey('${session.currentQuestionIndex}_${session.lastTimeBonus}'),
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        child: Text(
          '+${session.lastTimeBonus}s',
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ).animate().fadeOut(duration: 800.ms, delay: 200.ms).moveY(begin: 0, end: -20),
    );
  }
}

class GameScreen extends ConsumerWidget {
  GameScreen({super.key});

  final _inputProvider = StateProvider.autoDispose<String>((ref) => '');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (session == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (session.state == GameState.finished) {
      return _buildResultsScreen(context, ref, session, theme, l10n);
    }

    return Scaffold(
      backgroundColor: session.feverActive ? Colors.orange.shade50 : theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: session.feverActive ? Colors.orange.shade100 : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showExitConfirmation(context, ref, l10n),
        ),
        title: Text(
          session.mode == GameMode.practice
              ? l10n.practiceMode
              : session.mode == GameMode.campaign
                  ? '${l10n.levelPrefix}${session.level}'
                  : session.mode.name.toUpperCase(),
        ),
        actions: [
          IconButton(
            icon: Icon(session.state == GameState.paused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              if (session.state == GameState.paused) {
                ref.read(gameSessionProvider.notifier).resumeGame();
              } else {
                ref.read(gameSessionProvider.notifier).pauseGame();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(session, theme, l10n),
                const Spacer(),
                _buildQuestionArea(session, theme),
                const Spacer(),
                _buildNumpad(context, ref, theme, session, l10n),
              ],
            ),
          ),
          if (session.state == GameState.paused)
            _buildPauseOverlay(context, ref, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(GameSession session, ThemeData theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Semantics(
                label: '${l10n.score}: ${session.score}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.score,
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${session.score}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                label: 'Engine Intensity: x${session.heatIndex.toStringAsFixed(1)}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'HEAT',
                      style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.whatshot,
                          size: 16,
                          color: session.heatIndex > 2.5 ? Colors.orange : theme.colorScheme.secondary,
                        ),
                        Text(
                          'x${session.heatIndex.toStringAsFixed(1)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: session.heatIndex > 2.5 ? Colors.orange : theme.colorScheme.secondary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.timeRemaining > 0 || session.mode == GameMode.scoreAttack)
            Semantics(
              label: 'Time Remaining: ${session.timeRemaining} seconds',
              child: const GameTimer(),
            ),
          if (session.mode == GameMode.campaign && session.timeTarget != null)
            _buildCampaignTimer(session, theme, l10n),
          if (session.mode == GameMode.practice)
            _buildPracticeTimer(session, theme, l10n),
          Semantics(
            label: 'Combo Streak: x${session.comboMultiplier}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'STREAK',
                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'x${session.comboMultiplier}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignTimer(GameSession session, ThemeData theme, AppLocalizations l10n) {
    final elapsed = session.elapsedSeconds;
    final target = session.timeTarget ?? 1;
    final progress = (elapsed / target).clamp(0.0, 1.0);
    final isOnTrack = progress <= 0.85;
    final isWarning = progress > 0.85 && progress <= 1.0;

    final minutes = elapsed ~/ 60;
    final seconds = elapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    Color statusColor;
    if (isOnTrack) {
      statusColor = Colors.green;
    } else if (isWarning) {
      statusColor = Colors.orange;
    } else {
      statusColor = theme.colorScheme.error;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.time,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              timeString,
              style: theme.textTheme.titleLarge?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              child: FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: statusColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPracticeTimer(GameSession session, ThemeData theme, AppLocalizations l10n) {
    final elapsed = session.elapsedSeconds;
    final minutes = elapsed ~/ 60;
    final seconds = elapsed % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.elapsed,
          style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          timeString,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionArea(GameSession session, ThemeData theme) {
    if (session.isVisualCounting && session.currentVisualData != null) {
      return _buildVisualCountingArea(session, theme);
    }
    if (session.currentQuestion == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          if (session.feverActive)
            Semantics(
              label: 'Fever Mode Active: Double Points',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'FEVER x2',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ).animate(
              onPlay: (controller) {
                if (session.feverActive) {
                  HapticManager.instance.vibrate();
                }
              },
            ).scale().shake(),
          const SizedBox(height: 8),
          Semantics(
            label: 'Question: ${session.currentQuestion!.displayString}',
            child: Text(
              session.currentQuestion!.displayString,
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: session.feverActive ? Colors.deepOrange : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(key: ValueKey(session.currentQuestionIndex)).fadeIn().scale(),
          const SizedBox(height: 24),
          if (session.mode == GameMode.practice)
            Text(
              'Practice Session',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              'Question ${session.currentQuestionIndex + 1} of ${session.totalQuestions}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          if (session.revealedHints.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                session.revealedHints.last,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(),
            ),
        ],
      ),
    );
  }

  Widget _buildVisualCountingArea(GameSession session, ThemeData theme) {
    final data = session.currentVisualData!;
    return GlassmorphicContainer(
      width: 320,
      height: 320,
      borderRadius: 32,
      child: Stack(
        clipBehavior: Clip.none,
        children: data.shapes.map((shape) {
          final color = Color(shape.color);
          return Positioned(
            left: shape.x,
            top: shape.y,
            child: _buildShape(shape).animate(
              onPlay: (controller) => controller.repeat(reverse: true),
            ).move(
              begin: Offset.zero,
              end: Offset(
                sin(shape.x) * 15,
                cos(shape.y) * 15,
              ),
              duration: (2000 + Random(shape.x.toInt()).nextInt(2000)).ms,
              curve: Curves.easeInOutSine,
            ).shimmer(
              duration: 3.seconds,
              color: color.withValues(alpha: 0.3),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShape(ShapeData shape) {
    final color = Color(shape.color);
    final shadowColor = color.withValues(alpha: 0.4);

    Widget shapeWidget;
    switch (shape.type) {
      case 'circle':
        shapeWidget = Container(
          width: shape.size,
          height: shape.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.8),
                color,
              ],
              center: const Alignment(-0.3, -0.3),
            ),
          ),
        );
        break;
      case 'square':
        shapeWidget = Container(
          width: shape.size,
          height: shape.size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(shape.size * 0.2),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
        );
        break;
      case 'triangle':
        shapeWidget = CustomPaint(
          size: Size(shape.size, shape.size),
          painter: _TrianglePainter(color: color, shadowColor: shadowColor),
        );
        break;
      default:
        shapeWidget = Icon(
          Icons.star_rounded,
          color: color,
          size: shape.size,
          shadows: [
            Shadow(
              color: shadowColor,
              blurRadius: 12,
            ),
          ],
        );
    }

    return shapeWidget.animate().scale(
          duration: 600.ms,
          curve: Curves.elasticOut,
          delay: (Random(shape.x.toInt()).nextInt(500)).ms,
        );
  }

  Widget _buildNumpad(BuildContext context, WidgetRef ref, ThemeData theme, GameSession session, AppLocalizations l10n) {
    final isLargeTarget = ref.watch(accessibilitySettingsProvider.select((s) => s.largeTargetMode));

    return Container(
      padding: EdgeInsets.all(isLargeTarget ? 8 : 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInputDisplay(theme, ref),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildNumpadButton(context, ref, '1', theme),
              _buildNumpadButton(context, ref, '2', theme),
              _buildNumpadButton(context, ref, '3', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, '4', theme),
              _buildNumpadButton(context, ref, '5', theme),
              _buildNumpadButton(context, ref, '6', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, '7', theme),
              _buildNumpadButton(context, ref, '8', theme),
              _buildNumpadButton(context, ref, '9', theme),
            ],
          ),
          Row(
            children: [
              _buildNumpadButton(context, ref, 'C', theme, color: theme.colorScheme.error),
              _buildNumpadButton(context, ref, '0', theme),
              _buildNumpadButton(context, ref, 'OK', theme, color: theme.colorScheme.primary),
            ],
          ),
          if (session.mode == GameMode.practice || session.level > 5)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextButton.icon(
                icon: const Icon(Icons.lightbulb_outline, size: 18),
                label: Text('${l10n.getHint} (10 PTS)'),
                onPressed: () => ref.read(gameSessionProvider.notifier).useHint(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(
    BuildContext context,
    WidgetRef ref,
    String label,
    ThemeData theme, {
    Color? color,
  }) {
    final isLargeTarget = ref.watch(accessibilitySettingsProvider.select((s) => s.largeTargetMode));

    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(isLargeTarget ? 2.0 : 4.0),
        child: PremiumAnimatedButton(
          padding: EdgeInsets.symmetric(vertical: isLargeTarget ? 24 : 16),
          backgroundColor: color?.withValues(alpha: 0.1) ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderColor: color ?? theme.colorScheme.outline.withValues(alpha: 0.2),
          onPressed: () {
            HapticManager.instance.lightImpact();
            final currentInput = ref.read(_inputProvider);
            final session = ref.read(gameSessionProvider);
            if (session == null) return;

            if (label == 'C') {
              ref.read(_inputProvider.notifier).state = '';
            } else if (label == 'OK') {
              if (currentInput.isNotEmpty) {
                if (session.isVisualCounting) {
                  ref.read(gameSessionProvider.notifier).answerVisualCounting(int.parse(currentInput));
                } else {
                  ref.read(gameSessionProvider.notifier).answerQuestion(int.parse(currentInput));
                }
                ref.read(_inputProvider.notifier).state = '';
              }
            } else {
              if (currentInput.length < 5) {
                ref.read(_inputProvider.notifier).state = currentInput + label;
              }
            }
          },
          child: Text(
            label,
            style: (isLargeTarget ? theme.textTheme.headlineMedium : theme.textTheme.headlineSmall)?.copyWith(
              color: color ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputDisplay(ThemeData theme, WidgetRef ref) {
    final input = ref.watch(_inputProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        input.isEmpty ? '?' : input,
        textAlign: TextAlign.center,
        style: theme.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: input.isEmpty
              ? theme.colorScheme.onSurface.withValues(alpha: 0.3)
              : theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildResultsScreen(BuildContext context, WidgetRef ref, GameSession session, ThemeData theme, AppLocalizations l10n) {
    final user = ref.watch(userSessionProvider);
    final pointsEarned = session.score;
    final oldLevel = user != null ? ((user.totalPoints - pointsEarned) / 2500).floor() + 1 : 1;
    final newLevel = user?.level ?? 1;
    final didLevelUp = newLevel > oldLevel;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (didLevelUp)
                Text(
                  'LEVEL UP!',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(duration: 2.seconds),
              Text(
                session.passed ? l10n.levelComplete : l10n.gameOver,
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: session.passed ? theme.colorScheme.primary : theme.colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              PremiumCard(
                child: Column(
                  children: [
                    _buildResultRow(l10n.score, '${session.score}', theme),
                    const Divider(),
                    _buildResultRow(l10n.accuracy, '${session.accuracy.toStringAsFixed(1)}%', theme),
                    const Divider(),
                    _buildResultRow('CORRECT', '${session.correctAnswers}/${session.totalQuestions}', theme),
                    const Divider(),
                    _buildResultRow('MAX STREAK', '${session.bestStreak}', theme),
                    const Divider(),
                    _buildResultRow(l10n.averageHeat, 'x${session.heatIndex.toStringAsFixed(2)}', theme),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (user != null)
                Column(
                  children: [
                    Text(
                      'LEVEL $newLevel',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: user.levelProgress,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${user.pointsToNextLevel} pts to next level',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              if (session.mode == GameMode.duel || session.mode == GameMode.campaign)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('CHALLENGE A FRIEND'),
                    onPressed: () => _shareGhostData(session),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: PremiumPrimaryButton(
                  text: l10n.continueText,
                  onPressed: () {
                    ref.read(gameSessionProvider.notifier).endGame();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareGhostData(GameSession session) {
    // In a real app, this would generate a deep link or export a file
    /*
    final data = {
      'score': session.score,
      'times': session.responseTimes,
      'correct': session.pendingStats.map((s) => s['isCorrect'] as bool).toList(),
      'mode': session.mode.name,
      'level': session.level,
      'op': session.operation,
    };
    */
    
    Share.share('I scored ${session.score} in ${session.operation}! Can you beat my ghost? #MathLabChallenge');
  }

  Widget _buildResultRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(BuildContext context, WidgetRef ref, ThemeData theme, AppLocalizations l10n) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.gamePaused.toUpperCase(),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 48),
            PremiumPrimaryButton(
              width: 200,
              text: l10n.resume,
              onPressed: () => ref.read(gameSessionProvider.notifier).resumeGame(),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                minimumSize: const Size(200, 56),
              ),
              onPressed: () => _showExitConfirmation(context, ref, l10n),
              child: Text(l10n.exit),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exitGame),
        content: Text(l10n.exitGameDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Dialog
              ref.read(gameSessionProvider.notifier).endGame();
              Navigator.pop(context); // Game Screen
            },
            child: Text(l10n.exit, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final Color shadowColor;

  _TrianglePainter({required this.color, required this.shadowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawShadow(path, shadowColor, 4.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
