import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/painting.dart';

import 'collectible.dart';
import 'lane.dart';
import 'obstacle.dart';

/// El coche del nino.
///
/// Se mueve **libremente por la carretera**: el control principal es el
/// **volante** (inclinacion del movil), que lo desplaza de forma continua;
/// tambien se puede arrastrar con el dedo o cambiar de carril.
class Car extends PositionComponent with CollisionCallbacks {
  /// Crea el coche.
  Car({
    required this.image,
    required this.carWidth,
    required this.carHeight,
    this.onCollect,
    this.onCrash,
  });

  /// Imagen del sprite del coche.
  final ui.Image image;

  /// Se invoca cuando el coche recoge una estrella.
  final VoidCallback? onCollect;

  /// Se invoca cuando el coche choca con un obstaculo.
  final VoidCallback? onCrash;

  /// Ancho logico del coche.
  final double carWidth;

  /// Alto logico del coche.
  final double carHeight;

  /// Duracion del cambio de carril.
  static const double laneChangeSeconds = 0.22;

  /// Inclinacion maxima al cambiar de carril (radianes).
  static const double maxTilt = 0.21;

  Lane _currentLane = Lane.center;
  Lane? _pendingLane;
  double _startX = 0;
  double _targetX = 0;
  double _transition = 1;
  double _tiltDirection = 1;
  double _stunTimer = 0;
  double _shakeTimer = 0;
  double _roadCenterX = 0;
  double _laneWidth = 120;
  double _minX = 0;
  double _maxX = 0;
  double _centerX = 0;
  double _halfRange = 0;
  double _bounce = 0;
  bool _free = false;
  double _freeTargetX = 0;
  SpriteComponent? _sprite;

  /// Carril actual del coche.
  Lane get currentLane => _currentLane;

  /// `true` si el coche esta inmovilizado tras un choque.
  bool get isStunned => _stunTimer > 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(carWidth, carHeight);
    anchor = Anchor.center;

    _sprite = SpriteComponent(
      sprite: Sprite(image),
      size: Vector2(carWidth, carHeight),
      anchor: Anchor.center,
    );
    await add(_sprite!);
    await add(
      RectangleHitbox(
        size: Vector2(carWidth * 0.62, carHeight * 0.78),
        anchor: Anchor.center,
        position: Vector2.zero(),
      ),
    );
  }

  /// Define la geometria de la pista para poder calcular los carriles.
  void configure({
    required double roadCenterX,
    required double laneWidth,
    double? roadWidth,
  }) {
    _roadCenterX = roadCenterX;
    _laneWidth = laneWidth;
    _targetX = _xForLane(_currentLane);
    if (_transition >= 1) {
      x = _targetX;
    }
    // Limites laterales: el coche puede moverse por **toda** la carretera,
    // no solo de carril en carril (como en los juegos de hoy).
    final width = roadWidth ?? laneWidth * 3;
    final margin = carWidth * 0.55;
    _minX = roadCenterX - width / 2 + margin;
    _maxX = roadCenterX + width / 2 - margin;
    _halfRange = (_maxX - _minX) / 2;
    _centerX = (_maxX + _minX) / 2;
  }

  /// Mueve el coche con el **volante** (inclinacion del movil).
  ///
  /// [normalized] va de `-1` (todo a la izquierda) a `+1` (todo a la
  /// derecha). El coche se desplaza de forma continua, sin saltos: el nino
  /// ve que responde al instante.
  void steerBy(double normalized) {
    final value = normalized.clamp(-1.0, 1.0);
    _free = true;
    _pendingLane = null;
    _freeTargetX = _centerX + value * _halfRange;
  }

  /// Mueve el coche libremente (arrastrando el dedo).
  ///
  /// El coche se desplaza de forma continua hacia el punto pedido: el nino
  /// ve que responde al instante.
  void moveTo(double worldX) {
    _free = true;
    _freeTargetX = worldX.clamp(_minX, _maxX);
    _pendingLane = null;
  }

  double _xForLane(Lane lane) =>
      _roadCenterX + (lane.index - 1) * _laneWidth;

  /// Pide al coche que se mueva a un carril.
  ///
  /// Si ya hay un cambio en curso, el nuevo se guarda en un buffer de
  /// una entrada: el nino nunca "pierde" un toque.
  void steerTo(Lane lane) {
    if (lane == _currentLane && _pendingLane == null && !_free) {
      return;
    }
    _free = false;
    if (_transition < 1) {
      _pendingLane = lane;
      return;
    }
    _applyLane(lane);
  }

  /// Mueve el coche un carril a la izquierda.
  void steerLeft() {
    final index = _currentLane.index;
    steerTo(LaneIndex.fromIndex((index - 1).clamp(0, 2)));
  }

  /// Mueve el coche un carril a la derecha.
  void steerRight() {
    final index = _currentLane.index;
    steerTo(LaneIndex.fromIndex((index + 1).clamp(0, 2)));
  }

  /// Devuelve el coche al carril central.
  void steerCenter() => steerTo(Lane.center);

  void _applyLane(Lane lane) {
    _currentLane = lane;
    _startX = x;
    _targetX = _xForLane(lane);
    _transition = 0;
    _tiltDirection = switch (lane) {
      Lane.left => -1,
      Lane.right => 1,
      Lane.center => 1,
    };
  }

  /// Inmoviliza el coche durante [seconds] tras un choque.
  ///
  /// No hay "game over": el juego simplemente continua despues.
  void stun([double seconds = 1]) {
    _stunTimer = seconds;
    _shakeTimer = seconds;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Suspension: el cuerpo cabecea suavemente mientras roda. Da vida al
    // vehiculo sin marear al nino.
    _bounce += dt;
    _sprite?.position.y = math.sin(_bounce * 16) * 1.8;

    if (_stunTimer > 0) {
      _stunTimer -= dt;
      _shakeTimer -= dt;
      // Pequeno temblor para que el choque se entienda.
      x = _targetX + math.sin(_shakeTimer * 60) * 3;
      return;
    }

    if (_free) {
      // Movimiento libre (el nino arrastra el dedo): el coche va hacia el
      // punto pedido y se inclina segun la velocidad lateral.
      final delta = _freeTargetX - x;
      x += delta * math.min(1, dt * 16);
      angle = (delta * 0.03).clamp(-maxTilt, maxTilt);
    } else if (_transition < 1) {
      _transition = math.min(1, _transition + dt / laneChangeSeconds);
      final eased = 1 - math.pow(1 - _transition, 3).toDouble();
      x = _startX + (_targetX - _startX) * eased;
      angle = math.sin(_transition * math.pi) * maxTilt * _tiltDirection;
      if (_transition >= 1) {
        final pending = _pendingLane;
        _pendingLane = null;
        if (pending != null) {
          _applyLane(pending);
        }
      }
    } else {
      angle = angle * (1 - math.min(1, dt * 8));
      x = _targetX;
    }
  }

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    return other is Obstacle || other is Collectible;
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is Collectible) {
      other.collect();
      onCollect?.call();
    } else if (other is Obstacle) {
      other.crush();
      if (!isStunned) {
        stun();
        onCrash?.call();
      }
    }
  }
}
