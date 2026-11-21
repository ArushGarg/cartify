import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../products/screens/product_list_screen.dart';
import 'login_screen.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<double> _screenFade;
  late Animation<double> _ringScale;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoController,
          curve: const Interval(0.0, 0.4, curve: Curves.easeIn)),
    );

    _ringScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.easeInOut),
    );

    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textController,
          curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _screenFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    _textController.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    await _fadeOutController.forward();

    if (!mounted) return;
    final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, _) => isLoggedIn
            ? const ProductListScreen()
            : const LoginScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _screenFade,
      builder: (context, child) => Opacity(
        opacity: _screenFade.value,
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F1729), Color(0xFF1A0B2E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              children: [
                // Floating particles
                AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ParticlePainter(
                          _particleController.value),
                      size: Size.infinite,
                    );
                  },
                ),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glowing ring + logo
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) => Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: AnimatedBuilder(
                              animation: _particleController,
                              builder: (context, _) => Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer glow ring
                                  Transform.scale(
                                    scale: _ringScale.value,
                                    child: Container(
                                      width: 140,
                                      height: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppTheme.primary
                                              .withOpacity(0.15),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Inner ring
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primary
                                            .withOpacity(0.25),
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  // Logo container with glow
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E1133),
                                      borderRadius:
                                      BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primary
                                              .withOpacity(0.4),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: SvgPicture.asset(
                                      'assets/logo.svg',
                                      colorFilter: const ColorFilter.mode(
                                        AppTheme.primary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Animated "Cartify" text
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: const Text(
                              'Cartify',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tagline
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) => Opacity(
                          opacity: _taglineOpacity.value,
                          child: const Text(
                            'Shop the way you like',
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
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
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles = List.generate(12, (i) => _Particle(i));

  _ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppTheme.primary.withOpacity(0.4);
    for (final p in particles) {
      final x = size.width * p.x;
      final y = (size.height * p.y + progress * size.height * p.speed) %
          size.height;
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

class _Particle {
  late double x, y, radius, speed;
  _Particle(int seed) {
    final r = Random(seed);
    x = r.nextDouble();
    y = r.nextDouble();
    radius = r.nextDouble() * 2 + 1;
    speed = r.nextDouble() * 0.15 + 0.05;
  }
}