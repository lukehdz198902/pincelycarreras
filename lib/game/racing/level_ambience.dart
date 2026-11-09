import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import '../../core/constants/palette.dart';
import '../../data/models/level_spec.dart';

/// Capa de particulas que da personalidad a cada nivel.
///
/// Se dibuja con primitivas para no anadir assets: petalos, mariposas,
/// burbujas, globos, luciernagas, estrellas fugaces, confeti, nieve, hojas
/// y chispas. Todas las particulas se reciclan al salir de la pantalla.
class LevelAmbience extends Component {
  /// Crea la capa ambiental del nivel.
  LevelAmbience({required this.kind, required this.seed});

  /// Efecto ambiental del nivel.
  final LevelEffect kind;

  /// Semilla para que cada nivel tenga una distribucion estable.
  final int seed;

  late final math.Random _random = math.Random(seed);
  final List<_Particle> _particles = [];
  Vector2 _size = Vector2.zero();
  bool _spawned = false;

  /// Eje de repulsion de las particulas (a lo largo de la carretera).
  ///
  /// El mundo del juego esta girado 90 grados, asi que el eje "horizontal"
  /// de las particulas es el eje **largo** de la pista.
  double get _spreadExtent => _size.y;

  /// Eje de caida de las particulas (hacia abajo de la pantalla).
  double get _fallExtent => _size.x;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _size = size;
    if (!_spawned) {
      _spawnAll();
      _spawned = true;
    }
  }

  @override
  void update(double dt) {
    if (_size.x <= 0 || _size.y <= 0 || _particles.isEmpty) {
      return;
    }
    for (final particle in _particles) {
      particle.life += dt;
      switch (kind) {
        case LevelEffect.petals:
          particle.y += (18 + particle.size * 2) * dt;
          particle.x +=
              math.sin(particle.life * 1.6 + particle.phase) * 20 * dt;
          particle.angle += dt * 0.8;
        case LevelEffect.butterflies:
          particle.x += particle.vx * dt;
          particle.y += particle.vy * dt +
              math.sin(particle.life * 2.4 + particle.phase) * 16 * dt;
        case LevelEffect.bubbles:
          particle.y -= (22 + particle.size * 2.4) * dt;
          particle.x +=
              math.sin(particle.life * 1.4 + particle.phase) * 10 * dt;
        case LevelEffect.balloons:
          particle.y -= (12 + particle.size * 0.6) * dt;
          particle.x +=
              math.sin(particle.life * 0.8 + particle.phase) * 8 * dt;
        case LevelEffect.fireflies:
          particle.x += particle.vx * dt;
          particle.y += particle.vy * dt;
        case LevelEffect.shootingStars:
          particle.x += particle.vx * dt;
          particle.y += particle.vy * dt;
        case LevelEffect.confetti:
          particle.y += (26 + particle.size * 2) * dt;
          particle.x +=
              math.sin(particle.life * 2 + particle.phase) * 14 * dt;
          particle.angle += particle.spin * dt;
        case LevelEffect.snow:
          particle.y += (14 + particle.size) * dt;
          particle.x +=
              math.sin(particle.life * 0.9 + particle.phase) * 10 * dt;
        case LevelEffect.leaves:
          particle.y += (20 + particle.size * 2) * dt;
          particle.x +=
              math.sin(particle.life * 1.2 + particle.phase) * 24 * dt;
          particle.angle += particle.spin * dt;
        case LevelEffect.sparkles:
          particle.x += particle.vx * dt;
          particle.y += particle.vy * dt;
          particle.angle += particle.spin * dt;
        case LevelEffect.sand:
          particle.x -= (30 + particle.size * 4) * dt;
          particle.y += math.sin(particle.life * 3 + particle.phase) * 14 * dt;
        case LevelEffect.waves:
          particle.y += (26 + particle.size * 3) * dt;
          particle.x += math.sin(particle.life * 1.4 + particle.phase) * 12 * dt;
        case LevelEffect.embers:
          particle.y -= (24 + particle.size * 3) * dt;
          particle.x += math.sin(particle.life * 2 + particle.phase) * 12 * dt;
      }
      _recycle(particle);
    }
  }

  @override
  void render(Canvas canvas) {
    // El mundo del juego esta girado 90 grados para que la pista se vea en
    // horizontal. Aqui se deshace ese giro solo para las particulas, de
    // modo que la nieve cae **hacia abajo** de la pantalla y no hacia el
    // lado.
    canvas.save();
    canvas.translate(0, _size.y);
    canvas.rotate(-math.pi / 2);
    for (final particle in _particles) {
      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.angle);
      _drawParticle(canvas, particle);
      canvas.restore();
    }
    canvas.restore();
  }

  void _drawParticle(Canvas canvas, _Particle particle) {
    final pulse = 0.5 +
        0.5 * math.sin(particle.life * 3 + particle.phase);
    final paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = particle.color;

    switch (kind) {
      case LevelEffect.petals:
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.56,
          ),
          paint,
        );
      case LevelEffect.butterflies:
        final wing = particle.size;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-wing * 0.42, 0),
            width: wing,
            height: wing * 0.72,
          ),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(wing * 0.42, 0),
            width: wing,
            height: wing * 0.72,
          ),
          paint,
        );
        canvas.drawLine(
          Offset(0, -wing * 0.4),
          Offset(0, wing * 0.4),
          Paint()
            ..color = AppPalette.ink.withValues(alpha: 0.75)
            ..strokeWidth = 1.4
            ..strokeCap = StrokeCap.round,
        );
      case LevelEffect.bubbles:
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = particle.color.withValues(alpha: 0.7);
        canvas.drawCircle(Offset.zero, particle.size, paint);
        paint
          ..style = PaintingStyle.fill
          ..color = particle.color.withValues(alpha: 0.25);
        canvas.drawCircle(
          Offset(-particle.size * 0.3, -particle.size * 0.3),
          particle.size * 0.28,
          paint,
        );
      case LevelEffect.balloons:
        paint.color = particle.color;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 1.25,
          ),
          paint,
        );
        canvas.drawLine(
          Offset(0, particle.size * 0.6),
          Offset(0, particle.size * 1.5),
          Paint()
            ..color = AppPalette.ink.withValues(alpha: 0.45)
            ..strokeWidth = 1,
        );
        canvas.drawPath(
          Path()
            ..moveTo(-particle.size * 0.18, particle.size * 0.58)
            ..lineTo(particle.size * 0.18, particle.size * 0.58)
            ..lineTo(0, particle.size * 0.8)
            ..close(),
          paint,
        );
      case LevelEffect.fireflies:
        paint.color = particle.color.withValues(alpha: 0.25 + pulse * 0.35);
        canvas.drawCircle(Offset.zero, particle.size * 2.4, paint);
        paint.color = particle.color.withValues(alpha: 0.75 + pulse * 0.25);
        canvas.drawCircle(Offset.zero, particle.size, paint);
      case LevelEffect.shootingStars:
        final tail = Path()
          ..moveTo(0, 0)
          ..lineTo(particle.size, -particle.size * 0.28)
          ..lineTo(particle.size * 0.2, particle.size * 0.22)
          ..close();
        paint.color = particle.color.withValues(alpha: 0.35);
        canvas.drawPath(tail, paint);
        paint.color = particle.color;
        canvas.drawPath(_starPath(particle.size * 0.45), paint);
      case LevelEffect.confetti:
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size,
            height: particle.size * 0.58,
          ),
          paint,
        );
      case LevelEffect.snow:
        paint.color =
            particle.color.withValues(alpha: 0.55 + pulse * 0.45);
        canvas.drawCircle(Offset.zero, particle.size, paint);
      case LevelEffect.leaves:
        final size = particle.size;
        final leaf = Path()
          ..moveTo(0, -size)
          ..quadraticBezierTo(size * 0.9, -size * 0.2, 0, size)
          ..quadraticBezierTo(-size * 0.9, -size * 0.2, 0, -size)
          ..close();
        canvas.drawPath(leaf, paint);
        canvas.drawLine(
          Offset(0, -size * 0.8),
          Offset(0, size * 0.8),
          Paint()
            ..color = AppPalette.ink.withValues(alpha: 0.25)
            ..strokeWidth = 1,
        );
      case LevelEffect.sparkles:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 2;
        paint.strokeCap = StrokeCap.round;
        paint.color =
            particle.color.withValues(alpha: 0.35 + pulse * 0.65);
        final arm = particle.size * (0.6 + pulse * 0.4);
        canvas.drawLine(Offset(-arm, 0), Offset(arm, 0), paint);
        canvas.drawLine(Offset(0, -arm), Offset(0, arm), paint);
      case LevelEffect.sand:
        paint.color = particle.color.withValues(alpha: 0.45 + pulse * 0.4);
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: particle.size * 1.8,
            height: particle.size * 0.6,
          ),
          paint,
        );
      case LevelEffect.waves:
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = particle.color.withValues(alpha: 0.4 + pulse * 0.45);
        final wave = Path()
          ..moveTo(-particle.size, 0)
          ..quadraticBezierTo(
            -particle.size * 0.5,
            -particle.size * 0.7,
            0,
            0,
          )
          ..quadraticBezierTo(
            particle.size * 0.5,
            particle.size * 0.7,
            particle.size,
            0,
          );
        canvas.drawPath(wave, paint);
      case LevelEffect.embers:
        paint.color = particle.color.withValues(alpha: 0.35 + pulse * 0.55);
        canvas.drawCircle(Offset.zero, particle.size, paint);
        paint.color = particle.color.withValues(alpha: 0.15 + pulse * 0.3);
        canvas.drawCircle(Offset.zero, particle.size * 2.2, paint);
    }
  }

  Path _starPath(double radius) {
    final path = Path();
    for (var i = 0; i < 8; i++) {
      final r = i.isEven ? radius : radius * 0.32;
      final angle = -math.pi / 2 + i * math.pi / 4;
      final point = Offset(
        math.cos(angle) * r,
        math.sin(angle) * r,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  void _spawnAll() {
    final count = switch (kind) {
      LevelEffect.petals => 22,
      LevelEffect.butterflies => 12,
      LevelEffect.bubbles => 20,
      LevelEffect.balloons => 9,
      LevelEffect.fireflies => 26,
      LevelEffect.shootingStars => 6,
      LevelEffect.confetti => 34,
      LevelEffect.snow => 40,
      LevelEffect.leaves => 20,
      LevelEffect.sparkles => 24,
      LevelEffect.sand => 30,
      LevelEffect.waves => 18,
      LevelEffect.embers => 22,
    };
    for (var i = 0; i < count; i++) {
      _particles.add(_makeParticle(initial: true));
    }
  }

  _Particle _makeParticle({required bool initial}) {
    final particle = _Particle()
      ..x = _random.nextDouble() * _spreadExtent
      ..y = initial
          ? _random.nextDouble() * _fallExtent
          : -40 - _random.nextDouble() * 100
      ..phase = _random.nextDouble() * math.pi * 2
      ..life = _random.nextDouble() * 4
      ..angle = _random.nextDouble() * math.pi * 2;

    switch (kind) {
      case LevelEffect.petals:
        particle
          ..size = 5 + _random.nextDouble() * 5
          ..color = _pick([
            AppPalette.pink,
            AppPalette.yellow,
            AppPalette.white,
            AppPalette.red,
          ]);
      case LevelEffect.butterflies:
        particle
          ..size = 7 + _random.nextDouble() * 5
          ..vx = (_random.nextDouble() - 0.5) * 46
          ..vy = 10 + _random.nextDouble() * 26
          ..color = _pick([
            AppPalette.violet,
            AppPalette.cyan,
            AppPalette.yellow,
            AppPalette.pink,
          ]);
      case LevelEffect.bubbles:
        particle
          ..size = 5 + _random.nextDouble() * 10
          ..color = _pick([
            AppPalette.cyan,
            AppPalette.white,
            AppPalette.blue,
          ]);
      case LevelEffect.balloons:
        particle
          ..size = 10 + _random.nextDouble() * 7
          ..color = _pick([
            AppPalette.red,
            AppPalette.blue,
            AppPalette.yellow,
            AppPalette.green,
            AppPalette.violet,
            AppPalette.pink,
          ]);
      case LevelEffect.fireflies:
        particle
          ..size = 2.4 + _random.nextDouble() * 2.6
          ..vx = (_random.nextDouble() - 0.5) * 26
          ..vy = (_random.nextDouble() - 0.5) * 26
          ..color = _pick([AppPalette.yellow, AppPalette.lime]);
      case LevelEffect.shootingStars:
        particle
          ..size = 14 + _random.nextDouble() * 12
          ..vx = -70 - _random.nextDouble() * 80
          ..vy = 60 + _random.nextDouble() * 70
          ..color = _pick([AppPalette.white, AppPalette.yellow]);
      case LevelEffect.confetti:
        particle
          ..size = 4 + _random.nextDouble() * 4
          ..spin = (_random.nextDouble() - 0.5) * 7
          ..color = _pick([
            AppPalette.red,
            AppPalette.orange,
            AppPalette.yellow,
            AppPalette.green,
            AppPalette.cyan,
            AppPalette.blue,
            AppPalette.violet,
            AppPalette.pink,
          ]);
      case LevelEffect.snow:
        particle
          ..size = 2.5 + _random.nextDouble() * 3.5
          ..color = AppPalette.white;
      case LevelEffect.leaves:
        particle
          ..size = 7 + _random.nextDouble() * 5
          ..spin = (_random.nextDouble() - 0.5) * 3.4
          ..color = _pick([
            AppPalette.orange,
            AppPalette.brown,
            AppPalette.yellow,
            AppPalette.red,
          ]);
      case LevelEffect.sparkles:
        particle
          ..size = 3 + _random.nextDouble() * 4
          ..vx = (_random.nextDouble() - 0.5) * 12
          ..vy = (_random.nextDouble() - 0.5) * 12
          ..spin = (_random.nextDouble() - 0.5) * 2
          ..color = _pick([
            AppPalette.cyan,
            AppPalette.white,
            AppPalette.blue,
          ]);
      case LevelEffect.sand:
        particle
          ..size = 2 + _random.nextDouble() * 3
          ..color = _pick([
            const Color(0xFFF3D9A4),
            const Color(0xFFE7C88C),
            AppPalette.orange,
          ]);
      case LevelEffect.waves:
        particle
          ..size = 6 + _random.nextDouble() * 6
          ..color = _pick([
            AppPalette.cyan,
            AppPalette.white,
            AppPalette.blue,
          ]);
      case LevelEffect.embers:
        particle
          ..size = 2.5 + _random.nextDouble() * 3.5
          ..color = _pick([
            const Color(0xFFFF7043),
            AppPalette.orange,
            AppPalette.yellow,
          ]);
    }
    return particle;
  }

  Color _pick(List<Color> colors) =>
      colors[_random.nextInt(colors.length)];

  void _recycle(_Particle particle) {
    const margin = 70.0;
    if (particle.y > _fallExtent + margin) {
      particle.y = -margin;
      particle.x = _random.nextDouble() * _spreadExtent;
    } else if (particle.y < -margin) {
      particle.y = _fallExtent + margin;
      particle.x = _random.nextDouble() * _spreadExtent;
    }
    if (particle.x < -margin) {
      particle.x = _spreadExtent + margin;
    } else if (particle.x > _spreadExtent + margin) {
      particle.x = -margin;
    }
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double vx = 0;
  double vy = 0;
  double size = 6;
  double phase = 0;
  double spin = 0;
  double angle = 0;
  double life = 0;
  Color color = const Color(0xFFFFFFFF);
}
