import 'package:flutter/material.dart';

void main() => runApp(const _PreviewApp());

class _PreviewApp extends StatelessWidget {
  const _PreviewApp();
  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
}

// ── Brand colors ─────────────────────────────
class _Colors {
  static const navy   = Color(0xFF1B2B8F);
  static const purple = Color(0xFF8B1FA8);
  static const yellow = Color(0xFFF5D800);
  static const pink   = Color(0xFFF050A0);
}

// ── SplashScreen ─────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;

  late final AnimationController _taglineCtrl;
  late final Animation<double> _taglineOpacity;
  late final Animation<Offset> _taglineSlide;

  late final AnimationController _dotsCtrl;
  late final Animation<double> _dotsOpacity;

  late final AnimationController _versionCtrl;
  late final Animation<double> _versionOpacity;

  late final AnimationController _blobCtrl;
  late final Animation<double> _blobOpacity;

  @override
  void initState() {
    super.initState();

    _blobCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _blobOpacity = CurvedAnimation(parent: _blobCtrl, curve: Curves.easeIn);

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _logoCtrl.forward();
    });

    _taglineCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));
    _taglineSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
            CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 1150), () {
      if (mounted) _taglineCtrl.forward();
    });

    _dotsCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _dotsCtrl, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 1700), () {
      if (mounted) _dotsCtrl.forward();
    });

    _versionCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _versionOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _versionCtrl, curve: Curves.easeIn));
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _versionCtrl.forward();
    });

    
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  void dispose() {
    _blobCtrl.dispose();
    _logoCtrl.dispose();
    _taglineCtrl.dispose();
    _dotsCtrl.dispose();
    _versionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _blobOpacity,
            child: const _BlobBackground(),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, _) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: Image.asset(
                        'assets/images/LogoPmob.jpeg',
                        width: 160,
                        height: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineOpacity,
                    child: Text(
                      'Jadi Juara Bukan Sekedar Mimpi!',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 52),
                FadeTransition(
                  opacity: _dotsOpacity,
                  child: const _BouncingDots(),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _versionOpacity,
              child: Text(
                'v1.0.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  color: Colors.grey[350],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Blob background ───────────────────────────
class _BlobBackground extends StatelessWidget {
  const _BlobBackground(); 

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -120,
          left: -120,
          child: _blob(480, const Color(0xFFDDE4FF)),
        ),
        Positioned(
          bottom: -80,
          right: -80,
          child: _blob(360, const Color(0xFFF9D8F9)),
        ),
        Positioned(
          bottom: 60,
          left: 40,
          child: _blob(220, const Color(0xFFFFFBCC)),
        ),
      ],
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color,
                blurRadius: 90,
                spreadRadius: 60,
              )
            ],
          ),
          
        ),
      );
}

// ── Bouncing dots ─────────────────────────────
class _BouncingDots extends StatefulWidget {
  const _BouncingDots(); 

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  final List<Color> _colors = const [
    _Colors.navy,
    _Colors.yellow,
    _Colors.purple,
    _Colors.pink,
  ];

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1100),
      )..repeat(reverse: true),
    );

    _animations = List.generate(
      4,
      (i) {
        final delay = i * 0.18;
        return Tween<double>(begin: 0, end: -12).animate(
          CurvedAnimation(
            parent: _controllers[i],
            curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
                curve: Curves.easeInOut),
          ),
        );
      },
    );

    for (int i = 0; i < 4; i++) {
      Future.delayed(Duration(milliseconds: (i * 180)), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (i) {
        return AnimatedBuilder(
          animation: _controllers[i],
          builder: (_, _) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: _colors[i],
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}