import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/services/asset_service.dart';
import 'climb_terrain.dart';
import 'race_timing.dart';

/// Modo "Subidas": el vehiculo recorre un terreno visto de lado.
///
/// El vehiculo **no esta pegado al terreno**: tiene peso. Al llegar a un
/// rasante deja de tocar el suelo, vuela un rato y aterriza aplastando la
/// suspension. Ese ciclo (acelerar, despegar, volar, aterrizar) es lo que
/// hace que se sienta como un juego de verdad.
///
/// No hay derrota: el vehiculo nunca se cae y la carrera termina en la meta.
class ClimbGame extends FlameGame {
  /// Crea la escena de las subidas.
  ClimbGame({
    required this.carAssetPath,
    required this.wheelAssetPath,
    required this.onStarCollected,
    required this.onFinished,
    required this.seed,
    this.loopCount = 1,
    this.skyColor = AppPalette.cyan,
    this.hillColor = const Color(0xFF6FBF73),
    this.groundColor = const Color(0xFFB07A45),
    this.sunColor = const Color(0xFFFFF0A8),
  });

  /// Ruta del sprite de la carroceria (vista de lado).
  final String carAssetPath;

  /// Ruta del sprite de la rueda.
  final String wheelAssetPath;

  /// Semilla del terreno.
  final int seed;

  /// Cuantos loops 360 grados tiene el trazado.
  final int loopCount;

  /// Color del cielo.
  final Color skyColor;

  /// Color de las colinas del fondo.
  final Color hillColor;

  /// Color del terreno.
  final Color groundColor;

  /// Color del sol o de la luna.
  final Color sunColor;

  /// Se invoca con el numero de estrellas recogidas.
  final void Function(int amount) onStarCollected;

  /// Se invoca al llegar a la meta (distancia y tiempo).
  final void Function(int distance, int seconds) onFinished;

  /// `true` mientras el nino pulsa el boton de acelerar.
  bool accelerating = false;

  /// `true` mientras el nino pulsa el boton de frenar.
  bool braking = false;

  late final ClimbTerrain _terrain;
  _ClimbStarField? _starField;
  _ClimbDust? _dust;
  ui.Image? _carImage;
  ui.Image? _wheelImage;
  ui.Image? _starImage;

  _ClimbVehicle? _vehicle;
  double _distance = 0;
  double _speed = ClimbSpeed.cruiseSpeed;
  double _seconds = 0;
  double _shake = 0;
  bool _finished = false;
  bool _halted = false;

  /// Distancia recorrida en pixeles.
  double get distance => _distance;

  /// Tiempo de la carrera en segundos.
  double get seconds => _seconds;

  /// Velocidad actual.
  double get currentSpeed => _speed;

  /// `true` si el vehiculo esta en el aire.
  bool get isAirborne => _vehicle?.airborne ?? false;

  /// `true` si la carrera ha terminado.
  bool get isFinished => _finished;

  /// `true` si la escena esta detenida.
  bool get isHalted => _halted;

  /// Detiene el motor de forma definitiva.
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
    camera.viewfinder.anchor = Anchor.topLeft;
    _terrain = ClimbTerrain(seed: seed, loopCount: loopCount);
    try {
      final images = await Future.wait([
        AssetService.loadImage(carAssetPath),
        AssetService.loadImage(wheelAssetPath),
        AssetService.loadImage(AssetPaths.star),
      ]);
      _carImage = images[0];
      _wheelImage = images[1];
      _starImage = images[2];
    } catch (error) {
      debugPrint('[Pincel] No se pudieron cargar las subidas: $error');
      return;
    }

    await world.add(
      _ClimbBackdrop(
        skyColor: skyColor,
        hillColor: hillColor,
        groundColor: groundColor,
        sunColor: sunColor,
        terrain: _terrain,
      ),
    );
    _dust = _ClimbDust(color: groundColor);
    await world.add(_dust!);

    final vehicle = _ClimbVehicle(
      bodyImage: _carImage!,
      wheelImage: _wheelImage!,
    );
    _vehicle = vehicle;
    await world.add(vehicle);

