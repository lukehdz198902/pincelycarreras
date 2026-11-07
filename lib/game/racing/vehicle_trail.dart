import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

/// Estela de polvo detras del vehiculo.
///
/// Son bocanadas que salen por detras y se desvanecen: dan sensacion de
/// movimiento y de que el vehiculo "vive", sin necesidad de mas sprites.
class VehicleTrail extends Component {
  /// Crea la estela.
  VehicleTrail({required this.color, this.interval = 0.09});

  /// Color del polvo.
  final Color color;

  /// Velocidad actual del vehiculo: a mas velocidad, mas polvo.
  double speed = 0;

  /// Segundos entre bocanada y bocanada.
  final double interval;

  /// Posicion del vehiculo (se actualiza cada frame).
  Vector2 anchor = Vector2.zero();

  /// Si la estela esta activa.
  bool enabled = true;

  final List<_Puff> _puffs = [];
  double _timer = 0;
  int _seed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (!enabled) {
      return;
    }
    _timer += dt;
    while (_timer >= interval) {
      _timer -= interval;
      _spawn();
    }
    for (final puff in _puffs) {
      puff.age += dt;
      puff.y += 26 * dt;
      puff.radius += 14 * dt;
    }
    _puffs.removeWhere((puff) => puff.age > puff.life);
  }

  void _spawn() {
    _seed++;
    _puffs.add(
      _Puff(
        x: anchor.x + ((_seed * 37) % 13 - 6),
        y: anchor.y + 6,
        radius: 5 + (speed * 0.02) + (_seed % 3),
        life: 0.55 + (math.Random(_seed).nextDouble() * 0.25),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    for (final puff in _puffs) {
      final progress = puff.age / puff.life;
      if (progress >= 1) {
        continue;
      }
      final paint = Paint()
        ..isAntiAlias = true
        ..color = color.withValues(alpha: 0.4 * (1 - progress));
      canvas.drawCircle(
        Offset(puff.x, puff.y),
        puff.radius,
        paint,
      );
    }
  }
}

class _Puff {
  _Puff({
    required this.x,
    required this.y,
    required this.radius,
    required this.life,
  });

  double x;
  double y;
  double radius;
  double age = 0;
  final double life;
}

/// Lineas de viento que aparecen al correr rapido.
///
/// Dan sensacion de velocidad sin necesidad de sprites: son trazos claros
/// que bajan por los lados de la pantalla.
class SpeedStreaks extends Component {
  /// Intensidad actual (0 = parado, 1 = a tope).
  double intensity = 0;

  final List<_Streak> _streaks = [];
  double _timer = 0;
  int _seed = 0;

  @override
  void update(double dt) {
    super.update(dt);
    if (intensity < 0.35) {
      return;
    }
    _timer += dt;
    while (_timer > 0.05) {
      _timer -= 0.05;
      _spawn();
    }
    for (final streak in _streaks) {
      streak.age += dt;
      streak.y += streak.speed * dt;
    }
    _streaks.removeWhere((streak) => streak.age > streak.life);
  }

  void _spawn() {
    _seed++;
    final side = _seed.isEven ? -1.0 : 1.0;
    _streaks.add(
      _Streak(
        x: side * (120 + (_seed * 53) % 160),
        y: -40,
        speed: 320 + (_seed * 37) % 220,
        life: 0.5 + (_seed % 3) * 0.12,
        length: 26 + (_seed % 4) * 12,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (intensity < 0.35) {
      return;
    }
    final paint = Paint()
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..color = const Color(0xFFFFFFFF).withValues(alpha: 0.28 * intensity);
    for (final streak in _streaks) {
      final progress = streak.age / streak.life;
      if (progress >= 1) {
        continue;
      }
      canvas.drawLine(
        Offset(streak.x, streak.y),
        Offset(streak.x, streak.y + streak.length),
        paint,
      );
    }
  }
}

class _Streak {
  _Streak({
    required this.x,
    required this.y,
    required this.speed,
    required this.life,
    required this.length,
  });

  final double x;
  double y;
  final double speed;
  final double life;
  final double length;
  double age = 0;
}

/// Campo de chispas (al recoger una estrella).
class SparkField extends Component {
  /// Lista de explosiones de chispas.
  final List<SparkBurst> bursts = [];

  /// Crea una explosion de chispas.
  void burst({required Vector2 position, required Color color}) {
    bursts.add(SparkBurst(position: position, color: color));
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final burst in bursts) {
      burst.age += dt;
    }
    bursts.removeWhere((burst) => burst.age > burst.life);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..isAntiAlias = true;
    for (final burst in bursts) {
      final progress = burst.age / burst.life;
      if (progress >= 1) {
        continue;
      }
      paint.color = burst.color.withValues(alpha: 0.8 * (1 - progress));
      final radius = 8 + progress * 34;
      for (var i = 0; i < 8; i++) {
        final angle = i / 8 * math.pi * 2;
        canvas.drawCircle(
          Offset(
            burst.position.x + math.cos(angle) * radius,
            burst.position.y + math.sin(angle) * radius,
          ),
          4 * (1 - progress) + 1.5,
          paint,
        );
      }
    }
  }
}

/// Explosion de chispas (una estrella recogida).
class SparkBurst {
  /// Crea la explosion.
  SparkBurst({required this.position, required this.color});

  /// Centro de la explosion.
  final Vector2 position;

  /// Color de las chispas.
  final Color color;

  /// Duracion total.
  final double life = 0.45;

  /// Edad actual.
  double age = 0;
}
