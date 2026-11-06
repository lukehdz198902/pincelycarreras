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
        radius: 5 + (_seed % 3),
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