    await _placeStars();
  }

  Future<void> _placeStars() async {
    _starField?.removeFromParent();
    final image = _starImage;
    if (image == null) {
      return;
    }
    final stars = <_ClimbStar>[];
    var s = 320.0;
    while (s < _terrain.length - 260) {
      stars.add(_ClimbStar(position: _terrain.positionAt(s), radius: 18));
      s += 560 + (stars.length % 3) * 110;
    }
    final field = _ClimbStarField(image: image, stars: stars);
    _starField = field;
    await world.add(field);
  }

  @override
  void update(double dt) {
    if (_halted || _finished) {
      return;
    }
    super.update(dt);
    _seconds += dt;

    if (braking) {
      // El freno manda: si el nino pulsa los dos a la vez, frena.
      _speed -= ClimbSpeed.braking * dt;
    } else if (accelerating) {
      _speed += ClimbSpeed.acceleration * dt;
    } else {
      // Sin pulsar nada el vehiculo sigue rodando despacio.
      _speed += (ClimbSpeed.cruiseSpeed - _speed) * math.min(1, dt * 1.4);
    }
    _speed = _speed.clamp(ClimbSpeed.minSpeed, ClimbSpeed.maxSpeed);

    final vehicle = _vehicle;
    if (vehicle == null) {
      return;
    }

    final previousX = _distance;
    _distance += _speed * dt;
    vehicle.step(
      terrain: _terrain,
      dx: _distance - previousX,
      dt: dt,
      speed: _speed,
    );

    // Polvo: sale de las ruedas cuando acelera o al aterrizar.
    _dust?.emit(
      position: vehicle.wheelContact,
      speed: _speed,
      grounded: !vehicle.airborne,
      dt: dt,
    );
    if (vehicle.justLanded) {
      _shake = 7;
      _dust?.burst(vehicle.wheelContact);
    }
    _shake = math.max(0, _shake - dt * 26);

    // Estrellas: se recogen al pasar por encima.
    final stars = _starField?.stars ?? const <_ClimbStar>[];
    for (final star in stars) {
      if (star.collected) {
        continue;
      }
      if ((star.position.dx - vehicle.position.x).abs() < 48 &&
          (star.position.dy - vehicle.position.y).abs() < 70) {
        star.collected = true;
        onStarCollected(1);
      }
    }

    // Camara: sigue al vehiculo con suavizado y tiembla al aterrizar.
    final screenX = size.x * 0.36;
    final screenY = size.y * 0.62;
    final target = Vector2(
      vehicle.position.x - screenX,
      vehicle.position.y - screenY,
    );
    final current = camera.viewfinder.position;
    camera.viewfinder.position = Vector2(
      current.x + (target.x - current.x) * 0.25,
      current.y + (target.y - current.y) * 0.25,
    );
    if (_shake > 0.2) {
      camera.viewfinder.position += Vector2(
        math.sin(_seconds * 90) * _shake,
        math.cos(_seconds * 70) * _shake * 0.6,
      );
    }

    if (_distance >= _terrain.length - 40) {
      _finished = true;
      onFinished(_distance.round(), _seconds.round());
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Offset.zero & Size(size.x, size.y),
      Paint()..color = skyColor,
    );
    super.render(canvas);
  }
}

/// Vehiculo de las subidas con peso, suspension y vuelo.
class _ClimbVehicle extends PositionComponent {
  _ClimbVehicle({
    required ui.Image bodyImage,
    required ui.Image wheelImage,
  })  : _body = SpriteComponent(
          sprite: Sprite(bodyImage),
          size: Vector2(132, 78),
          anchor: Anchor.center,
        ),
        _wheelBack = SpriteComponent(
          sprite: Sprite(wheelImage),
          size: Vector2(38, 38),
          anchor: Anchor.center,
        ),
        _wheelFront = SpriteComponent(
          sprite: Sprite(wheelImage),
          size: Vector2(38, 38),
          anchor: Anchor.center,
        );

  final SpriteComponent _body;
  final SpriteComponent _wheelBack;
  final SpriteComponent _wheelFront;

  /// Velocidad vertical (px/s), positiva hacia abajo.
  double _verticalSpeed = 0;

  /// `true` si el vehiculo esta en el aire.
  bool airborne = false;

  /// `true` en el frame en el que aterriza.
  bool justLanded = false;

  /// Giro de las ruedas (radianes).
  double wheelSpin = 0;

  /// Suspension: 1 = normal, menor = aplastado.
  double squash = 1;

  /// Punto de contacto con el suelo (para el polvo).
  Vector2 wheelContact = Vector2.zero();

