import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/game_settings.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../calculator/calculator_screen.dart';
import '../../profile_setup/profile_setup_screen.dart';
import '../../../core/accessibility/accessibility_settings.dart';
import 'avatar_shop_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(userSessionProvider);
    final theme = Theme.of(context);
    final totalStars = ref.watch(totalStarsProvider);
    final completedLevels = ref.watch(completedLevelsProvider);
    final totalTime = ref.watch(totalTimePlayedProvider);
    final accuracy = ref.watch(overallAccuracyProvider);
    final currentLocale = ref.watch(localeProvider);
    final settings = ref.watch(settingsProvider);
    final currentTheme = ref.watch(themeProvider);

    // Show loading if user is not initialized yet
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.isMobile(context) ? 0 : 20,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(context, ref, user, theme, l10n),
                      _buildStats(
                        totalStars,
                        completedLevels,
                        totalTime,
                        accuracy,
                        theme,
                        l10n,
                      ),
                      _buildMenuSection(
                        context,
                        ref,
                        theme,
                        user,
                        currentLocale,
                        currentTheme,
                        settings,
                        l10n,
                      ),
                      _buildAchievementsSection(
                        theme,
                        totalStars,
                        accuracy,
                        totalTime,
                        l10n,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 48), // Spacer to balance the edit button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      l10n.userProfile,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      l10n.systemStatusActive,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileSetupScreen(),
                    ),
                  );
                },
                icon: PremiumGlassOverlay(
                  padding: const EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(
                    Icons.edit,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 20.seconds),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 10.seconds),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _parseColor(context, user?.avatarColor ?? '#00F5FF').withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _parseColor(context, user?.avatarColor ?? '#00F5FF'),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _parseColor(context, user?.avatarColor ?? '#00F5FF').withValues(alpha: 0.3),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getAvatarIcon(user?.avatarShape ?? 'circle'),
                    color: _parseColor(context, user?.avatarColor ?? '#00F5FF'),
                    size: 50,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            user?.name?.toUpperCase() ?? l10n.player,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'LEVEL ${user?.level ?? 1}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                height: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: user?.levelProgress ?? 0,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PremiumGlassOverlay(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            borderRadius: 24,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.stars,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  '${user?.totalPoints ?? 0} PTS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    int totalStars,
    int completedLevels,
    int totalTime,
    double accuracy,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        borderRadius: AppDesignTokens.radiusMedium,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              l10n.stars,
              '$totalStars',
              Icons.star_rounded,
              theme.colorScheme.tertiary,
              theme,
            ),
            _buildStatItem(
              l10n.level,
              '$completedLevels',
              Icons.task_alt_rounded,
              theme.colorScheme.primary,
              theme,
            ),
            _buildStatItem(
              l10n.time,
              '${totalTime}m',
              Icons.timer_outlined,
              theme.colorScheme.primary,
              theme,
            ),
            _buildStatItem(
              l10n.accuracy,
              '${accuracy.toStringAsFixed(0)}%',
              Icons.analytics_outlined,
              theme.colorScheme.secondary,
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    dynamic user,
    AppLocale currentLocale,
    AppThemeType currentTheme,
    GameSettings settings,
    AppLocalizations l10n,
  ) {
    final isMobile = ResponsiveUtils.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.storeAndCustomization, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.storefront_outlined,
            title: l10n.avatarShop,
            subtitle: l10n.unlockNewAvatarsWithPoints,
            color: theme.colorScheme.tertiary,
            theme: theme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AvatarShopScreen()),
              );
            },
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.interface, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.palette_outlined,
            title: l10n.visualTheme,
            subtitle: AppThemes.getThemeName(currentTheme).toUpperCase(),
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () => _showThemeDialog(context, ref, currentTheme, theme),
          ),
          _buildMenuCard(
            icon: Icons.language_outlined,
            title: l10n.language,
            subtitle:
                '${currentLocale.flag} ${currentLocale.nativeName}'.toUpperCase(),
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () => _showLanguageDialog(context, ref, currentLocale),
          ),
          _buildMenuCard(
            icon: Icons.visibility_outlined,
            title: l10n.focusMode,
            subtitle: l10n.focusModeDesc,
            color: theme.colorScheme.primary,
            theme: theme,
            trailing: Switch(
              value: user.isFocusMode,
              onChanged: (value) {
                HapticManager.instance.selectionClick();
                ref.read(userSessionProvider.notifier).setFocusMode(value);
              },
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          _buildMenuCard(
            icon: Icons.auto_awesome_outlined,
            title: l10n.performanceMode,
            subtitle: l10n.performanceModeDesc,
            color: theme.colorScheme.primary,
            theme: theme,
            trailing: Consumer(
              builder: (context, ref, _) {
                final reduceTransparency = ref.watch(
                  accessibilitySettingsProvider.select(
                    (s) => s.reduceTransparency,
                  ),
                );
                return Switch(
                  value: reduceTransparency,
                  onChanged: (value) {
                    ref
                        .read(accessibilitySettingsProvider.notifier)
                        .setReduceTransparency(value);
                  },
                  activeThumbColor: theme.colorScheme.primary,
                );
              },
            ),
          ),
          _buildMenuCard(
            icon: Icons.remove_red_eye_outlined,
            title: l10n.colorBlindModeTitle,
            subtitle: l10n.colorBlindModeDesc,
            color: theme.colorScheme.primary,
            theme: theme,
            onTap: () => _showColorBlindDialog(context, ref, theme, l10n),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.audioAndHaptics, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.notifications_none_outlined,
            title: l10n.notifications,
            subtitle: l10n.pushUpdates,
            color: theme.colorScheme.secondary,
            theme: theme,
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (value) {
                HapticManager.instance.selectionClick();
                ref.read(settingsProvider.notifier).toggleNotifications(value);
              },
              activeThumbColor: theme.colorScheme.secondary,
            ),
          ),
          _buildMenuCard(
            icon: Icons.volume_up_outlined,
            title: l10n.audioOutput,
            subtitle: l10n.sfxAndMusic,
            color: theme.colorScheme.secondary,
            theme: theme,
            trailing: Switch(
              value: settings.soundEnabled,
              onChanged: (value) {
                HapticManager.instance.selectionClick();
                ref.read(settingsProvider.notifier).toggleSound(value);
              },
              activeThumbColor: theme.colorScheme.secondary,
            ),
          ),
          _buildMenuCard(
            icon: Icons.vibration_outlined,
            title: l10n.hapticFeedback,
            subtitle: l10n.tactileResponse,
            color: theme.colorScheme.secondary,
            theme: theme,
            trailing: Switch(
              value: settings.vibrationEnabled,
              onChanged: (value) {
                HapticManager.instance.selectionClick();
                ref.read(settingsProvider.notifier).toggleHaptics(value);
              },
              activeThumbColor: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildSectionHeader(l10n.systemSettings, theme),
          const SizedBox(height: 12),
          _buildMenuCard(
            icon: Icons.calculate_outlined,
            title: l10n.calculator,
            subtitle: l10n.builtInArithmeticTool,
            color: theme.colorScheme.tertiary,
            theme: theme,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalculatorScreen()),
              );
            },
          ),
          _buildMenuCard(
            icon: Icons.analytics_outlined,
            title: l10n.reports,
            subtitle: l10n.performanceAnalytics,
            color: theme.colorScheme.tertiary,
            theme: theme,
            onTap: () {
              ref.read(navigationIndexProvider.notifier).state = 2;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ThemeData theme,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: PremiumCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: AppDesignTokens.radiusMedium,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
    ThemeData theme,
    int totalStars,
    double accuracy,
    int totalTime,
    AppLocalizations l10n,
  ) {
    final achievements = [
      {
        'icon': Icons.star_rounded,
        'title': l10n.stargazer,
        'progress': (totalStars / 50).clamp(0.0, 1.0),
        'color': theme.colorScheme.secondary,
      },
      {
        'icon': Icons.track_changes_rounded,
        'title': l10n.sharpshooter,
        'progress': accuracy / 100.0,
        'color': theme.colorScheme.primary,
      },
      {
        'icon': Icons.timer_outlined,
        'title': l10n.timeLord,
        'progress': (totalTime / 3600).clamp(0.0, 1.0),
        'color': theme.colorScheme.tertiary,
      },
      {
        'icon': Icons.school_rounded,
        'title': l10n.scholar,
        'progress': (totalStars / 120).clamp(0.0, 1.0),
        'color': theme.colorScheme.primary,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(l10n.achievements, theme),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final color = achievement['color'] as Color;
                final progress = achievement['progress'] as double;
                
                return Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 16),
                  child: PremiumCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: color,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          achievement['title'] as String,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: color.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation(color),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    AppLocale currentLocale,
  ) {
    HapticManager.instance.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 24,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
          l10n.language,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppLocale.supportedLocales.map((locale) {
            return ListTile(
              leading: Text(locale.flag, style: const TextStyle(fontSize: 24)),
              title: Text(locale.name),
              subtitle: Text(locale.nativeName),
              selected: currentLocale == locale,
              selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
onTap: () {
                 ref.read(localeProvider.notifier).setLocale(locale);
                 Navigator.pop(context);
                 // Show success feedback
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(
                     content: Text('${AppLocalizations.of(context)?.languageChanged ?? 'Language changed'} ${locale.name}'),
                     duration: const Duration(seconds: 2),
                     backgroundColor: Theme.of(context).colorScheme.primary,
                   ),
                 );
               },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.continueGame),
          ),
        ],
      ),
    ));
  }

  void _showThemeDialog(
    BuildContext context,
    WidgetRef ref,
    AppThemeType currentTheme,
    ThemeData theme,
  ) {
    HapticManager.instance.selectionClick();
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 24,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
          l10n.selectTheme,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeType.values.map((themeType) {
            final isSelected = currentTheme == themeType;
            final themeColor = AppThemes.getThemeColor(themeType);

            return ListTile(
              leading: Icon(
                AppThemes.getThemeIcon(themeType),
                color: isSelected ? theme.colorScheme.primary : themeColor,
              ),
              title: Text(
                AppThemes.getThemeName(themeType),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(AppThemes.getThemeDescription(themeType)),
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                ref.read(themeProvider.notifier).setTheme(themeType);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Theme updated to ${AppThemes.getThemeName(themeType)}',
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: theme.colorScheme.primary,
                  ),
                );
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.continueGame),
          ),
        ],
      ),
    ));
  }

  void _showColorBlindDialog(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    HapticManager.instance.selectionClick();
    final currentMode = ref.read(accessibilitySettingsProvider).colorBlindMode;

    showDialog(
      context: context,
      builder: (context) => PremiumGlassOverlay(
        borderRadius: 24,
        child: AlertDialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.colorBlindModeTitle,
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ColorBlindMode.values.map((mode) {
              final isSelected = currentMode == mode;
              String title;
              switch (mode) {
                case ColorBlindMode.none:
                  title = l10n.colorBlindModeNone;
                  break;
                case ColorBlindMode.protanopia:
                  title = l10n.colorBlindModeProtanopia;
                  break;
                case ColorBlindMode.deuteranopia:
                  title = l10n.colorBlindModeDeuteranopia;
                  break;
                case ColorBlindMode.tritanopia:
                  title = l10n.colorBlindModeTritanopia;
                  break;
              }

              return ListTile(
                title: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                selected: isSelected,
                selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () {
                  ref
                      .read(accessibilitySettingsProvider.notifier)
                      .setColorBlindMode(mode);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.continueGame),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAvatarIcon(String shape) {
    switch (shape) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'triangle':
        return Icons.change_history;
      case 'star':
        return Icons.star;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }

  Color _parseColor(BuildContext context, String colorString) {
    final theme = Theme.of(context);
    try {
      if (colorString.startsWith('#')) {
        return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
      } else {
        return Color(int.parse(colorString));
      }
    } catch (e) {
      return theme.colorScheme.primary; // Default theme primary color
    }
  }
}
