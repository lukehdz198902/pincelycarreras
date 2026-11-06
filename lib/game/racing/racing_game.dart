import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../data/models/level_spec.dart';
import '../../data/services/asset_service.dart';
import 'car.dart';
import 'collectible.dart';
import 'lane.dart';
import 'level_ambience.dart';
import 'obstacle.dart';
import 'race_timing.dart';
import 'track_generator.dart';
import 'track_scroller.dart';
import 'vehicle_trail.dart';

/// Modo de carreras: vista cenital con 3 carriles.
///
/// El coche acelera **solo**: el nino unicamente toca la pantalla para
/// cambiar de carril. Chocar no termina la partida, solo detiene el coche
/// un segundo. Cada mundo tiene un **final**: la meta cierra la carrera.
class RacingGame extends FlameGame
    with HasCollisionDetection, MultiTouchTapDetector, PanDetector {
  /// Crea la escena de carreras.
  RacingGame({
    required this.carAssetPath,
    required this.trackAssetPath,
    required this.asphaltAssetPath,
    required this.curbAssetPath,
    required this.onStarCollected,
    required this.onCrash,
    required this.onLapCompleted,
    required this.onRaceFinished,
    this.onLaneChange,
    this.effect = LevelEffect.petals,
    this.speedScale = 1,
    this.levelSeed = 1,
    this.starsPerLap = 3,
    this.vehicleWidthFactor = 1,
    this.vehicleHeightFactor = 1,
    this.decalAssetPath,
    this.decalColor = 0xFFFF4757,
    this.characterAssetPath,
    this.laps = 3,
    this.targetSeconds = 70,
  });

  /// Ruta del sprite del vehiculo.
  final String carAssetPath;

  /// Ruta del fondo de la pista.
  final String trackAssetPath;

  /// Ruta del asfalto (la carretera de este mundo).
  final String asphaltAssetPath;

  /// Ruta del bordillo de este mundo.
  final String curbAssetPath;

  /// Efecto ambiental del mundo.
  final LevelEffect effect;

  /// Multiplicador de velocidad del mundo.
  final double speedScale;

  /// Semilla de las particulas ambientales.
  final int levelSeed;

  /// Estrellas otorgadas al cruzar cada banderin.
  final int starsPerLap;

  /// Multiplicador de anchura del vehiculo.
  final double vehicleWidthFactor;

  /// Multiplicador de longitud del vehiculo.
  final double vehicleHeightFactor;

  /// Ruta de la calca pintada en la carroceria (opcional).
  final String? decalAssetPath;

  /// Color de la calca (ARGB).
  final int decalColor;

  /// Ruta del personaje que viaja con el nino (opcional).
  final String? characterAssetPath;

  /// Numero de tramos del recorrido (el ultimo es la meta).
  final int laps;

  /// Duracion objetivo de la carrera en segundos.
  final int targetSeconds;

  /// Se invoca con el numero de estrellas recogidas.
  final void Function(int amount) onStarCollected;

  /// Se invoca cuando el coche choca con un obstaculo.
  final VoidCallback onCrash;

  /// Se invoca cuando el coche cruza un banderin intermedio.
  final VoidCallback onLapCompleted;

  /// Se invoca cuando el coche cruza la meta y la carrera termina.
  final VoidCallback onRaceFinished;

  /// Se invoca cuando el coche cambia de carril.
  final VoidCallback? onLaneChange;

  /// Color de fondo mientras se cargan los sprites.
  ///
  /// Flame usa negro puro por defecto, que provocaria un destello negro
  /// al entrar en la pantalla. Se usa el azul noche de la paleta.
  @override
  Color backgroundColor() => AppPalette.ink;

  /// Velocidad inicial de la pista.
  static const double initialSpeed = RaceTiming.baseSpeed;

  /// Velocidad maxima de la pista (constante: no acelera).
  static const double maxSpeed = RaceTiming.baseSpeed;

  /// Tiempo entre filas de obstaculos (multiplicador de la velocidad).
  ///
  /// Antes era 1,15: las filas se empalmaban y era imposible esquivarlas.
  /// Con 2,2 hay siempre un hueco comodo entre obstaculos.
  static const double rowSpacingFactor = 2.2;

  /// Estrellas otorgadas al cruzar la meta.
  static const int lapStars = 3;

  final TrackGenerator _generator = TrackGenerator();
  final math.Random _random = math.Random();
  final List<Obstacle> _obstacles = [];
  final List<Collectible> _collectibles = [];
  final List<_TrackBanner> _banners = [];

  ui.Image? _carImage;
  ui.Image? _trackImage;
  ui.Image? _asphaltImage;
  ui.Image? _curbImage;
  ui.Image? _starImage;
  ui.Image? _coneImage;
  ui.Image? _puddleImage;
  ui.Image? _rockImage;
  ui.Image? _decalImage;
  ui.Image? _characterImage;

  Car? _car;
  TrackScroller? _scroller;
  VehicleTrail? _trail;
  bool _assetsReady = false;
  bool _halted = false;
  bool _finished = false;
  double _scroll = 0;
  double _elapsed = 0;
  double _raceSeconds = 0;
  double _speed = initialSpeed;
  double _distanceSinceRow = 0;
  double _distanceSinceLap = 0;
  double _lapDistance = 2600;
  int _bannersSpawned = 0;
  double? _dragStartX;
  double? _carDragX;
  Vector2? _builtSize;

  /// Velocidad actual de la pista.
  double get currentSpeed => _speed;

  /// `true` si el juego esta listo para jugar.
  bool get isReady => _assetsReady && _car != null;

  /// `true` si la escena se ha detenido de forma definitiva.
  bool get isHalted => _halted;

  /// `true` si la carrera ya ha terminado (meta cruzada).
  bool get isFinished => _finished;

  /// Segundos transcurridos desde el inicio de la carrera.
  double get raceSeconds => _raceSeconds;

  /// Carril en el que esta el coche (`null` si aun no se ha construido).
  Lane? get carLane => _car?.currentLane;

  /// Posicion horizontal del coche en la pantalla.
  double get carX => _car?.x ?? 0;

  /// Detiene el motor de forma definitiva.
  ///
  /// Se llama al salir de la pantalla: aunque el `GameWidget` tarde en
  /// desmontarse, el `update` deja de mover coche, obstaculos y estrellas.
  void halt() {
    _halted = true;
    pauseEngine();
  }

  @override
  void onRemove() {
    _halted = true;
    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Flame 1.38 ancla el "viewfinder" en el CENTRO del viewport: el origen
    // (0, 0) del mundo aparece en el centro de la pantalla y todo lo que se
    // dibuja queda desplazado media pantalla. Para un juego de carreras
    // top-down el origen debe ser la esquina superior izquierda, que es lo
    // que espera el resto del juego (pista centrada y coche abajo).
    camera.viewfinder.anchor = Anchor.topLeft;

    try {
      final images = await Future.wait([
        AssetService.loadImage(carAssetPath),
        AssetService.loadImage(trackAssetPath),
        AssetService.loadImage(asphaltAssetPath),
        AssetService.loadImage(curbAssetPath),
        AssetService.loadImage(AssetPaths.star),
        AssetService.loadImage(AssetPaths.cone),
        AssetService.loadImage(AssetPaths.puddle),
        AssetService.loadImage(AssetPaths.rock),
        if (decalAssetPath != null) AssetService.loadImage(decalAssetPath!),
        if (characterAssetPath != null)
          AssetService.loadImage(characterAssetPath!),
      ]);
      _carImage = images[0];
      _trackImage = images[1];
      _asphaltImage = images[2];
      _curbImage = images[3];
      _starImage = images[4];
      _coneImage = images[5];
      _puddleImage = images[6];
      _rockImage = images[7];
      _decalImage = images.length > 8 ? images[8] : null;
      _characterImage = images.length > 9 ? images[9] : null;
      _decalImage = images.length > 10 ? images[10] : null;
      _characterImage = images.length > 11 ? images[11] : null;
      _assetsReady = true;
      unawaited(_buildWorld());
    } catch (error) {
      debugPrint('[Pincel] No se pudo preparar la carrera: $error');
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!_assetsReady) {
      return;
    }
    if (_builtSize == null ||
        _builtSize!.x != size.x ||
        _builtSize!.y != size.y) {
      unawaited(_buildWorld());
    }
  }

  Future<void> _buildWorld() async {
    if (_halted) {
      return;
    }
    final carImage = _carImage;
    final trackImage = _trackImage;
    final asphaltImage = _asphaltImage;
    final curbImage = _curbImage;
    if (carImage == null ||
        trackImage == null ||
        asphaltImage == null ||
        curbImage == null) {
      return;
    }

    world.removeAll(world.children.toList());
    _obstacles.clear();
    _collectibles.clear();
    _banners.clear();

    final roadWidth = math.min(
      size.x - GameSizes.roadMargin * 2,
      GameSizes.maxRoadWidth,
    );
    final laneWidth = roadWidth / 3;
    final carWidth = laneWidth * 0.62 * vehicleWidthFactor;
    final carHeight = carWidth * 1.52 * vehicleHeightFactor;

    final scroller = TrackScroller(
      backgroundImage: trackImage,
      asphaltImage: asphaltImage,
      curbImage: curbImage,
      roadWidth: roadWidth,
    )
      ..size = size.clone()
      ..priority = -10;
    _scroller = scroller;
    await world.add(scroller);

    // Las particulas del mundo van por encima del fondo pero por debajo
    // del vehiculo y de los obstaculos.
    await world.add(
      LevelAmbience(
        kind: effect,
        seed: levelSeed,
      )..priority = -5,
    );

    // Estela de polvo detras del vehiculo.
    final trail = VehicleTrail(color: _trailColor(effect))..priority = -4;
    _trail = trail;
    await world.add(trail);

    final car = Car(
      image: carImage,
      carWidth: carWidth,
      carHeight: carHeight,
      onCollect: () => onStarCollected(1),
      onCrash: onCrash,
    )..position = Vector2(size.x / 2, size.y * 0.78);
    _car = car;
    await world.add(car);
    car.configure(
      roadCenterX: size.x / 2,
      laneWidth: laneWidth,
      roadWidth: roadWidth,
    );

    // Calca y personaje: lo que el nino ha pintado en el taller.
    final livery = _VehicleLivery(
      decalImage: _decalImage,
      decalColor: Color(decalColor),
      characterImage: _characterImage,
    );
    livery.size = Vector2(carWidth, carHeight);
    if (livery.hasContent) {
      await car.add(livery);
    }

    _builtSize = size.clone();
    _scroll = 0;
    _elapsed = 0;
    _raceSeconds = 0;
    _speed = initialSpeed * speedScale;
    _distanceSinceRow = 0;
    _distanceSinceLap = 0;
    _bannersSpawned = 0;
    _finished = false;
    _lapDistance = RaceTiming.lapDistance(
      targetSeconds: targetSeconds,
      laps: laps,
      speedScale: speedScale,
    );
    _scroller?.scroll = 0;
  }

  /// Color del polvo de la estela segun el ambiente del mundo.
  static Color _trailColor(LevelEffect effect) => switch (effect) {
        LevelEffect.snow => const Color(0xFFFFFFFF),
        LevelEffect.sand => const Color(0xFFE8C88C),
        LevelEffect.leaves => const Color(0xFFC58A4A),
        LevelEffect.petals => const Color(0xFFFFC0DB),
        LevelEffect.embers => const Color(0xFF8A5A5A),
        _ => const Color(0xFFBFC4D4),
      };

  /// Mueve el coche al carril indicado.
  void steerTo(Lane lane) {
    if (_car?.currentLane == lane) {
      return;
    }
    _car?.steerTo(lane);
    onLaneChange?.call();
  }

  /// Mueve el coche al carril izquierdo.
  void steerLeft() {
    if (_car == null) {
      return;
    }
    _car!.steerLeft();
    onLaneChange?.call();
  }

  /// Mueve el coche al carril derecho.
  void steerRight() {
    if (_car == null) {
      return;
    }
    _car!.steerRight();
    onLaneChange?.call();
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    // Un unico toque en cualquier parte: mitad izquierda o derecha.
    if (info.eventPosition.widget.x < size.x / 2) {
      steerLeft();
    } else {
      steerRight();
    }
  }

  @override
  void onPanStart(DragStartInfo info) {
    _dragStartX = info.eventPosition.widget.x;
    _carDragX = _car?.x;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    final car = _car;
    final start = _dragStartX;
    final origin = _carDragX;
    if (car == null || start == null || origin == null) {
      return;
    }
    // El nino arrastra el coche por la carretera: se mueve de forma
    // continua, como en los juegos modernos.
    final delta = info.eventPosition.widget.x - start;
    car.moveTo(origin + delta);
  }

  @override
  void onPanEnd(DragEndInfo info) {
    _dragStartX = null;
    _carDragX = null;
  }

  @override
  void onPanCancel() {
    _dragStartX = null;
    _carDragX = null;
  }

  @override
  void update(double dt) {
    if (_halted || _finished) {
      return;
    }
    super.update(dt);
    _raceSeconds += dt;
    final car = _car;
    final scroller = _scroller;
    if (car == null || scroller == null) {
      return;
    }

    if (car.isStunned) {
      // Tras un choque el mundo se detiene: nunca hay "game over".
      return;
    }

    _elapsed += dt;
    // Velocidad CONSTANTE: el nino no pierde el ritmo a mitad de carrera.
    _speed = RaceTiming.speedAt(_elapsed, speedScale);
    _scroll += _speed * dt;
    scroller.scroll = _scroll;
    _trail?.anchor = car.position.clone();

    _distanceSinceRow += _speed * dt;
    if (_distanceSinceRow >= _speed * rowSpacingFactor) {
      _distanceSinceRow = 0;
      unawaited(_spawnRow());
    }

    _distanceSinceLap += _speed * dt;
    if (_distanceSinceLap >= _lapDistance) {
      _distanceSinceLap = 0;
      final isFinish = _bannersSpawned >= laps - 1;
      unawaited(_spawnBanner(isFinish: isFinish));
      _bannersSpawned++;
    }

    _advance(dt);
  }

  void _advance(double dt) {
    final distance = _speed * dt;
    final limit = size.y + 140;

    for (final obstacle in List<Obstacle>.from(_obstacles)) {
      obstacle.position.y += distance;
      if (obstacle.position.y > limit) {
        obstacle.removeFromParent();
        _obstacles.remove(obstacle);
      }
    }

    for (final star in List<Collectible>.from(_collectibles)) {
      star.position.y += distance;
      if (star.position.y > limit) {
        star.removeFromParent();
        _collectibles.remove(star);
      }
    }

    final car = _car;
    for (final banner in List<_TrackBanner>.from(_banners)) {
      banner.position.y += distance;
      if (car != null && banner.position.y >= car.position.y) {
        _banners.remove(banner);
        banner.removeFromParent();
        if (banner.isFinish) {
          _finished = true;
          onRaceFinished();
        } else {
          onStarCollected(starsPerLap);
          onLapCompleted();
        }
      } else if (banner.position.y > limit) {
        _banners.remove(banner);
        banner.removeFromParent();
      }
    }
  }

  Future<void> _spawnRow() async {
    final car = _car;
    if (car == null) {
      return;
    }
    final roadWidth = _scroller?.roadWidth ?? GameSizes.maxRoadWidth;
    final laneWidth = roadWidth / 3;
    final roadCenterX = size.x / 2;
    final row = _generator.next();
    final spawnY = -80.0;
    final newComponents = <Component>[];

    for (final lane in row.obstacleLanes) {
      final type = _randomObstacleType();
      final image = _imageForType(type);
      if (image == null) {
        continue;
      }
      final obstacle = Obstacle(
        type: type,
        image: image,
        obstacleSize: Vector2(laneWidth * 0.72, laneWidth * 0.72),
      )..position = Vector2(roadCenterX + (lane - 1) * laneWidth, spawnY);
      _obstacles.add(obstacle);
      newComponents.add(obstacle);
    }

    final starLane = row.starLane;
    final starImage = _starImage;
    if (starLane != null && starImage != null) {
      final star = Collectible(
        image: starImage,
        itemSize: Vector2(laneWidth * 0.62, laneWidth * 0.62),
      )..position = Vector2(roadCenterX + (starLane - 1) * laneWidth, spawnY);
      _collectibles.add(star);
      newComponents.add(star);
    }

    await world.addAll(newComponents);
  }

  Future<void> _spawnBanner({required bool isFinish}) async {
    final roadWidth = _scroller?.roadWidth ?? GameSizes.maxRoadWidth;
    final banner = _TrackBanner(isFinish: isFinish)
      ..size = Vector2(roadWidth, isFinish ? 30 : 20)
      ..priority = -1
      ..position = Vector2(size.x / 2 - roadWidth / 2, -60);
    _banners.add(banner);
    await world.add(banner);
  }

  ObstacleType _randomObstacleType() {
    return switch (_random.nextInt(3)) {
      0 => ObstacleType.cone,
      1 => ObstacleType.puddle,
      _ => ObstacleType.rock,
    };
  }

  ui.Image? _imageForType(ObstacleType type) => switch (type) {
    ObstacleType.cone => _coneImage,
    ObstacleType.puddle => _puddleImage,
    ObstacleType.rock => _rockImage,
  };
}