  double _bodyAngle = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await add(_wheelBack);
    await add(_wheelFront);
    await add(_body);
  }

  /// Avanza la fisica del vehiculo.
  void step({
    required ClimbTerrain terrain,
    required double dx,
    required double dt,
    required double speed,
  }) {
    justLanded = false;
    position.x += dx;

    final ground = terrain.positionAt(position.x);
    final groundAngle = terrain.angleAt(position.x);

    if (airborne) {
      // Vuelo: solo la gravedad manda.
      _verticalSpeed += ClimbSpeed.gravity * dt;
      position.y += _verticalSpeed * dt;
      if (position.y >= ground.dy) {
        position.y = ground.dy;
        airborne = false;
        justLanded = true;
        squash = 0.72;
        _verticalSpeed = 0;
      }
    } else {
      // En el suelo: el vehiculo sigue el terreno, pero si el terreno cae
      // mas rapido de lo que puede seguir, despega.
      final ahead = terrain.positionAt(position.x + math.max(dx, 6));
      final drop = ahead.dy - ground.dy;
      if (ClimbSpeed.shouldLeaveGround(
        drop: drop,
        dt: dt,
        speed: speed,
      )) {
        airborne = true;
        _verticalSpeed = math.min(_verticalSpeed, 0);
      } else {
        position.y = ground.dy;
        _verticalSpeed = 0;
      }
      // El angulo sigue al terreno con suavizado (sin tirones).
      _bodyAngle = _lerpAngle(_bodyAngle, groundAngle, math.min(1, dt * 12));
    }
    angle = _bodyAngle;

    // Las ruedas giran con la velocidad.
    wheelSpin += speed * dt / 19;

    // La suspension vuelve a su sitio despues de un aterrizaje.
    squash += (1 - squash) * math.min(1, dt * 9);

    // OJO: el origen del vehiculo es el **punto de apoyo** de las ruedas,
    // no su centro. Asi el coche va ENCIMA del terreno y no se mete dentro
    // de la montana.
    final lift = 19.0 + (1 - squash) * 8;
    _body.position = Vector2(0, -lift - 22);
    _body.scale = Vector2(1, squash);
    _wheelBack.position = Vector2(-38, -lift);
    _wheelBack.angle = wheelSpin;
    _wheelFront.position = Vector2(42, -lift);
    _wheelFront.angle = wheelSpin;
    wheelContact = Vector2(position.x - 38, position.y);
  }

  static double _lerpAngle(double from, double to, double t) {
    var difference = (to - from) % (math.pi * 2);
    if (difference > math.pi) {
      difference -= math.pi * 2;
    }
    if (difference < -math.pi) {
      difference += math.pi * 2;
    }
    return from + difference * t;
  }
}

/// Estrella del recorrido.
class _ClimbStar {
  _ClimbStar({required this.position, required this.radius});

  /// Posicion en el mundo.
  final Offset position;

  /// Radio de dibujo.
  final double radius;

  /// `true` si ya se ha recogido.
  bool collected = false;
}

/// Campo de estrellas del recorrido.
class _ClimbStarField extends Component {
  _ClimbStarField({required this.image, required this.stars});

  final ui.Image image;
  final List<_ClimbStar> stars;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    for (final star in stars) {
      if (star.collected) {
        continue;
      }
      canvas.drawImageRect(
        image,
        source,
        Rect.fromCenter(
          center: star.position,
          width: star.radius * 2.4,
          height: star.radius * 2.4,
        ),
        paint,
      );
    }
  }
}

/// Polvo que sale de las ruedas.
class _ClimbDust extends Component {
  _ClimbDust({required this.color});

  final Color color;
  final List<_DustPuff> _puffs = [];
  double _timer = 0;

  /// Emite polvo continuo bajo las ruedas.
  void emit({
    required Vector2 position,
    required double speed,
    required bool grounded,
    required double dt,
  }) {
    if (!grounded || speed < 30) {
      return;
    }
    _timer += dt;
    if (_timer < 0.09) {
      return;
    }
    _timer = 0;
    _puffs.add(
      _DustPuff(
        x: position.x,
        y: position.y,
        radius: 4 + speed * 0.05,
        life: 0.5,
      ),
    );
  }

