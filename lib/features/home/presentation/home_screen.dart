import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/sound_manager.dart';
import '../../../core/providers.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../profile/presentation/avatar_shop_screen.dart';
import '../../campaign/presentation/campaign_screen.dart';
import '../../game/logic/game_session_provider.dart';
import '../../arcade/presentation/arcade_screen.dart';
import '../../arcade/enhanced_challenge_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../calculator/calculator_screen.dart';
import '../../custom_mix/presentation/custom_mix_screen.dart';
import '../../puzzle/math_riddle/math_riddle_level_selection_screen.dart';
import '../../puzzle/cross_numbers/cross_numbers_level_selection_screen.dart';
import '../../game/ui/game_screen.dart';
import '../../game/logic/session_stats_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _cardAnimationController.forward();

    // Load level progress and check daily challenges
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(levelProgressProvider.notifier).loadProgress();
      ref.read(dailyChallengeProvider.notifier).checkAndResetChallenges();
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userSessionProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final completedLevels = ref.watch(completedLevelsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);
    final accuracy = ref.watch(overallAccuracyProvider);
    final sessionStats = ref.watch(sessionStatsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Let MainNavigationScaffold handle background
      body: _buildAdvancedBody(
        theme, 
        user, 
        totalStars, 
        completedLevels, 
        totalTime, 
        accuracy, 
        sessionStats, 
        l10n,
      ),
    );
  }

  Widget _buildChallengeSection(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final allChallenges = ref.watch(dailyChallengeProvider);
        final dailyChallenges = allChallenges.where((c) => !c.isWeekly).toList();
        final weeklyChallenges = allChallenges.where((c) => c.isWeekly).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.dailyChallenge,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToScreen(const EnhancedChallengeScreen()),
                  child: Text(l10n.viewAll),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (dailyChallenges.isNotEmpty)
              _buildChallengeCard(dailyChallenges.first, theme, l10n),
            if (weeklyChallenges.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                l10n.weeklyChallenges,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildChallengeCard(weeklyChallenges.first, theme, l10n, isWeekly: true),
            ],
          ],
        );
      },
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, ThemeData theme, AppLocalizations l10n, {bool isWeekly = false}) {
    final hoursLeft = challenge.expiresAt.difference(DateTime.now()).inHours;
    final minutesLeft = challenge.expiresAt.difference(DateTime.now()).inMinutes % 60;
    final color = isWeekly ? theme.colorScheme.secondary : theme.colorScheme.tertiary;
    final isMobile = ResponsiveUtils.isMobile(context);

    return PremiumCard(
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      borderColor: color.withValues(alpha: 0.4),
      onTap: () => _navigateToScreen(const EnhancedChallengeScreen()),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isWeekly ? Icons.auto_awesome : Icons.calendar_today,
                      color: color,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 20),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      (isWeekly ? l10n.weeklyChallenges : l10n.dailyChallenge).toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 10),
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  challenge.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 8,
                    backgroundColor: color.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${challenge.currentValue} / ${challenge.targetValue}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      isWeekly 
                        ? l10n.timeLeftShort(hoursLeft ~/ 24, hoursLeft % 24)
                        : l10n.timeLeftShort(hoursLeft, minutesLeft),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 11),
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right, 
              color: color,
              size: ResponsiveUtils.getResponsiveIconSize(context, 24),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildStreakIndicator(ThemeData theme) {
    return Consumer(
      builder: (context, ref, child) {
        final streak = ref.watch(bestStreakProvider);
        if (streak == 0) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.tertiary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: theme.colorScheme.tertiary,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '$streak',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
        ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildLanguageToggle(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final currentLocale = ref.watch(localeProvider);
        return IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              currentLocale.flag,
              key: ValueKey(currentLocale.flag),
              style: const TextStyle(fontSize: 20),
            ),
          ),
          tooltip: l10n.switchLanguage,
          onPressed: () {
            HapticManager.instance.selectionClick();
            ref.read(soundManagerProvider).playEffect('click');
            ref.read(localeProvider.notifier).toggleLanguage();
            final newLocale = ref.read(localeProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${l10n.switchedTo} ${newLocale.name}'),
                duration: const Duration(seconds: 1),
                backgroundColor: theme.colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAdvancedBody(
    ThemeData theme,
    dynamic user,
    int totalStars,
    int completedLevels,
    int totalTime,
    double accuracy,
    SessionStats sessionStats,
    AppLocalizations l10n,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(context);
    final topPadding = MediaQuery.of(context).padding.top;
    
    // Calculate horizontal padding based on screen width
    final double horizontalPadding = screenWidth > 1200 
        ? (screenWidth - 1000) / 2 
        : (isMobile ? 16 : 32);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding + 20,
              horizontalPadding,
              120,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(theme, l10n),
                const SizedBox(height: 32),
                _buildWelcomeSection(theme, l10n),
                const SizedBox(height: 40),
                _buildChallengeSection(theme, l10n),
                const SizedBox(height: 40),
                _buildGameModesGrid(theme, l10n),
                const SizedBox(height: 40),
                _buildSessionStats(theme, sessionStats, l10n),
                const SizedBox(height: 32),
                _buildQuickActions(theme, l10n),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.bolt_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.commandCenter,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: theme.colorScheme.primary,
                  fontSize: 10,
                ),
              ),
              Text(
                l10n.welcomeBack,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        _buildStreakIndicator(theme),
        const SizedBox(width: 8),
        _buildLanguageToggle(theme, l10n),
      ],
    );
  }






  Widget _buildWelcomeSection(ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(userSessionProvider);
        if (user == null) return const SizedBox.shrink();

        final String? lastMode = user.lastPlayedMode;
        final String? lastOp = user.lastPlayedOperation;
        final int? lastLevel = user.lastPlayedLevel;
        final double? lastHeat = user.lastHeatIndex;
        
        final isMobile = ResponsiveUtils.isMobile(context);

        String quickResumeSubtitle = '';
        
        // Heat Intensity Tag
        Widget? heatTag;
        if (lastHeat != null && lastHeat > 1.2) {
           heatTag = Container(
             margin: const EdgeInsets.only(top: 8),
             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
             decoration: BoxDecoration(
               color: Colors.orange.withValues(alpha: 0.1),
               borderRadius: BorderRadius.circular(6),
               border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
             ),
             child: Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 const Icon(Icons.local_fire_department, color: Colors.orange, size: 12),
                 const SizedBox(width: 4),
                 Text(
                   '${l10n.engineIntensity.toUpperCase()}: ${(lastHeat * 100).toInt()}%',
                   style: const TextStyle(color: Colors.orange, fontSize: 10, fontWeight: FontWeight.w900),
                 ),
               ],
             ),
           );
        }

        if (lastMode != null && lastOp != null) {
          if (lastMode == 'campaign') {
            quickResumeSubtitle = '${lastOp.toUpperCase()} ${l10n.levelUppercase(lastLevel ?? 1)}';
          } else {
            String modeTitle = lastMode.toUpperCase();
            if (lastMode == 'scoreAttack') modeTitle = l10n.scoreAttack;
            if (lastMode == 'endless') modeTitle = l10n.endless;
            if (lastMode == 'duel') modeTitle = l10n.duel;
            if (lastMode == 'flash') modeTitle = l10n.flash;
            if (lastMode == 'speedDemon') modeTitle = l10n.speedDemon;
            if (lastMode == 'mathMaster') modeTitle = l10n.mathMaster;
            if (lastMode == 'marathon') modeTitle = l10n.marathon;
            if (lastMode == 'practice') modeTitle = l10n.practice;
            if (lastMode == 'custommix') modeTitle = l10n.customMix;
            
            quickResumeSubtitle = '$modeTitle - ${lastOp.toUpperCase()}';
          }
        }

        return PremiumGlassOverlay(
          padding: EdgeInsets.all(isMobile ? 20 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${l10n.welcomeBack}, ${user.name}!',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                l10n.levelUppercase(user.level),
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${user.totalPoints} PTS',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Hero(
                    tag: 'app_logo_icon',
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.2),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _buildAvatarPlaceholder(user, theme),
                      ),
                    ),
                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.2))
                      .moveY(begin: -2, end: 2, duration: 1500.ms, curve: Curves.easeInOut),
                ],
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(user.levelProgress * 100).toInt()}% ${l10n.ptsToLevel(user.pointsToNextLevel, user.level + 1)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        '${user.pointsToNextLevel} XP LEFT',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      children: [
                        Container(
                          height: 12,
                          width: double.infinity,
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                        FractionallySizedBox(
                          widthFactor: user.levelProgress,
                          child: Container(
                            height: 12,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                              ),
                            ),
                          ),
                        ).animate().shimmer(duration: 1500.ms),
                      ],
                    ),
                  ),
                ],
              ),
              if (quickResumeSubtitle.isNotEmpty) ...[
                const SizedBox(height: 24),
                Divider(color: theme.colorScheme.onSurface.withValues(alpha: 0.1)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () {
                     if (lastMode == 'campaign' && lastOp != null && lastLevel != null) {
                      ref.read(soundManagerProvider).playGameStart();
                      ref.read(gameSessionProvider.notifier).startGame(
                            mode: GameMode.campaign,
                            operation: lastOp,
                            level: lastLevel,
                            totalQuestions: lastLevel > 50 ? 60 : 50,
                          );
                      _navigateToScreen(GameScreen());
                    } else if (lastMode != null && lastOp != null) {
                      final GameMode mode = GameMode.values.firstWhere(
                        (m) => m.name == lastMode,
                        orElse: () => GameMode.campaign,
                      );

                      if (mode != GameMode.campaign) {
                        ref.read(soundManagerProvider).playGameStart();
                        int totalQuestions = 60;
                        int? timeLimit;
                        int level = lastLevel ?? 1;

                        if (mode == GameMode.scoreAttack) {
                          totalQuestions = (200 * (1 + level * 0.05)).round();
                          timeLimit = 90 + (level * 5);
                        } else if (mode == GameMode.speedDemon) {
                          totalQuestions = (35 * (1 + level * 0.05)).round();
                          timeLimit = 45 + (level * 2);
                        } else if (mode == GameMode.endless) {
                          totalQuestions = 1000;
                        } else if (mode == GameMode.mathMaster) {
                          totalQuestions = (100 * (1 + level * 0.05)).round();
                        } else if (mode == GameMode.marathon) {
                          totalQuestions = 500;
                        } else if (mode == GameMode.flash) {
                          totalQuestions = (50 * (1 + level * 0.05)).round();
                          timeLimit = 60 + (level * 3);
                        }

                        ref.read(gameSessionProvider.notifier).startGame(
                          mode: mode,
                          operation: lastOp,
                          level: level,
                          totalQuestions: totalQuestions,
                          timeLimit: timeLimit,
                        );
                        _navigateToScreen(GameScreen());
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.quickResume.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.primary,
                                fontSize: 9,
                              ),
                            ),
                            Text(
                              quickResumeSubtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            heatTag ?? const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              _buildDailyProgressIndicator(theme),
            ],
          ),
        );
      },
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildAvatarPlaceholder(dynamic user, ThemeData theme) {
    if (user == null) {
      return Icon(Icons.person, color: theme.colorScheme.primary, size: 32);
    }
    // In a real app, you'd use the avatarShape and avatarColor
    return Center(
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'P',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  Widget _buildDailyProgressIndicator(ThemeData theme) {
    // Mock daily progress - in real app this would come from user data
    const int dailyGoal = 10;
    const int completedToday = 3;

    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department,
            color: theme.colorScheme.primary,
            size: 16,
          ).animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$completedToday/$dailyGoal',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ).animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideX(begin: 0.2, end: 0),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            height: 4,
            child: LinearProgressIndicator(
              value: completedToday / dailyGoal,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate()
              .fadeIn(duration: 600.ms, delay: 400.ms)
              .scale(begin: const Offset(0, 1), end: const Offset(1, 1), alignment: Alignment.centerLeft),
        ],
      ),
    ).animate()
        .fadeIn(duration: 500.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0);
  }



  Widget _buildSessionStats(ThemeData theme, SessionStats sessionStats, AppLocalizations l10n) {
    if (sessionStats.questionsAnswered == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.todaysSession,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.questionsAnswered}',
                l10n.questions,
                theme.colorScheme.primary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.accuracy.toStringAsFixed(1)}%',
                l10n.accuracy,
                theme.colorScheme.secondary,
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSessionStatCard(
                '${sessionStats.timeSpent ~/ 60}m',
                l10n.time,
                theme.colorScheme.tertiary,
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionStatCard(String value, String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    ).animate()
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
  }

  Widget _buildQuickActions(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                l10n.calculator,
                Icons.calculate,
                theme.colorScheme.primary,
                () => _navigateToScreen(const CalculatorScreen()),
                theme,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                l10n.avatarShop,
                Icons.storefront_rounded,
                theme.colorScheme.secondary,
                () => _navigateToScreen(const AvatarShopScreen()),
                theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed, ThemeData theme) {
    return InkWell(
      onTap: () {
        HapticManager.instance.selectionClick();
        onPressed();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildGameModesGrid(ThemeData theme, AppLocalizations l10n) {
    final isMobile = ResponsiveUtils.isMobile(context);
    final crossAxisCount = ResponsiveUtils.getResponsiveGridColumns(context);
    final double childAspectRatio = isMobile ? 1.2 : 1.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameModes,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final gameModes = [
              {
                'title': l10n.campaign,
                'subtitle': l10n.completeLevelsProgressively,
                'icon': Icons.map,
                'color': theme.colorScheme.primary,
                'screen': const CampaignScreen(),
              },
              {
                'title': l10n.arcade,
                'subtitle': l10n.fastPacedChallenges,
                'icon': Icons.flash_on,
                'color': theme.colorScheme.secondary,
                'screen': const ArcadeScreen(),
              },
              {
                'title': l10n.practice,
                'subtitle': l10n.improveSpecificSkills,
                'icon': Icons.school,
                'color': theme.colorScheme.tertiary,
                'screen': const PracticeScreen(),
              },
              {
                'title': l10n.customMix,
                'subtitle': l10n.createYourOwnChallenges,
                'icon': Icons.shuffle,
                'color': theme.colorScheme.error,
                'screen': const CustomMixScreen(),
              },
              {
                'title': l10n.logicRiddles,
                'subtitle': l10n.solveLogicChallenges,
                'icon': Icons.extension,
                'color': theme.colorScheme.surfaceTint,
                'screen': const MathRiddleLevelSelectionScreen(),
              },
              {
                'title': l10n.crossNumbers,
                'subtitle': l10n.crossNumbersDesc,
                'icon': Icons.grid_4x4_rounded,
                'color': Colors.deepOrange,
                'screen': const CrossNumbersLevelSelectionScreen(),
              },
            ];

            final mode = gameModes[index];
            return _buildGameModeCard(
              mode['title'] as String,
              mode['icon'] as IconData,
              mode['color'] as Color,
              () => _navigateToScreen(mode['screen'] as Widget),
              theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameModeCard(String title, IconData icon, Color color, VoidCallback onPressed, ThemeData theme) {
    return PremiumCard(
      onTap: onPressed,
      padding: EdgeInsets.zero,
      borderColor: color.withValues(alpha: 0.3),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              icon,
              size: 80,
              color: color.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: Hero(
                    tag: 'mode_icon_$title',
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).scale(
      begin: const Offset(0.9, 0.9),
      end: const Offset(1, 1),
      curve: Curves.easeOutBack,
    );
  }







  void _navigateToScreen(Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }


}