/// Linea de meta (o banderin de vuelta) dibujada en el juego.
///
/// Se dibuja **en el mundo**, no como sprite: asi es nitida a cualquier
/// tamano (los PNG se veian pixeleados al estirarlos por toda la carretera)
/// y el coche pasa **por encima** de ella.
class _TrackBanner extends PositionComponent {
  _TrackBanner({required this.isFinish});

  /// `true` si es la meta final.
  final bool isFinish;

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    final paint = Paint()..isAntiAlias = false;
    final cell = height / 2;

    if (isFinish) {
      // Meta a cuadros.
      final columns = (width / cell).ceil();
      for (var row = 0; row < 2; row++) {
        for (var column = 0; column < columns; column++) {
          paint.color = (row + column).isEven
              ? const Color(0xFF2B2D42)
              : const Color(0xFFFFFFFF);
          canvas.drawRect(
            Rect.fromLTWH(column * cell, row * cell, cell, cell),
            paint,
          );
        }
      }
      return;
    }

    // Banderin de vuelta: dos franjas de color con flechas.
    paint.color = const Color(0xFF2ED573);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height / 2), paint);
    paint.color = const Color(0xFFFFD32A);
    canvas.drawRect(Rect.fromLTWH(0, height / 2, width, height / 2), paint);
    paint.color = const Color(0x552B2D42);
    final step = height * 1.2;
    for (var x = 0.0; x < width; x += step) {
      final path = Path()
        ..moveTo(x, height * 0.15)
        ..lineTo(x + height * 0.5, height * 0.5)
        ..lineTo(x, height * 0.85)
        ..lineTo(x + height * 0.22, height * 0.5)
        ..close();
      canvas.drawPath(path, paint);
    }
  }
}

