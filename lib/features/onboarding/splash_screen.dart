import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _bgController;
  late final AnimationController _loadingController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 15))..repeat();
    _loadingController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000));

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_mainController);
    
    _logoOpacity = CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOutCubic),
    );

    _mainController.forward();
    _loadingController.forward();
    _boot();
  }

  Future<void> _boot() async {
    final bootStart = DateTime.now();
    
    // Perform any necessary background initialization here
    // SoundManager is already initialized in StartupNotifier, but we can ensure it's ready
    
    final elapsed = DateTime.now().difference(bootStart);
    if (elapsed < const Duration(milliseconds: 3500)) {
      await Future.delayed(const Duration(milliseconds: 3500) - elapsed);
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _bgController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final bg = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Animated Background Mesh
          AnimatedBuilder(
            animation: _bgController,
            builder: (_, child) {
              return CustomPaint(
                painter: _SplashMeshPainter(
                  color1: primary.withValues(alpha: 0.1),
                  color2: secondary.withValues(alpha: 0.05),
                  progress: _bgController.value,
                ),
                size: Size.infinite,
              );
            },
          ),
          
          Center(
            child: AnimatedBuilder(
              animation: _mainController,
              builder: (_, child) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Column(
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [primary, primary.withValues(alpha: 0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.calculate_rounded,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'mathlab',
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              letterSpacing: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'LOGIC • ARITHMETIC • PUZZLES',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Loading Indicator
                  SizedBox(
                    width: 200,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: AnimatedBuilder(
                            animation: _loadingProgress,
                            builder: (context, child) => LinearProgressIndicator(
                              value: _loadingProgress.value,
                              backgroundColor: primary.withValues(alpha: 0.1),
                              valueColor: AlwaysStoppedAnimation<Color>(primary),
                              minHeight: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'INITIALIZING CORE...',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashMeshPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final double progress;

  _SplashMeshPainter({
    required this.color1,
    required this.color2,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    final p1 = Offset(
      size.width * (0.5 + 0.2 * math.cos(progress * 2 * math.pi)),
      size.height * (0.4 + 0.1 * math.sin(progress * 2 * math.pi)),
    );
    
    final p2 = Offset(
      size.width * (0.3 + 0.3 * math.sin(progress * 2 * math.pi + 2)),
      size.height * (0.6 + 0.2 * math.cos(progress * 2 * math.pi + 2)),
    );

    paint.shader = RadialGradient(
      colors: [color1, color1.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: p1, radius: size.width * 0.9));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    paint.shader = RadialGradient(
      colors: [color2, color2.withValues(alpha: 0)],
    ).createShader(Rect.fromCircle(center: p2, radius: size.width * 0.7));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SplashMeshPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
