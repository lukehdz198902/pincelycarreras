import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';

/// Una estrella coleccionable.
///
/// Al recogerla suma una estrella y se reproduce un sonido positivo.
class Collectible extends PositionComponent {
  /// Crea una estrella.
  Collectible({required this.image, required this.itemSize});

  /// Imagen del sprite.
  final ui.Image image;

  /// Tamano logico del coleccionable.
  final Vector2 itemSize;

  /// `true` si ya fue recogida.
  bool get isCollected => _collected;
  bool _collected = false;

  /// Velocidad de giro.
  static const double spinSpeed = 2.2;

  SpriteComponent? _sprite;

  /// Marca la estrella como recogida y la hace desaparecer.
  void collect() {
    if (_collected) {
      return;
    }
    _collected = true;
    removeFromParent();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = itemSize;
    anchor = Anchor.center;
    final sprite = SpriteComponent(
      sprite: Sprite(image),
      size: itemSize,
      anchor: Anchor.center,
    );
    _sprite = sprite;
    await add(sprite);
    await add(
      CircleHitbox(
        radius: itemSize.x * 0.45,
        anchor: Anchor.center,
        position: Vector2.zero(),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _sprite?.angle += spinSpeed * dt;
  }
}