/// Calca pintada y personaje: la "decoracion" del vehiculo.
///
/// La calca se tiñe con un filtro de color (`srcIn`), asi el nino puede
/// pintarla del color que quiera sin necesidad de mas sprites.
class _VehicleLivery extends PositionComponent {
  _VehicleLivery({
    required this.decalImage,
    required this.decalColor,
    required this.characterImage,
  });

  final ui.Image? decalImage;
  final Color decalColor;
  final ui.Image? characterImage;

  /// `true` si hay algo que dibujar.
  bool get hasContent => decalImage != null || characterImage != null;

  @override
  void render(Canvas canvas) {
    final decal = decalImage;
    if (decal != null) {
      final side = size.x * 0.38;
      final paint = Paint()
        ..filterQuality = FilterQuality.medium
        ..colorFilter = ColorFilter.mode(decalColor, BlendMode.srcIn);
      canvas.drawImageRect(
        decal,
        Rect.fromLTWH(0, 0, decal.width.toDouble(), decal.height.toDouble()),
        Rect.fromCenter(
          center: Offset(0, size.y * 0.08),
          width: side,
          height: side,
        ),
        paint,
      );
    }

    final character = characterImage;
    if (character != null) {
      final side = size.x * 0.3;
      final paint = Paint()..filterQuality = FilterQuality.medium;
      canvas.drawImageRect(
        character,
        Rect.fromLTWH(
          0,
          0,
          character.width.toDouble(),
          character.height.toDouble(),
        ),
        Rect.fromCenter(
          center: Offset(0, -size.y * 0.34),
          width: side,
          height: side,
        ),
        paint,
      );
    }
  }
}
