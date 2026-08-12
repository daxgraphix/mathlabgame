import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/providers.dart';
import '../../core/themes/app_themes.dart';
import '../../features/game/logic/game_session_provider.dart';
import '../../features/game/logic/session_stats_provider.dart';
import '../../features/game/logic/player_performance_provider.dart';
import '../../features/analytics/analytics_provider.dart';
import '../../features/practice/presentation/practice_screen.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/render_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/accessibility/accessibility_settings.dart';

final filteredPerformanceTrendsProvider = Provider<PerformanceTrends>((ref) {
  final trends = ref.watch(performanceTrendsProvider);
  final filter = ref.watch(reportsFilterProvider);

  if (filter == null) return trends;

  final filteredPoints = trends.dataPoints.where((p) {
    if (p.mode == null) return false;
    return p.mode == filter;
  }).toList();

  return PerformanceTrends(dataPoints: filteredPoints);
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  String _getLocalizedMode(String mode, AppLocalizations l10n) {
    final m = mode.toLowerCase();
    if (m == 'addition') return l10n.addition;
    if (m == 'subtraction') return l10n.subtraction;
    if (m == 'multiplication') return l10n.multiplication;
    if (m == 'division') return l10n.division;
    if (m == 'arcade') return l10n.arcade;
    if (m == 'practice') return l10n.practice;
    if (m == 'campaign') return l10n.campaign;
    if (m == 'mathriddles') return l10n.mathRiddles;
    if (m == 'cross_numbers' || m == 'crossnumbers') return l10n.crossNumbers;
    if (m == 'custommix') return l10n.customMix;
    // Fallback for unexpected mode names: split camelCase and capitalize
    return mode.replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)!}').trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check for session inactivity when opening reports
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionStatsProvider.notifier).checkInactivity();
    });

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final accuracy = ref.watch(overallAccuracyProvider);
    final totalStars = ref.watch(totalStarsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);
    final completedLevels = ref.watch(completedLevelsProvider);

    final isMobile = ResponsiveUtils.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context, theme, l10n, ref),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 20 : 32,
                  24,
                  isMobile ? 20 : 32,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCards(context, theme, totalStars, completedLevels, totalTime, accuracy, l10n)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 32),
                    _buildPerformanceAnalytics(context, theme, l10n)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 100.ms)
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 32),
                    _buildLevelMastery(context, theme, ref, l10n)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 200.ms)
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 32),
                    _buildPerformanceInsights(context, theme, l10n)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 300.ms)
                        .slideY(begin: 0.05, end: 0),
                    const SizedBox(height: 32),
                    _buildChallengesSummary(context, theme, ref, l10n)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideY(begin: 0.05, end: 0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengesSummary(BuildContext context, ThemeData theme, WidgetRef ref, AppLocalizations l10n) {
    final challenges = ref.watch(dailyChallengeProvider);
    final dailyChallenges = challenges.where((c) => !c.isWeekly).toList();
    final weeklyChallenges = challenges.where((c) => c.isWeekly).toList();

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text(
            l10n.challengesSummary,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          PremiumCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChallengeSection(l10n.dailyChallenges, dailyChallenges, theme, l10n),
                const SizedBox(height: 24),
                Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                const SizedBox(height: 24),
                _buildChallengeSection(l10n.weeklyChallenges, weeklyChallenges, theme, l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeSection(String title, List<DailyChallenge> challenges, ThemeData theme, AppLocalizations l10n) {
    final completedCount = challenges.where((c) => c.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '$completedCount / ${challenges.length}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...challenges.map((challenge) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: challenge.isCompleted 
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: challenge.isCompleted 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  challenge.isCompleted ? Icons.check : Icons.circle_outlined,
                  size: 16,
                  color: challenge.isCompleted 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: challenge.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: (challenge.currentValue / challenge.targetValue).clamp(0.0, 1.0),
                        backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          challenge.isCompleted ? theme.colorScheme.primary : theme.colorScheme.secondary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (challenge.isClaimed)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.claimed.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  '${challenge.rewardPoints} pts',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme, AppLocalizations l10n, WidgetRef ref) {
    return AppBar(
      title: Text(l10n.reports),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Navigator.canPop(context) ? IconButton(
        icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ) : null,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: GlassmorphicContainer(
            borderRadius: 12,
            padding: EdgeInsets.zero,
            opacity: 0.1,
            overflowProtected: false,
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showExportOptions(context, ref, l10n),
              tooltip: l10n.exportOptions,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    ThemeData theme,
    int totalStars,
    int completedLevels,
    int totalTime,
    double accuracy,
    AppLocalizations l10n,
  ) {
    final columns = ResponsiveUtils.getResponsiveGridColumns(context);

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.performanceOverview,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - (columns - 1) * 12) / columns;
              
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      context,
                      l10n.starsEarned,
                      totalStars.toString(),
                      Icons.star,
                      theme.colorScheme.primary,
                      theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PracticeScreen(initialOperation: 'mixed')),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      context,
                      l10n.levelsCompleted,
                      completedLevels.toString(),
                      Icons.flag,
                      theme.colorScheme.secondary,
                      theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PracticeScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      context,
                      l10n.accuracy,
                      '${accuracy.toStringAsFixed(1)}%',
                      Icons.trending_up,
                      theme.colorScheme.tertiary,
                      theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PracticeScreen()),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _buildStatCard(
                      context,
                      l10n.timePlayed,
                      '${totalTime ~/ 60}h ${totalTime % 60}m',
                      Icons.timer,
                      theme.colorScheme.error,
                      theme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PracticeScreen()),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, ThemeData theme, {VoidCallback? onTap}) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      borderColor: color.withValues(alpha: 0.3),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 24 : 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.headlineSmall)?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceAnalytics(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final stats = ref.watch(sessionStatsProvider);
        final bestStreak = ref.watch(bestStreakProvider);
        final analytics = ref.watch(analyticsProvider);
        final totalStars = ref.watch(totalStarsProvider);

        final modes = analytics.recentSessions
            .map((s) => s['mode'] as String?)
            .where((m) => m != null)
            .toSet()
            .toList();

        final filter = ref.watch(reportsFilterProvider);
        final displayTrends = ref.watch(filteredPerformanceTrendsProvider);

        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.performanceAnalytics,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  if (modes.isNotEmpty)
                    PopupMenuButton<String?>(
                      initialValue: filter,
                      icon: Icon(
                        Icons.filter_list,
                        color: filter != null ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                      onSelected: (String? mode) {
                        ref.read(reportsFilterProvider.notifier).state = mode;
                      },
                      itemBuilder: (context) => [
                         PopupMenuItem(
                          value: null,
                          child: Text(l10n.allModes),
                        ),
                        ...modes.map((mode) => PopupMenuItem(
                            value: mode,
                            child: Text(_getLocalizedMode(mode!, l10n)),
                          )),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.currentSession.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            filter ?? l10n.allModes,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        _buildMainMetric(l10n.accuracy, '${stats.accuracy.toStringAsFixed(1)}%', Icons.track_changes, Colors.blue, theme),
                        const SizedBox(width: 16),
                        _buildMainMetric(l10n.time, '${stats.timeSpent ~/ 60}m', Icons.timer_outlined, Colors.orange, theme),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.accuracyTrend,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAccuracyChart(context, ref, displayTrends, theme, l10n),
                    const SizedBox(height: 24),
                    Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    const SizedBox(height: 24),
                    Text(
                      l10n.engineIntensity.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(l10n.averageHeat, displayTrends.averageHeat.toStringAsFixed(2), theme),
                        _buildMiniStat(l10n.currentHeat, ref.watch(gameSessionProvider)?.heatIndex.toStringAsFixed(2) ?? '1.00', theme),
                        _buildMiniStat(l10n.maxHeat, displayTrends.heatHistory.isEmpty ? '1.00' : displayTrends.heatHistory.reduce((a, b) => a > b ? a : b).toStringAsFixed(2), theme),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildHeatTrendChart(context, ref, displayTrends, theme, l10n),
                    const SizedBox(height: 24),
                    Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.1)),
                    const SizedBox(height: 24),
                    Text(
                      l10n.realTimeStats.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                         _buildChipStat(l10n.questions, '${stats.questionsAnswered}', Icons.quiz_outlined, theme),
                         _buildChipStat(l10n.correct, '${stats.correctAnswers}', Icons.check_circle_outline, theme),
                         _buildChipStat(l10n.bestStreak, '$bestStreak', Icons.local_fire_department_outlined, theme),
                         _buildChipStat(l10n.starsEarned, '$totalStars', Icons.star_outline, theme),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainMetric(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipStat(String label, String value, IconData icon, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAccuracyChart(BuildContext context, WidgetRef ref, PerformanceTrends trends, ThemeData theme, AppLocalizations l10n) {
    if (trends.accuracyHistory.isEmpty) return const SizedBox.shrink();

    final chartHeight = ResponsiveUtils.isMobile(context) ? 60.0 : 100.0;
    final padding = ResponsiveUtils.getResponsivePadding(context, mobileHorizontal: 0, mobileVertical: 0);

    final spots = trends.accuracyHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    return Padding(
      padding: padding,
      child: SizedBox(
        height: chartHeight,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => (ref.read(accessibilitySettingsProvider).highContrast
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surface).withValues(alpha: 0.95),
                tooltipBorder: BorderSide(
                  color: ref.read(accessibilitySettingsProvider).highContrast
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primary.withValues(alpha: 0.2),
                  width: ref.read(accessibilitySettingsProvider).highContrast ? 2 : 1,
                ),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final index = barSpot.x.toInt();
                    final accuracy = barSpot.y;
                    final timestamp = trends.timestamps.length > index ? trends.timestamps[index] : null;
                    
                    final dateStr = timestamp != null 
                      ? '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}' 
                      : '${l10n.gameSession} ${index + 1}';

                    final isHighContrast = ref.read(accessibilitySettingsProvider).highContrast;

                    return LineTooltipItem(
                      '$dateStr\n${accuracy.toStringAsFixed(1)}%',
                      theme.textTheme.bodySmall!.copyWith(
                        color: isHighContrast ? theme.colorScheme.surface : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            minX: 0,
            maxX: spots.length.toDouble() - 1,
            minY: 0,
            maxY: 105,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.2),
                      theme.colorScheme.primary.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeatTrendChart(BuildContext context, WidgetRef ref, PerformanceTrends trends, ThemeData theme, AppLocalizations l10n) {
    if (trends.heatHistory.isEmpty) return const SizedBox.shrink();

    final chartHeight = ResponsiveUtils.isMobile(context) ? 60.0 : 80.0;
    final padding = ResponsiveUtils.getResponsivePadding(context, mobileHorizontal: 0, mobileVertical: 0);

    final spots = trends.heatHistory.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final minHeat = trends.heatHistory.reduce((a, b) => a < b ? a : b);
    final maxHeat = trends.heatHistory.reduce((a, b) => a > b ? a : b);
    
    // Calculate adaptive Y-axis bounds
    final minY = (minHeat - 0.2).clamp(0.0, 5.0);
    final maxY = (maxHeat + 0.2).clamp(minY + 0.5, 5.0);

    return Padding(
      padding: padding,
      child: SizedBox(
        height: chartHeight,
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (touchedSpot) => (ref.read(accessibilitySettingsProvider).highContrast
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.surface).withValues(alpha: 0.95),
                tooltipBorder: BorderSide(
                  color: ref.read(accessibilitySettingsProvider).highContrast
                      ? theme.colorScheme.surface
                      : theme.colorScheme.error.withValues(alpha: 0.2),
                  width: ref.read(accessibilitySettingsProvider).highContrast ? 2 : 1,
                ),
                getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                  return touchedBarSpots.map((barSpot) {
                    final index = barSpot.x.toInt();
                    final heat = barSpot.y;
                    final timestamp = trends.timestamps.length > index ? trends.timestamps[index] : null;
                    
                    String level;
                    if (heat >= 2.5) {
                      level = l10n.intensityCritical;
                    } else if (heat >= 2.0) {
                      level = l10n.intensityHigh;
                    } else if (heat >= 1.5) {
                      level = l10n.intensityMedium;
                    } else {
                      level = l10n.intensityNormal;
                    }
                    
                    final dateStr = timestamp != null 
                      ? '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}' 
                      : '${l10n.gameSession} ${index + 1}';

                    final isHighContrast = ref.read(accessibilitySettingsProvider).highContrast;

                    return LineTooltipItem(
                      '$dateStr\n${heat.toStringAsFixed(2)}x\n$level',
                      theme.textTheme.bodySmall!.copyWith(
                        color: isHighContrast 
                            ? theme.colorScheme.surface 
                            : (heat >= 2.0 ? theme.colorScheme.error : theme.colorScheme.primary),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    );
                  }).toList();
                },
              ),
            ),
            minX: 0,
            maxX: spots.length.toDouble() - 1,
            minY: minY,
            maxY: maxY,
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: theme.colorScheme.error,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                    radius: 3,
                    color: theme.colorScheme.error,
                    strokeWidth: 0,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.error.withValues(alpha: 0.3),
                      theme.colorScheme.error.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelMastery(
    BuildContext context,
    ThemeData theme,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final analytics = ref.watch(analyticsProvider);
        final progressMap = ref.watch(levelProgressProvider);
        
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.levelMasteryBreakdown,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.progressByCategory.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (progressMap.isNotEmpty) ...[
                      ...progressMap.entries.map((entry) {
                        final operation = entry.key;
                        final levels = entry.value;
                        final completed = levels.where((level) => level.stars > 0).length;
                        final totalStarsEarned = levels.fold<int>(0, (sum, level) => sum + level.stars);
                        final totalLevels = levels.length;
                        final progress = totalLevels > 0 ? completed / totalLevels : 0.0;
                        
                        final localizedOp = _getLocalizedMode(operation, l10n);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PracticeScreen(
                                    initialOperation: operation.toLowerCase(),
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        localizedOp.toUpperCase(),
                                        style: theme.textTheme.labelLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$totalStarsEarned',
                                            style: theme.textTheme.labelLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Stack(
                                    children: [
                                      Container(
                                        height: 8,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.outline.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                      FractionallySizedBox(
                                        widthFactor: progress.clamp(0.05, 1.0),
                                        child: Container(
                                          height: 8,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary,
                                                theme.colorScheme.primary.withValues(alpha: 0.6),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$completed / $totalLevels ${l10n.levelsCompleted.toLowerCase()}',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      Center(
                        child: Text(
                          l10n.noProgressDataAvailable,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Divider(height: 1, color: theme.colorScheme.outline.withValues(alpha: 0.05)),
                    const SizedBox(height: 24),
                    Text(
                      l10n.gameModeDistribution.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...analytics.operationUsage.entries.map((entry) {
                      final mode = entry.key;
                      final count = entry.value;
                      final localizedMode = _getLocalizedMode(mode, l10n);
                      
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(localizedMode.toUpperCase(), style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$count ${l10n.sessions}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPerformanceInsights(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Consumer(
      builder: (context, ref, child) {
        final trends = ref.watch(performanceTrendsProvider);
        final stats = ref.watch(sessionStatsProvider);
        
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.performanceInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildInsightCard(
                      l10n.neuralEfficiencyIndex,
                      trends.neuralEfficiencyIndex.toStringAsFixed(2),
                      Icons.psychology_rounded,
                      Colors.blueAccent,
                      l10n.performanceScore,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      l10n.bestAccuracy,
                      '${trends.peakAccuracy.toStringAsFixed(1)}%',
                      Icons.stars_rounded,
                      Colors.amber,
                      l10n.personalRecordDesc,
                      theme,
                    ),
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      l10n.averageResponseTime,
                      '${stats.timeSpent > 0 && stats.questionsAnswered > 0 
                          ? (stats.timeSpent / stats.questionsAnswered).toStringAsFixed(1) 
                          : '0'}s',
                      Icons.bolt_rounded,
                      Colors.deepPurple,
                      l10n.avgResponseTimeDesc,
                      theme,
                    ),
                    if (trends.averageTimeToFirstAnswer != null) ...[
                      const SizedBox(height: 16),
                      _buildInsightCard(
                        l10n.timeToFirstAnswer,
                        '${trends.averageTimeToFirstAnswer}s',
                        Icons.timer_outlined,
                        Colors.indigo,
                        l10n.timeToFirstAnswerDesc,
                        theme,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildInsightCard(
                      l10n.completionRate,
                      stats.questionsAnswered > 0 
                          ? '${(stats.correctAnswers / stats.questionsAnswered * 100).toStringAsFixed(1)}%'
                          : '0%',
                      Icons.task_alt_rounded,
                      Colors.teal,
                      l10n.completionRateDesc,
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (trends.averageTimeByMode.isNotEmpty)
                _buildModeTimingBreakdown(theme, l10n, trends.averageTimeByMode),
              const SizedBox(height: 24),
              if (trends.timingTrend.length > 1)
                _buildTimingTrendChart(context, theme, l10n, trends.timingTrend),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInsightCard(String label, String value, IconData icon, Color color, String description, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeTimingBreakdown(ThemeData theme, AppLocalizations l10n, Map<String, double> averageTimeByMode) {
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.timingByMode,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          ...averageTimeByMode.entries.map((entry) {
            final modeName = _getLocalizedMode(entry.key, l10n);
            final avgTime = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      modeName,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(
                    '${avgTime.toStringAsFixed(1)}s',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimingTrendChart(BuildContext context, ThemeData theme, AppLocalizations l10n, List<int> timingTrend) {
    if (timingTrend.isEmpty) return const SizedBox.shrink();

    final chartHeight = ResponsiveUtils.isMobile(context) ? 60.0 : 80.0;
    final padding = ResponsiveUtils.getResponsivePadding(context, mobileHorizontal: 0, mobileVertical: 0);

    final spots = timingTrend.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.toDouble());
    }).toList();

    final minTime = timingTrend.reduce((a, b) => a < b ? a : b).toDouble() * 0.8;
    final maxTime = timingTrend.reduce((a, b) => a > b ? a : b).toDouble() * 1.2;

    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.timingTrend,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.areYouGettingFaster,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: padding,
            child: SizedBox(
              height: chartHeight,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (timingTrend.length - 1).toDouble(),
                  minY: minTime,
                  maxY: maxTime,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: theme.colorScheme.secondary,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.secondary.withValues(alpha: 0.2),
                            theme.colorScheme.secondary.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 32,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(
                    Icons.ios_share_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.exportReport,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildExportOption(
              context: context,
              icon: Icons.picture_as_pdf_rounded,
              title: l10n.exportAsPdf,
              subtitle: l10n.generateDetailedPdfReport,
              onTap: () => _shareAsPdf(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.image_rounded,
              title: l10n.shareAsImage,
              subtitle: l10n.captureHighQualityImage,
              onTap: () => _exportAsImage(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.print_rounded,
              title: l10n.printReport,
              subtitle: l10n.sendReportToPrinter,
              onTap: () => _printReport(context, ref, l10n),
              theme: theme,
            ),
            _buildExportOption(
              context: context,
              icon: Icons.save_rounded,
              title: l10n.saveToDevice,
              subtitle: l10n.savePdfToDeviceStorage,
              onTap: () => _saveToDevice(context, ref, l10n),
              theme: theme,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                icon,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportAsImage(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.generatingImage),
          duration: const Duration(seconds: 2),
        ),
      );

      final screenWidth = MediaQuery.of(context).size.width;
      final captureWidth = (screenWidth * 0.9).clamp(300.0, 400.0);

      // Use RenderService for cleaner off-screen rendering
      final image = await RenderService.safeCaptureWithOverlay(
        context,
        _buildReportContentForImage(context, ref, l10n),
        size: Size(captureWidth, 800), // Height is flexible but we provide a base
        pixelRatio: 2.0,
      );

      if (image == null) throw 'Could not generate image';

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mathlab_report_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (!context.mounted) return;

      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.performanceReportTitle,
        subject: l10n.mathLearningProgress,
      );

      Future.delayed(const Duration(seconds: 10), () {
        if (file.existsSync()) file.deleteSync();
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.imageSharedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.imageExportFailed}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildReportContentForImage(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final user = ref.read(userSessionProvider);
    final accuracy = ref.read(overallAccuracyProvider);
    final totalStars = ref.read(totalStarsProvider);
    final trends = ref.read(performanceTrendsProvider);
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.performanceReportTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.generatedOn(DateTime.now().toString().split('.')[0]),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (user != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${l10n.playerLabel}: ${user.name}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildStatCardForImage(l10n.starsEarned, totalStars.toString(), Icons.star, theme.colorScheme.primary, theme),
          const SizedBox(height: 12),
          _buildStatCardForImage(l10n.accuracy, '${accuracy.toStringAsFixed(1)}%', Icons.trending_up, theme.colorScheme.tertiary, theme),
          const SizedBox(height: 12),
          _buildStatCardForImage(l10n.averageHeat, trends.averageHeat.toStringAsFixed(2), Icons.speed, theme.colorScheme.error, theme),
          const SizedBox(height: 12),
          _buildStatCardForImage(l10n.neuralEfficiencyIndex, trends.neuralEfficiencyIndex.toStringAsFixed(2), Icons.psychology_rounded, theme.colorScheme.secondary, theme),
          const SizedBox(height: 24),
          Text(
            'mathlab-math.app',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              letterSpacing: 2,
            ),
          ),
        ],
      );
  }

  Widget _buildStatCardForImage(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printReport(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.preparingDocument),
          duration: const Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pwContext) => _buildPremiumPdfLayout(ref, l10n),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'mathlab_Report_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.documentSentToPrinter),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.printFailed}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  pw.Widget _buildPremiumPdfLayout(WidgetRef ref, AppLocalizations l10n) {
    final user = ref.read(userSessionProvider);
    final accuracy = ref.read(overallAccuracyProvider);
    final totalStars = ref.read(totalStarsProvider);
    final completedLevels = ref.read(completedLevelsProvider);
    final totalTime = ref.read(totalTimePlayedProvider);
    final trends = ref.read(performanceTrendsProvider);
    final bestStreak = ref.read(bestStreakProvider);
    final avgHeat = trends.averageHeat;
    final maxHeat = trends.heatHistory.isEmpty ? 1.0 : trends.heatHistory.reduce((a, b) => a > b ? a : b);

    return pw.Container(
      padding: const pw.EdgeInsets.all(32),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                flex: 3,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'mathlab',
                      style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.indigo600,
                      ),
                    ),
                    pw.Text(
                      l10n.performanceReportTitle,
                      style: pw.TextStyle(
                        fontSize: 14,
                        color: PdfColors.grey700,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 16),
              pw.Expanded(
                flex: 2,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      l10n.generatedOn(DateTime.now().toString().split('.')[0]),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                      textAlign: pw.TextAlign.right,
                    ),
                    if (user != null)
                      pw.Text(
                        '${l10n.playerLabel}: ${user.name}',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 32),
          
          // Overview Card
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  l10n.performanceOverview.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.indigo600,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: _buildPdfStatColumn(l10n.starsEarned, totalStars.toString(), PdfColors.amber700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.levelsCompleted, completedLevels.toString(), PdfColors.green700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.accuracy, '${accuracy.toStringAsFixed(1)}%', PdfColors.blue700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.timePlayed, '${totalTime ~/ 60}h ${totalTime % 60}m', PdfColors.red700)),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // Engine Intensity Card
          pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  l10n.engineIntensity.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red700,
                    letterSpacing: 1.2,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: _buildPdfStatColumn(l10n.heatIndex, avgHeat.toStringAsFixed(2), PdfColors.red700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.maxHeat, maxHeat.toStringAsFixed(2), PdfColors.orange700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.streak, bestStreak.toString(), PdfColors.deepOrange700)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(child: _buildPdfStatColumn(l10n.neuralEfficiencyIndex, trends.neuralEfficiencyIndex.toStringAsFixed(2), PdfColors.purple700)),
                    pw.Expanded(child: _buildPdfStatColumn(l10n.bestAccuracy, '${trends.peakAccuracy.toStringAsFixed(1)}%', PdfColors.amber700)),
                  ],
                ),
              ],
            ),
          ),
          
          pw.Spacer(),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'mathlab-math.app',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
              pw.Text(
                l10n.endOfReport,
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStatColumn(String label, String value, PdfColor color) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 9,
            color: PdfColors.grey600,
          ),
          softWrap: true,
        ),
      ],
    );
  }

  Future<void> _exportAsPDF(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(l10n.generatingPdf),
          duration: const Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pwContext) => _buildPremiumPdfLayout(ref, l10n),
        ),
      );

      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir != null) {
        final fileName = 'mathlab_report_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(await pdf.save());

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.reportSaved(file.path)),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        throw 'Could not access downloads directory';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.reportSaveFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _saveToDevice(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    await _exportAsPDF(context, ref, l10n);
  }

  Future<void> _shareAsPdf(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.preparingPdf),
          duration: const Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context pwContext) => _buildPremiumPdfLayout(ref, l10n),
        ),
      );

      final bytes = await pdf.save();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mathlab_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: l10n.mymathlabProgressReport,
        subject: l10n.performanceReportTitle,
      );

      Future.delayed(const Duration(seconds: 10), () {
        if (file.existsSync()) file.deleteSync();
      });

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pdfSharedSuccessfully),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.shareFailed(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }


}