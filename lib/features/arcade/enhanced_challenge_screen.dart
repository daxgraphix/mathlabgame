import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import '../../core/game_adaptability/adaptive_game_system.dart';
import '../../core/themes/app_themes.dart';
import '../../core/sound_manager.dart';
import '../../core/utils/responsive_utils.dart';
import '../../l10n/generated/app_localizations.dart';
import '../game/logic/game_session_provider.dart';
import '../game/ui/game_screen.dart';

class EnhancedChallengeScreen extends ConsumerStatefulWidget {
  const EnhancedChallengeScreen({super.key});

  @override
  ConsumerState<EnhancedChallengeScreen> createState() =>
      _EnhancedChallengeScreenState();
}

class _EnhancedChallengeScreenState
    extends ConsumerState<EnhancedChallengeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerProfile = ref.watch(playerProfileProvider);
    final allChallenges = ref.watch(dailyChallengeProvider);
    final daily = allChallenges.where((c) => !c.isWeekly).toList();
    final weekly = allChallenges.where((c) => c.isWeekly).toList();
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.5,
                  colors: [
                    theme.colorScheme.tertiary.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(theme, playerProfile, isMobile),
                const SizedBox(height: 8),
                _buildTabSwitcher(theme, isMobile),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildChallengeList(daily, theme, isMobile, padding),
                      _buildChallengeList(weekly, theme, isMobile, padding),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(ThemeData theme, bool isMobile) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 48),
      height: 54,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1),
            tabs: const [
              Tab(text: 'DAILY'),
              Tab(text: 'WEEKLY'),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildHeader(ThemeData theme, PlayerProfile? profile, bool isMobile) {
    return Container(
      padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 20, isMobile ? 16 : 32, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              HapticManager.instance.selectionClick();
              Navigator.pop(context);
            },
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHALLENGES',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    fontSize: isMobile ? 22 : 28,
                  ),
                ),
                Text(
                  'PUSH YOUR LIMITS',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (profile != null) 
            Hero(
              tag: 'skill_badge',
              child: _buildSkillBadge(profile.skillLevel, isMobile),
            ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(PlayerSkillLevel level, bool isMobile) {
    Color color;
    String label;
    switch (level) {
      case PlayerSkillLevel.master: color = Colors.purple; label = 'MASTER'; break;
      case PlayerSkillLevel.advanced: color = Colors.red; label = 'PRO'; break;
      case PlayerSkillLevel.intermediate: color = Colors.blue; label = 'ELITE'; break;
      case PlayerSkillLevel.beginner: color = Colors.green; label = 'ACE'; break;
      case PlayerSkillLevel.novice: color = Colors.grey; label = 'ROOKIE'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_rounded, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeList(List<DailyChallenge> challenges, ThemeData theme, bool isMobile, EdgeInsets padding) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final validChallenges = challenges
        .where((c) => c.expiresAt.isAfter(now))
        .toList();

    if (validChallenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.celebration_rounded, size: 64, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(l10n.allChallengesComplete, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'CHECK BACK LATER FOR NEW MISSIONS',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().scale();
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(padding.left, 16, padding.right, 32),
      physics: const BouncingScrollPhysics(),
      itemCount: validChallenges.length,
      itemBuilder: (context, index) {
        final challenge = validChallenges[index];
        return _buildChallengeCard(challenge, theme, isMobile);
      },
    );
  }

  Widget _buildChallengeCard(DailyChallenge challenge, ThemeData theme, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final progress = challenge.progress;
    final isComplete = challenge.isCompleted;
    final isClaimed = challenge.isClaimed;
    final timeLeft = challenge.expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;
    final minutesLeft = timeLeft.inMinutes % 60;
    final daysLeft = timeLeft.inDays;
    
    final isExpiringSoon = hoursLeft < 3 && !isComplete && !challenge.isWeekly;
    final color = challenge.isWeekly ? theme.colorScheme.secondary : theme.colorScheme.primary;

    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.zero,
      borderColor: isClaimed
          ? theme.colorScheme.outline.withValues(alpha: 0.2)
          : isComplete 
              ? Colors.green.withValues(alpha: 0.5) 
              : isExpiringSoon ? Colors.orange.withValues(alpha: 0.5) : color.withValues(alpha: 0.3),
      child: Opacity(
        opacity: isClaimed ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isClaimed
                          ? [theme.colorScheme.outline, theme.colorScheme.outline.withValues(alpha: 0.7)]
                          : isComplete 
                            ? [Colors.green, Colors.green.withValues(alpha: 0.7)]
                            : [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: (isClaimed ? theme.colorScheme.outline : (isComplete ? Colors.green : color)).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconForType(challenge.type),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title.toUpperCase(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          challenge.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            height: 1.4,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildRewardBadge(challenge.rewardPoints, theme, isClaimed),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          if (isComplete) 
                            Icon(Icons.check_circle_rounded, color: isClaimed ? theme.colorScheme.outline : Colors.green, size: 14),
                          if (isComplete) const SizedBox(width: 4),
                          Text(
                            isClaimed ? 'CLAIMED' : (isComplete ? 'COMPLETED' : '${(progress * 100).toInt()}% READY'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: isClaimed ? theme.colorScheme.outline : (isComplete ? Colors.green : color),
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${challenge.currentValue} / ${challenge.targetValue}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutCubic,
                        height: 10,
                        width: (MediaQuery.of(context).size.width - (isMobile ? 80 : 144)) * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isClaimed
                              ? [theme.colorScheme.outline, theme.colorScheme.outlineVariant]
                              : isComplete 
                                ? [Colors.green, Colors.greenAccent]
                                : [color, theme.colorScheme.secondary],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            if (!isClaimed)
                              BoxShadow(
                                color: (isComplete ? Colors.green : color).withValues(alpha: 0.4),
                                blurRadius: 8,
                              ),
                          ],
                        ),
                      ).animate(target: isComplete && !isClaimed ? 1 : 0).shimmer(duration: 2.seconds),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (isExpiringSoon ? Colors.red : theme.colorScheme.onSurface).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_rounded, 
                          size: 14, 
                          color: isExpiringSoon ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.5)
                        ),
                        const SizedBox(width: 6),
                        Text(
                          challenge.isWeekly
                            ? l10n.timeLeftShort(daysLeft, hoursLeft % 24).toUpperCase()
                            : l10n.timeLeftShort(hoursLeft, minutesLeft).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            color: isExpiringSoon ? Colors.red : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (isComplete && !isClaimed)
                    ElevatedButton(
                      onPressed: () {
                        HapticManager.instance.successPattern();
                        _claimReward(challenge.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: Colors.green.withValues(alpha: 0.4),
                      ),
                      child: const Text('CLAIM REWARD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                    )
                  else if (!isComplete)
                    ElevatedButton(
                      onPressed: () {
                        HapticManager.instance.lightImpact();
                        _startChallengeGame(challenge.type);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                        shadowColor: color.withValues(alpha: 0.4),
                      ),
                      child: const Text('LAUNCH MISSION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.outline,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 100.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildRewardBadge(int points, ThemeData theme, bool isClaimed) {
    final color = isClaimed ? theme.colorScheme.outline : Colors.amber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            '+$points',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'speed': return Icons.speed;
      case 'streak': return Icons.local_fire_department;
      case 'accuracy': return Icons.gps_fixed;
      case 'multiplication': return Icons.close;
      case 'division': return Icons.percent;
      case 'questions': return Icons.quiz;
      case 'correct': return Icons.check_circle;
      case 'arcade_sessions': return Icons.games;
      case 'cross_numbers': return Icons.grid_4x4;
      case 'stars': return Icons.star;
      case 'fever_mode': return Icons.whatshot;
      case 'hints_used': return Icons.lightbulb;
      default: return Icons.extension;
    }
  }

  void _startChallengeGame(String type) {
    final operation = _getOperationForType(type);
    final mode = _getGameModeForType(type);

    ref
        .read(gameSessionProvider.notifier)
        .startGame(
          mode: mode,
          operation: operation,
          level: 5,
          totalQuestions: 15,
        );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen()),
    );
  }

  void _claimReward(String challengeId) {
    ref.read(dailyChallengeProvider.notifier).claimReward(challengeId, ref);
  }

  String _getOperationForType(String type) {
    switch (type) {
      case 'division':
        return 'division';
      case 'multiplication':
        return 'multiplication';
      case 'subtraction':
        return 'subtraction';
      case 'addition':
        return 'addition';
      default:
        return 'addition';
    }
  }

  GameMode _getGameModeForType(String type) {
    switch (type) {
      case 'speed':
        return GameMode.speedDemon;
      case 'streak':
        return GameMode.endless;
      case 'score':
        return GameMode.scoreAttack;
      default:
        return GameMode.campaign;
    }
  }
}
