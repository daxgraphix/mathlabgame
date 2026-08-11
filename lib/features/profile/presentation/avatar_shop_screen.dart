import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/providers.dart';
import '../../../core/sound_manager.dart';
import '../../../core/themes/app_themes.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../l10n/generated/app_localizations.dart';

class AvatarShopScreen extends ConsumerWidget {
  const AvatarShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userSessionProvider);
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final theme = Theme.of(context);
    final totalStars = ref.watch(totalStarsProvider);

    final availableAvatars = [
      {'id': 'circle', 'name': 'Circle', 'cost': 0, 'requiredStars': 0, 'requiredLevel': 1, 'icon': Icons.circle, 'rarity': AppRarity.common, 'effect': 'None'},
      {'id': 'square', 'name': 'Square', 'cost': 0, 'requiredStars': 0, 'requiredLevel': 1, 'icon': Icons.square, 'rarity': AppRarity.common, 'effect': 'None'},
      {'id': 'star', 'name': 'Star', 'cost': 0, 'requiredStars': 0, 'requiredLevel': 1, 'icon': Icons.star, 'rarity': AppRarity.common, 'effect': 'None'},
      {'id': 'diamond', 'name': 'Diamond', 'cost': 500, 'requiredStars': 5, 'requiredLevel': 2, 'icon': Icons.diamond, 'rarity': AppRarity.rare, 'effect': 'Glitter'},
      {'id': 'shield', 'name': 'Shield', 'cost': 1000, 'requiredStars': 15, 'requiredLevel': 5, 'icon': Icons.shield, 'rarity': AppRarity.epic, 'effect': 'Shield Aura'},
      {'id': 'ninja', 'name': 'Ninja', 'cost': 5000, 'requiredStars': 30, 'requiredLevel': 10, 'icon': Icons.sports_martial_arts, 'rarity': AppRarity.epic, 'effect': 'Stealth'},
      {'id': 'crown', 'name': 'Crown', 'cost': 2500, 'requiredStars': 50, 'requiredLevel': 15, 'icon': Icons.emoji_events, 'rarity': AppRarity.legendary, 'effect': 'Royal Glow'},
      {'id': 'rocket', 'name': 'Rocket', 'cost': 10000, 'requiredStars': 75, 'requiredLevel': 20, 'icon': Icons.rocket_launch, 'rarity': AppRarity.legendary, 'effect': 'Rocket Trail'},
      {'id': 'dragon', 'name': 'Dragon', 'cost': 20000, 'requiredStars': 100, 'requiredLevel': 25, 'icon': Icons.local_fire_department, 'rarity': AppRarity.mythic, 'effect': 'Fire Breath'},
      {'id': 'phoenix', 'name': 'Phoenix', 'cost': 50000, 'requiredStars': 150, 'requiredLevel': 30, 'icon': Icons.mood, 'rarity': AppRarity.mythic, 'effect': 'Rebirth Flame'},
    ];

    final isMobile = ResponsiveUtils.isMobile(context);
    final crossAxisCount = ResponsiveUtils.getResponsiveGridColumns(context);
    final padding = ResponsiveUtils.getResponsivePadding(context, mobileHorizontal: 16, mobileVertical: 16, tabletHorizontal: 24, tabletVertical: 24);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, user, theme, l10n, totalStars, availableAvatars),
                Expanded(
                  child: GridView.builder(
                    padding: padding,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: isMobile ? 0.85 : 0.9,
                      crossAxisSpacing: isMobile ? 16 : 24,
                      mainAxisSpacing: isMobile ? 16 : 24,
                    ),
                    itemCount: availableAvatars.length,
                    itemBuilder: (context, index) {
                      final avatar = availableAvatars[index];
                      return _buildAvatarCard(context, ref, user, avatar, theme, l10n, totalStars);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user, ThemeData theme, AppLocalizations l10n, int totalStars, List<Map<String, dynamic>> availableAvatars) {
    final canPop = Navigator.canPop(context);
    final lockedCount = availableAvatars.where((a) {
      final isUnlocked = (user.unlockedAvatars ?? []).contains(a['id'] as String) || (a['cost'] as int) == 0;
      return !isUnlocked;
    }).length;

    final isMobile = ResponsiveUtils.isMobile(context);
    
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (canPop)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: theme.colorScheme.onSurface,
                      size: 18,
                    ),
                  ),
                  onPressed: () {
                    HapticManager.instance.selectionClick();
                    Navigator.pop(context);
                  },
                ),
              if (canPop) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.avatarShop.toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: isMobile ? 14 : 18,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '$lockedCount locked • $totalStars stars collected',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: isMobile ? 10 : 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildPointsCounter(user, theme, isMobile),
            ],
          ),
          const SizedBox(height: 24),
          _buildStarsProgressBar(context, user, totalStars, theme, availableAvatars),
        ],
      ),
    );
  }

  Widget _buildPointsCounter(dynamic user, ThemeData theme, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.stars_rounded,
            color: theme.colorScheme.onPrimary,
            size: isMobile ? 20 : 24,
          ),
          const SizedBox(width: 8),
          Text(
            '${user?.totalPoints ?? 0}',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w900,
              fontSize: isMobile ? 18 : 22,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildStarsProgressBar(BuildContext context, dynamic user, int totalStars, ThemeData theme, List<Map<String, dynamic>> availableAvatars) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = ResponsiveUtils.isMobile(context);
    final targetStars = 150; // Total stars needed for final unlock
    final progress = (totalStars / targetStars).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.avatarUnlocks.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '$totalStars / $targetStars STARS',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                letterSpacing: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              height: 14,
              width: (MediaQuery.of(context).size.width - (isMobile ? 40 : 64)) * progress,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
            ).animate().shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.3)),
          ],
        ),
      ],
    );
  }

  Widget _buildAvatarCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    Map<String, dynamic> avatar,
    ThemeData theme,
    AppLocalizations l10n,
    int totalStars,
  ) {
    final isUnlocked =
        (user.unlockedAvatars ?? []).contains(avatar['id'] as String) ||
        (avatar['cost'] as int) == 0;
    final isEquipped = user.avatarShape == avatar['id'];
    final cost = avatar['cost'] as int;
    final requiredStars = avatar['requiredStars'] as int;
    final requiredLevel = avatar['requiredLevel'] as int;
    final hasEnoughStars = totalStars >= requiredStars;
    final hasEnoughLevel = (user.level ?? 1) >= requiredLevel;
    final canAfford = (user.totalPoints ?? 0) >= cost;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          HapticManager.instance.selectionClick();
          if (isUnlocked) {
            if (!isEquipped) {
              ref.read(userSessionProvider.notifier).equipAvatar(avatar['id'] as String);
            }
          } else {
            if (!hasEnoughStars || !hasEnoughLevel) {
              String message = '';
              if (!hasEnoughStars && !hasEnoughLevel) {
                message = l10n.requiresLevelAndStars(requiredLevel, requiredStars);
              } else if (!hasEnoughStars) {
                message = l10n.requiresStarsToUnlock(requiredStars);
              } else {
                message = l10n.requiresLevelToUnlock(requiredLevel);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              return;
            }
            if (canAfford) {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => PremiumGlassOverlay(
                  borderRadius: 24,
                  child: AlertDialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    surfaceTintColor: Colors.transparent,
                    title: Text(l10n.unlockAvatarQuestion),
                  content: Text(l10n.unlockAvatarConfirm(cost, avatar['name'] as String)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(l10n.cancel.toUpperCase()),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(l10n.unlock.toUpperCase()),
                    ),
                  ],
                ),
              ));

              if (confirmed == true) {
                final success = await ref.read(userSessionProvider.notifier).unlockAvatar(
                  avatar['id'] as String,
                  cost,
                  requiredStars,
                  requiredLevel: requiredLevel,
                );
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.avatarUnlocked)),
                  );
                }
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.notEnoughPoints)),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: isEquipped 
                ? theme.colorScheme.primary.withValues(alpha: 0.05)
                : theme.colorScheme.surface.withValues(alpha: 0.3),
            border: Border.all(
              color: isEquipped
                  ? theme.colorScheme.primary
                  : isUnlocked
                      ? theme.colorScheme.outline.withValues(alpha: 0.2)
                      : theme.colorScheme.outline.withValues(alpha: 0.1),
              width: isEquipped ? 2 : 1.5,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: isEquipped
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: RarityUIConfig.getGradient(avatar['rarity'] as AppRarity, theme),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: RarityUIConfig.getColor(avatar['rarity'] as AppRarity, theme).withValues(alpha: 0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            avatar['icon'] as IconData,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        if (!isUnlocked)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                              child: Icon(
                                !hasEnoughStars || !hasEnoughLevel ? Icons.lock_rounded : Icons.lock_open_rounded,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      (avatar['name'] as String).toUpperCase(),
                      style: TextStyle(
                        color: isEquipped
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        fontSize: 12,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    _buildRarityBadge(avatar['rarity'] as AppRarity, theme, context),
                    const SizedBox(height: 8),
                    if (isEquipped)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.equipped.toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      )
                    else if (isUnlocked)
                       Text(
                        l10n.tapToEquip.toUpperCase(),
                        style: TextStyle(
                          color: theme.colorScheme.primary.withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: canAfford
                              ? theme.colorScheme.secondary.withValues(alpha: 0.1)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: canAfford 
                              ? theme.colorScheme.secondary.withValues(alpha: 0.3)
                              : theme.colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.stars_rounded, 
                              size: 10, 
                              color: canAfford ? theme.colorScheme.secondary : theme.colorScheme.outline
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$cost',
                              style: TextStyle(
                                color: canAfford
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.outline,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
    );
  }

  Widget _buildRarityBadge(AppRarity rarity, ThemeData theme, BuildContext context) {
    final color = RarityUIConfig.getColor(rarity, theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        RarityUIConfig.getName(rarity, context).toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
