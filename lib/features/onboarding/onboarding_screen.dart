import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers.dart';
import '../../core/sound_manager.dart';
import '../../l10n/generated/app_localizations.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  int _currentPage = 0;

  List<OnboardingPageData> _getPages(AppLocalizations l10n, ThemeData theme) => [
    OnboardingPageData(
      title: 'MATHLAB',
      subtitle: 'CORE SYSTEM',
      description:
          'A gamified adaptive arithmetic system that personalizes math practice with instant feedback and rewarding progression.',
      icon: Icons.calculate_rounded,
      accentColor: theme.colorScheme.primary,
    ),
    OnboardingPageData(
      title: 'ADVENTURE',
      subtitle: 'CAMPAIGN PROGRESSION',
      description:
          'Progress through chapter-based missions, unlock new stages, and build streaks as your skills evolve.',
      icon: Icons.explore_rounded,
      accentColor: theme.colorScheme.error,
    ),
    OnboardingPageData(
      title: 'CHALLENGE',
      subtitle: 'ARCADE + MISSIONS',
      description:
          'Jump into fast arcade modes, complete daily goals, and compete for top scores under pressure.',
      icon: Icons.bolt_rounded,
      accentColor: theme.colorScheme.tertiary,
    ),
    OnboardingPageData(
      title: 'PUZZLES',
      subtitle: 'LOGIC HUB',
      description:
          'Solve crossword clues, arithmetic riddles, number sequences, and logic challenges in a single puzzle hub.',
      icon: Icons.psychology_rounded,
      accentColor: theme.colorScheme.secondary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _nextPage(List<OnboardingPageData> pages) {
    HapticManager.instance.selectionClick();
    SoundManager.instance.playClick();
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    HapticManager.instance.lightImpact();
    SoundManager.instance.playClick();
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(startupProvider.notifier).completeIntro();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(l10n, theme);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Dynamic Mesh Background
          AnimatedBuilder(
            animation: Listenable.merge([_backgroundController, _pageController]),
            builder: (context, child) {
              final page = _pageController.hasClients ? (_pageController.page ?? 0) : 0.0;
              final index = page.floor();
              final nextIndex = (index + 1).clamp(0, pages.length - 1);
              final t = page - index;

              final color1 = Color.lerp(
                pages[index].accentColor,
                pages[nextIndex].accentColor,
                t,
              )!.withValues(alpha: 0.15);

              return CustomPaint(
                painter: _OnboardingMeshPainter(
                  color: color1,
                  progress: _backgroundController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Floating Math Symbols
          ...List.generate(6, (index) => _buildFloatingSymbol(index)),

          PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              HapticManager.instance.lightImpact();
            },
            itemBuilder: (context, index) {
              return _buildPage(pages[index], index);
            },
          ),

          // Top Navigation
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildProgressDots(pages),
                TextButton(
                  onPressed: _skip,
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'SKIP',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          Positioned(
            bottom: 60,
            left: 32,
            right: 32,
            child: _buildMainButton(theme, pages),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDots(List<OnboardingPageData> pages) {
    return Row(
      children: List.generate(
        pages.length,
        (index) => AnimatedContainer(
          duration: 400.ms,
          margin: const EdgeInsets.only(right: 8),
          width: _currentPage == index ? 32 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? pages[_currentPage].accentColor
                : pages[_currentPage].accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              if (_currentPage == index)
                BoxShadow(
                  color: pages[_currentPage].accentColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton(ThemeData theme, List<OnboardingPageData> pages) {
    final accent = pages[_currentPage].accentColor;
    final isLast = _currentPage == pages.length - 1;

    return GestureDetector(
      onTap: () => _nextPage(pages),
      child: AnimatedContainer(
        duration: 400.ms,
        height: 64,
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLast ? 'INITIALIZE SYSTEM' : 'NEXT MODULE',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isLast ? Icons.power_settings_new_rounded : Icons.arrow_forward_ios_rounded,
                size: 18,
                color: accent.computeLuminance() > 0.5 ? Colors.black : Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSymbol(int index) {
    final symbols = ['+', '−', '×', '÷', '∑', '√'];
    final random = math.Random(index);
    final startTop = random.nextDouble() * 800;
    final startLeft = random.nextDouble() * 400;

    return AnimatedBuilder(
      animation: _floatingController,
      builder: (context, child) {
        final offset = math.sin(_floatingController.value * 2 * math.pi + index) * 20;
        return Positioned(
          top: startTop + offset,
          left: startLeft + (index % 2 == 0 ? offset : -offset),
          child: Opacity(
            opacity: 0.05,
            child: Text(
              symbols[index % symbols.length],
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(OnboardingPageData page, int index) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Container
          Container(
            height: 280,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring
                AnimatedBuilder(
                  animation: _backgroundController,
                  builder: (context, child) => Transform.rotate(
                    angle: _backgroundController.value * 2 * math.pi,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: page.accentColor.withValues(alpha: 0.1),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Icon with glow
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.accentColor.withValues(alpha: 0.05),
                    boxShadow: [
                      BoxShadow(
                        color: page.accentColor.withValues(alpha: 0.1),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Icon(
                    page.icon,
                    size: 70,
                    color: page.accentColor,
                  ),
                )
                    .animate(key: ValueKey('icon_$index'))
                    .scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut, duration: 1200.ms)
                    .shimmer(delay: 1500.ms, duration: 2000.ms),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Text Content
          Column(
            children: [
              Text(
                page.title,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: theme.colorScheme.onSurface,
                ),
              )
                  .animate(key: ValueKey('title_$index'))
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: page.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: page.accentColor.withValues(alpha: 0.2)),
                ),
                child: Text(
                  page.subtitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: page.accentColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              )
                  .animate(key: ValueKey('subtitle_$index'))
                  .fadeIn(delay: 200.ms, duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 32),

              Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  height: 1.6,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(key: ValueKey('desc_$index'))
                  .fadeIn(delay: 400.ms, duration: 600.ms),
            ],
          ),
          
          const SizedBox(height: 100), // Space for bottom button
        ],
      ),
    );
  }
}

class _OnboardingMeshPainter extends CustomPainter {
  final Color color;
  final double progress;

  _OnboardingMeshPainter({required this.color, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final center = Offset(
      size.width * (0.5 + 0.1 * math.cos(progress * 2 * math.pi)),
      size.height * (0.5 + 0.1 * math.sin(progress * 2 * math.pi)),
    );

    paint.shader = RadialGradient(
      colors: [color, color.withValues(alpha: 0)],
      stops: const [0.0, 0.8],
    ).createShader(Rect.fromCircle(center: center, radius: size.width * 1.2));
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Add subtle grid
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), gridPaint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OnboardingMeshPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.progress != progress;
}


class OnboardingPageData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color accentColor;

  OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
