import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  final String? nextRoute;
  final Widget? nextScreen;

  const SplashScreen({
    super.key,
    this.nextRoute,
    this.nextScreen,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _waveController;
  late AnimationController _shimmerController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Wave animation controller (continuous)
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Shimmer animation controller (continuous)
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });

    // Navigate to next screen after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      if (widget.nextScreen != null) {
        // Navigate to the provided widget
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
      } else if (widget.nextRoute != null) {
        // Navigate using named route
        Navigator.of(context).pushReplacementNamed(widget.nextRoute!);
      }
      // If neither is provided, the splash screen stays (you handle navigation elsewhere)
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF011C40), // Deepest Navy
              Color(0xFF023859), // Dark Navy
              Color(0xFF26658C), // Deep Blue
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated wave background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WavePainter(_waveController.value),
                  );
                },
              ),
            ),

            // Floating particles
            ...List.generate(15, (index) {
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return _buildFloatingParticle(index);
                },
              );
            }),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App icon with glow effect
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF54ACBF).withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: const Color(0xFFA7EBF2).withOpacity(0.3),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFA7EBF2), // Light Cyan
                                Color(0xFF54ACBF), // Vibrant Teal
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFA7EBF2).withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_rounded,
                            size: 70,
                            color: Color(0xFF011C40),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // App name with shimmer effect
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: const [
                                  Color(0xFFA7EBF2),
                                  Color(0xFF54ACBF),
                                  Color(0xFFA7EBF2),
                                ],
                                stops: [
                                  _shimmerController.value - 0.3,
                                  _shimmerController.value,
                                  _shimmerController.value + 0.3,
                                ],
                                tileMode: TileMode.mirror,
                              ).createShader(bounds);
                            },
                            child: Text(
                              'Chatify',
                              style: GoogleFonts.inter(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'Connect in Real-Time',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFA7EBF2).withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 60),

                      // Loading indicator
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF54ACBF).withOpacity(0.8),
                          ),
                          backgroundColor:
                          const Color(0xFF26658C).withOpacity(0.3),
                        ),
                      ),
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

  Widget _buildFloatingParticle(int index) {
    final random = math.Random(index);
    final size = 3.0 + random.nextDouble() * 5;
    final startX = random.nextDouble();
    final startY = random.nextDouble();
    final speed = 0.3 + random.nextDouble() * 0.4;

    final progress = (_waveController.value + (index * 0.1)) % 1.0;
    final y = startY + (progress * speed);

    return Positioned(
      left: MediaQuery.of(context).size.width * startX,
      top: MediaQuery.of(context).size.height * (y % 1.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF54ACBF).withOpacity(0.4),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFA7EBF2).withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = const Color(0xFF54ACBF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final paint2 = Paint()
      ..color = const Color(0xFFA7EBF2).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    final path2 = Path();

    // First wave
    path1.moveTo(0, size.height * 0.6);
    for (double i = 0; i <= size.width; i++) {
      path1.lineTo(
        i,
        size.height * 0.6 +
            math.sin((i / size.width * 2 * math.pi) +
                (animationValue * 2 * math.pi)) *
                30,
      );
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    // Second wave
    path2.moveTo(0, size.height * 0.7);
    for (double i = 0; i <= size.width; i++) {
      path2.lineTo(
        i,
        size.height * 0.7 +
            math.sin((i / size.width * 2 * math.pi) +
                (animationValue * 2 * math.pi) +
                math.pi) *
                25,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}