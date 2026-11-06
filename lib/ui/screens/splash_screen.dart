import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';
import 'menu_screen.dart';

/// Pantalla de bienvenida animada.
///
/// Es corta (2,4 s), se puede saltar con un toque y suena una campanilla
/// positiva. No bloquea el arranque: la app ya esta lista detras.
class SplashScreen extends StatefulWidget {
  /// Crea la pantalla de bienvenida.
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _float;
  Timer? _timer;
  Timer? _chimeTimer;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _chimeTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }
      audioServiceOf(context)?.playSfx(SfxKind.welcome);
    });
    _timer = Timer(const Duration(milliseconds: 2400), _goToMenu);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _chimeTimer?.cancel();
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  void _goToMenu() {
    if (_navigated || !mounted) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 380),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MenuScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logoScale = Tween<double>(begin: 0.55, end: 1).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    final titleFade = CurvedAnimation(
      parent: _entrance,
      curve: const Interval(0.25, 1, curve: Curves.easeOut),
    );

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goToMenu,
        child: Stack(
          children: [
            const Positioned.fill(child: _SplashBackground()),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: logoScale,
                      child: const _LogoCard(),
                    ),
                    const SizedBox(height: 22),
                    FadeTransition(
                      opacity: titleFade,
                      child: const Column(
                        children: [
                          Text(
                            'Pincel',
                            style: TextStyle(
                              color: AppPalette.red,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              height: 0.98,
                              shadows: [
                                Shadow(
                                  color: AppPalette.white,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '& Carreras',
                            style: TextStyle(
                              color: AppPalette.blue,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              height: 1.05,
                              shadows: [
                                Shadow(
                                  color: AppPalette.white,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Pinta, conduce y recoge estrellas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppPalette.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeTransition(
                      opacity: titleFade,
                      child: AnimatedBuilder(
                        animation: _float,
                        builder: (context, child) {
                          final wobble =
                              math.sin(_float.value * math.pi * 2) * 10;
                          return Transform.translate(
                            offset: Offset(wobble, 0),
                            child: child,
                          );
                        },
                        child: const _SplashRoad(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 178,
      height: 178,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: AppPalette.blue, width: 7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 12),
            blurRadius: 24,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      // El mismo logotipo que aparece en el menu de aplicaciones.
      child: Image.asset(
        AssetPaths.appLogo,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const Icon(
          Icons.directions_car_rounded,
          color: AppPalette.red,
          size: 90,
        ),
      ),
    );
  }
}

class _SplashRoad extends StatelessWidget {
  const _SplashRoad();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                color: AppPalette.ink,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 44,
            right: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 5; i++)
                  Container(
                    width: 22,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppPalette.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            child: Image.asset(
              AssetPaths.iconCar,
              width: 54,
              height: 54,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) =>
                  Icon(Icons.directions_car_rounded,
                      color: AppPalette.red, size: 44),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF6E9),
                  Color(0xFFFFE9A8),
                  Color(0xFFBFEAFF),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -60,
          left: -50,
          child: _Blob(
            color: AppPalette.yellow.withValues(alpha: 0.4),
            size: 220,
          ),
        ),
        Positioned(
          bottom: -80,
          right: -60,
          child: _Blob(
            color: AppPalette.pink.withValues(alpha: 0.3),
            size: 260,
          ),
        ),
        Positioned(
          top: 160,
          right: -30,
          child: _Blob(
            color: AppPalette.cyan.withValues(alpha: 0.3),
            size: 150,
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
