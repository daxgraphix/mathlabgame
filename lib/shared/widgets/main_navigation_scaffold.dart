import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/themes/app_themes.dart';
import '../../core/sound_manager.dart';
import '../../core/providers.dart';
import '../../core/utils/game_flow_optimizer.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/arcade/presentation/arcade_screen.dart';
import '../../features/reports/reports_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _meshController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Start idle monitoring for proactive pre-calculation
    GameFlowOptimizer.startIdleMonitoring(ref);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameFlowOptimizer.stopIdleMonitoring();
    _meshController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      GameFlowOptimizer.stopIdleMonitoring();
    } else if (state == AppLifecycleState.resumed) {
      GameFlowOptimizer.startIdleMonitoring(ref);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final List<Widget> screens = [
      const HomeScreen(),
      const ArcadeScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: Stack(
        children: [
          // Global Background Mesh
          Positioned.fill(
            child: _buildGlobalBackground(theme),
          ),
          // Screens with Tab Transition
          Consumer(
            builder: (context, ref, child) {
              final currentIndex = ref.watch(navigationIndexProvider);
              return IndexedStack(
                index: currentIndex,
                children: screens.asMap().entries.map((entry) {
                  final index = entry.key;
                  final screen = entry.value;
                  return screen.animate(
                    key: ValueKey('tab_$index'),
                    target: currentIndex == index ? 1 : 0,
                  )
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                  .slideX(begin: 0.02, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
                }).toList(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, child) {
          final currentIndex = ref.watch(navigationIndexProvider);
          return _buildUnifiedBottomNav(context, ref, theme, l10n, currentIndex);
        },
      ),
    );
  }

  Widget _buildGlobalBackground(ThemeData theme) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _meshController,
        builder: (context, child) {
          return CustomPaint(
            painter: _MeshPainter(
              color1: theme.colorScheme.primary.withValues(alpha: 0.15),
              color2: theme.colorScheme.secondary.withValues(alpha: 0.1),
              progress: _meshController.value,
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnifiedBottomNav(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    AppLocalizations l10n,
    int currentIndex,
  ) {
    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: PremiumGlassOverlay(
          padding: EdgeInsets.zero,
          borderRadius: 24,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(ref, 0, Icons.home_rounded, Icons.home_outlined, l10n.home, currentIndex, theme),
                _buildNavItem(ref, 1, Icons.sports_esports_rounded, Icons.sports_esports_outlined, l10n.arcade, currentIndex, theme),
                _buildNavItem(ref, 2, Icons.bar_chart_rounded, Icons.bar_chart_outlined, l10n.stats, currentIndex, theme),
                _buildNavItem(ref, 3, Icons.person_rounded, Icons.person_outline_rounded, l10n.profile, currentIndex, theme),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(
    WidgetRef ref,
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int currentIndex,
    ThemeData theme,
  ) {
    final isSelected = currentIndex == index;
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5);

    return InkWell(
      onTap: () {
        if (!isSelected) {
          HapticManager.instance.selectionClick();
          ref.read(soundManagerProvider).playEffect('click');
          ref.read(navigationIndexProvider.notifier).state = index;
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: color,
              size: 26,
            ).animate(target: isSelected ? 1 : 0)
             .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
             .then()
             .shake(hz: 4, offset: const Offset(2, 0)),
            if (isSelected)
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn().slideY(begin: 0.5, end: 0),
          ],
        ),
      ),
    );
  }
}

class _MeshPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double progress;

  _MeshPainter({
    required this.color1,
    required this.color2,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Gradient points with slow movement
    final p1 = Offset(
      size.width * (0.5 + 0.3 * math.cos(progress * 2 * math.pi)),
      size.height * (0.3 + 0.2 * math.sin(progress * 2 * math.pi)),
    );
    
    final p2 = Offset(
      size.width * (0.2 + 0.4 * math.sin(progress * 2 * math.pi + 1)),
      size.height * (0.7 + 0.2 * math.cos(progress * 2 * math.pi + 1)),
    );

    // Draw primary blob
    paint.shader = RadialGradient(
      colors: [color1, color1.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: p1, radius: size.width * 0.8));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw secondary blob
    paint.shader = RadialGradient(
      colors: [color2, color2.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: p2, radius: size.width * 0.6));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _MeshPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color1 != color1 ||
      oldDelegate.color2 != color2;
}
