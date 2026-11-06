import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

/// Tipos de obstaculos que aparecen en la pista.
enum ObstacleType {
  /// Cono de trafico.
  cone,

  /// Charco de agua.
  puddle,

  /// Roca.
  rock,
}

/// Un obstaculo de la pista.
///
/// Chocar con el **no** termina la partida: el coche se detiene un segundo
/// y el juego continua.
class Obstacle extends PositionComponent {
  /// Crea un obstaculo.
  Obstacle({
    required this.type,
    required this.image,
    required this.obstacleSize,
  });

  /// Tipo de obstaculo.
  final ObstacleType type;

  /// Imagen del sprite.
  final ui.Image image;

  /// Tamano logico del obstaculo.
  final Vector2 obstacleSize;

  /// `true` si el obstaculo ya fue golpeado.
  bool get isCrushed => _crushed;
  bool _crushed = false;

  /// Marca el obstaculo como golpeado (se aplasta y se desvanece).
  void crush() {
    if (_crushed) {
      return;
    }
    _crushed = true;
    scale = Vector2.all(0.8);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = obstacleSize;
    anchor = Anchor.center;
    await add(
      SpriteComponent(
        sprite: Sprite(image),
        size: obstacleSize,
        anchor: Anchor.center,
      ),
    );
    await add(
      RectangleHitbox(
        size: Vector2(obstacleSize.x * 0.7, obstacleSize.y * 0.7),
        anchor: Anchor.center,
        position: Vector2.zero(),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_crushed) {
      // Se aplasta y desaparece: nunca hay "game over".
      final next = scale.x - dt * 0.9;
      if (next <= 0.05) {
        removeFromParent();
        return;
      }
      scale = Vector2.all(next.clamp(0.05, 1.0));
    }
  }
}
