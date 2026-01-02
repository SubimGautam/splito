import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splito_project/features/auth/presentation/pages/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DBA8A),
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;
  late final Animation<Color?> _colorTween;

  final List<_AnimatedCircle> _circles = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _colorTween = ColorTween(
      begin: const Color(0xFF1DBA8A).withOpacity(0.3),
      end: const Color(0xFF1DBA8A),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Initialize floating circles
    for (int i = 0; i < 8; i++) {
      _circles.add(_AnimatedCircle());
    }

    _controller.forward();

    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SignInScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      body: Stack(
        children: [
          // Animated background circles
          for (int i = 0; i < _circles.length; i++)
            Positioned(
              left: _circles[i].left * size.width,
              top: _circles[i].top * size.height,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(
                      0.0,
                      0.5,
                      curve: Curves.easeInOut,
                    ),
                  ),
                ),
                child: Container(
                  width: _circles[i].size,
                  height: _circles[i].size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1DBA8A)
                        .withOpacity(_circles[i].opacity),
                  ),
                ),
              ),
            ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo container
                ScaleTransition(
                  scale: _scale,
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: isSmallScreen ? 100 : 140,
                          height: isSmallScreen ? 100 : 140,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1DBA8A)
                                    .withOpacity(0.15),
                                blurRadius: 30,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.9,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.9),
                              ],
                            ),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.percent_rounded,
                                  size: isSmallScreen ? 50 : 70,
                                  color: _colorTween.value,
                                ),
                              ),
                              // Animated ring around icon
                              if (_controller.value > 0.7)
                                TweenAnimationBuilder(
                                  duration:
                                      const Duration(milliseconds: 600),
                                  tween: Tween<double>(begin: 0, end: 1),
                                  builder: (_, value, __) {
                                    return CustomPaint(
                                      painter: _RingPainter(
                                        progress: value,
                                        color: const Color(0xFF1DBA8A)
                                            .withOpacity(0.2),
                                      ),
                                      size: Size(
                                        isSmallScreen ? 100 : 140,
                                        isSmallScreen ? 100 : 140,
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Animated text
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(
                        0.5,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      children: [
                        // App name with gradient
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              colors: [
                                const Color(0xFF1DBA8A),
                                const Color(0xFF1DBA8A).withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Splito',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 40 : 48,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              height: 1,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tagline
                        Text(
                          'Split bills effortlessly',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black.withOpacity(0.6),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Animated loading dots
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: const Interval(
                        0.6,
                        1.0,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: _LoadingDots(
                      color: const Color(0xFF1DBA8A),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Floating circle data class
class _AnimatedCircle {
  final double left;
  final double top;
  final double size;
  final double opacity;

  _AnimatedCircle()
      : left = Random().nextDouble(),
        top = Random().nextDouble() * 0.8,
        size = Random().nextDouble() * 40 + 20,
        opacity = Random().nextDouble() * 0.05 + 0.02;
}

// Custom painter for animated ring
class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.8,
      height: size.height * 0.8,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

// Modern loading dots animation
class _LoadingDots extends StatefulWidget {
  final Color color;

  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotController,
          builder: (context, child) {
            final animationValue =
                (_dotController.value * 2 - index * 0.3) % 1.0;
            final scale = 0.7 + 0.6 * (1 - (animationValue - 0.5).abs() * 2);
            final opacity = 0.4 + 0.6 * (1 - (animationValue - 0.5).abs() * 2);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}