  /// Explosion de polvo al aterrizar.
  void burst(Vector2 position) {
    for (var i = 0; i < 8; i++) {
      _puffs.add(
        _DustPuff(
          x: position.x + (i.isEven ? -10 : 10),
          y: position.y,
          radius: 7 + i * 1.5,
          life: 0.6,
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    for (final puff in _puffs) {
      puff.age += dt;
      puff.y += 18 * dt;
      puff.radius += 16 * dt;
    }
    _puffs.removeWhere((puff) => puff.age > puff.life);
  }

  @override
  void render(Canvas canvas) {
    for (final puff in _puffs) {
      final progress = puff.age / puff.life;
      if (progress >= 1) {
        continue;
      }
      canvas.drawCircle(
        Offset(puff.x, puff.y),
        puff.radius,
        Paint()
          ..isAntiAlias = true
          ..color = color.withValues(alpha: 0.45 * (1 - progress)),
      );
    }
  }
}

class _DustPuff {
  _DustPuff({
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

/// Fondo de las subidas: cielo, sol, nubes y colinas con parallax.
class _ClimbBackdrop extends Component {
  _ClimbBackdrop({
    required this.skyColor,
    required this.hillColor,
    required this.groundColor,
    required this.sunColor,
    required this.terrain,
  });

  final Color skyColor;
  final Color hillColor;
  final Color groundColor;
  final Color sunColor;
  final ClimbTerrain terrain;

  /// Tamano de la vista (lo actualiza el juego cada frame).
  Vector2 viewSize = Vector2(800, 600);

  @override
  void render(Canvas canvas) {
    final points = terrain.points;
    if (points.isEmpty) {
      return;
    }
    final width = viewSize.x;
    final height = viewSize.y;
    final fillPaint = Paint()..isAntiAlias = true;

    // Cielo con degradado.
    fillPaint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color.lerp(skyColor, const Color(0xFFFFFFFF), 0.35) ?? skyColor,
        skyColor,
        Color.lerp(skyColor, const Color(0xFF000000), 0.12) ?? skyColor,
      ],
    ).createShader(Rect.fromLTWH(0, 0, width, height));
    canvas.drawRect(Offset.zero & Size(width, height), fillPaint);
    fillPaint.shader = null;

    // Sol (o luna) con halo.
    final sun = Offset(width * 0.78, height * 0.18);
    fillPaint.color = sunColor.withValues(alpha: 0.22);
    canvas.drawCircle(sun, height * 0.18, fillPaint);
    fillPaint.color = sunColor;
    canvas.drawCircle(sun, height * 0.085, fillPaint);

    // Nubes con parallax.
    for (var i = 0; i < 5; i++) {
      final cloud = Offset(
        (i * 320.0 + 60) % (width + 200) - 100,
        height * (0.1 + (i % 3) * 0.07),
      );
      fillPaint.color = const Color(0xFFFFFFFF).withValues(alpha: 0.5);
      for (final part in <(double, double, double)>[
        (0, 0, 26),
        (22, 6, 20),
        (-22, 8, 18),
      ]) {
        canvas.drawCircle(
          cloud + Offset(part.$1, part.$2),
          part.$3,
          fillPaint,
        );
      }
    }

    // Tres capas de colinas con parallax.
    for (var layer = 0; layer < 3; layer++) {
      final amplitude = 70 - layer * 16;
      final baseY = height * (0.5 + layer * 0.1);
      final path = Path()..moveTo(0, height);
      for (var x = 0.0; x <= width + 40; x += 40) {
        final world = x + terrain.length * 0;
        final y = baseY -
            math.sin(world / (260 + layer * 150)) * amplitude -
            math.sin(world / (90 + layer * 40)) * (amplitude * 0.25);
        path.lineTo(x, y);
      }
      path
        ..lineTo(width + 40, height)
        ..close();
      fillPaint.color = hillColor.withValues(alpha: 0.28 + layer * 0.22);
      canvas.drawPath(path, fillPaint);
    }

    // Terreno: cuerpo de tierra con la superficie iluminada.
    final ground = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points) {
      ground.lineTo(point.dx, point.dy);
    }
    ground
      ..lineTo(points.last.dx, points.last.dy + 1400)
      ..lineTo(points.first.dx, points.first.dy + 1400)
      ..close();
    fillPaint.color = darken(groundColor, 0.22);
    canvas.drawPath(ground, fillPaint);

    // Capa superior (la "hierba" o la arena).
    final surface = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points) {
      surface.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      surface,
      Paint()
        ..isAntiAlias = true
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = groundColor,
    );

    // Pedruscos sobre la superficie.
    fillPaint.color = darken(groundColor, 0.35);
    for (var i = 0; i < points.length; i += 9) {
      final point = points[i];
      canvas.drawCircle(
        Offset(point.dx + 6, point.dy + 22),
        3 + (i % 3),
        fillPaint,
      );
    }
  }

  Color darken(Color color, double factor) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * (1 - factor)).clamp(0.0, 1.0))
        .toColor();
  }
}
