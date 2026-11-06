import 'dart:math' as math;
import 'dart:ui';

/// Tipo de tramo del terreno de las subidas.
enum ClimbSegmentKind {
  /// Tramo plano.
  flat,

  /// Colina suave (sube y baja).
  hill,

  /// Bache pequeno.
  bump,

  /// Rampa pronunciada.
  ramp,

  /// Vuelta completa de 360 grados.
  loop,
}

/// Tramo generado del terreno.
class ClimbSegment {
  /// Crea un tramo.
  const ClimbSegment({
    required this.kind,
    required this.startX,
    required this.startY,
    required this.length,
  });

  /// Tipo de tramo.
  final ClimbSegmentKind kind;

  /// X inicial en el mundo.
  final double startX;

  /// Y inicial en el mundo (negativo = mas arriba).
  final double startY;

  /// Longitud del tramo en pixeles.
  final double length;
}

/// Terreno de las subidas.
///
/// Se genera como una lista de puntos con su angulo (la tangente). Asi el
/// vehiculo puede "pegarse" al terreno, subir las colinas y dar la vuelta
/// completa a los loops.
///
/// Es codigo puro: se puede testear sin Flutter.
class ClimbTerrain {
  /// Crea el terreno.
  ///
  /// [seed] cambia el trazado y [loopCount] cuantos loops 360 grados
  /// incluye (lo mas entretenido).
  ClimbTerrain({
    required this.seed,
    this.loopCount = 1,
    this.flatLength = 420,
    this.hillLength = 460,
    this.hillHeight = 150,
    this.loopRadius = 130,
  }) : _random = math.Random(seed) {
    _build();
    computeAngles();
  }

  /// Semilla del trazado.
  final int seed;

  /// Numero de vueltas completas.
  final int loopCount;

  /// Longitud de los tramos planos.
  final double flatLength;

  /// Longitud de las colinas.
  final double hillLength;

  /// Altura de las colinas.
  final double hillHeight;

  /// Radio de los loops.
  final double loopRadius;

  /// Puntos de la superficie del terreno.
  final List<Offset> points = [];

  /// Longitud de arco acumulada en cada punto.
  ///
  /// Es la coordenada real del recorrido: **siempre crece**, incluso dentro
  /// de un loop (donde el vehiculo va hacia la izquierda en pantalla).
  final List<double> arcLengths = [];

  /// Tangente (radianes) en cada punto.
  final List<double> angles = [];

  /// Tramos generados (para depurar y testear).
  final List<ClimbSegment> segments = [];

  /// Longitud total del terreno (en pixeles de recorrido).
  double get length => arcLengths.isEmpty ? 0 : arcLengths.last;

  final math.Random _random;

  void _build() {
    var x = 0.0;
    var y = 0.0;
    var loop = 0;

    // Salida recta para que el vehiculo arranque con calma.
    _addFlat(x, y, flatLength * 0.6);
    x += flatLength * 0.6;

    while (x < 5200) {
      final roll = _random.nextInt(10);
      if (roll < 3 && loop < loopCount) {
        _addLoop(x, y);
        loop++;
        x += loopRadius * 2 + 40;
        // Tras el loop el terreno sigue mas arriba.
        y -= loopRadius * 2;
      } else if (roll < 6) {
        _addHill(x, y, hillHeight * (0.7 + _random.nextDouble() * 0.5));
        x += hillLength;
      } else if (roll < 8) {
        _addRamp(x, y);
        x += 380;
      } else {
        _addFlat(x, y, flatLength);
        x += flatLength;
      }
    }

    // Recta final: la meta esta en un tramo llano.
    _addFlat(x, y, flatLength);
  }

  void _addFlat(double x, double y, double length) {
    segments.add(
      ClimbSegment(
        kind: ClimbSegmentKind.flat,
        startX: x,
        startY: y,
        length: length,
      ),
    );
    const step = 12.0;
    for (var t = 0.0; t <= length; t += step) {
      _push(Offset(x + t, y));
    }
  }

  void _addHill(double x, double y, double height) {
    segments.add(
      ClimbSegment(
        kind: ClimbSegmentKind.hill,
        startX: x,
        startY: y,
        length: hillLength,
      ),
    );
    const step = 10.0;
    for (var t = 0.0; t <= hillLength; t += step) {
      final progress = t / hillLength;
      _push(Offset(x + t, y - math.sin(progress * math.pi) * height));
    }
  }

  /// Rampa: sube suave y cae de golpe.
  ///
  /// La caida brusca es la que **lanza al vehiculo**: al no poder seguir
  /// el terreno, despega y vuela hasta el siguiente punto.
  void _addRamp(double x, double y) {
    segments.add(
      ClimbSegment(
        kind: ClimbSegmentKind.ramp,
        startX: x,
        startY: y,
        length: 380,
      ),
    );
    const step = 8.0;
    for (var t = 0.0; t <= 380; t += step) {
      final progress = t / 380;
      // Sube rapido (0..0.55) y baja casi vertical (0.55..1).
      final height = progress < 0.55
          ? math.sin(progress / 0.55 * math.pi / 2) * 120
          : (1 - (progress - 0.55) / 0.45) * 120;
      _push(Offset(x + t, y - height));
    }
  }

  void _addLoop(double x, double y) {
    segments.add(
      ClimbSegment(
        kind: ClimbSegmentKind.loop,
        startX: x,
        startY: y,
        length: 2 * math.pi * loopRadius,
      ),
    );
    // El circulo se recorre en sentido antihorario: el vehiculo sube por
    // la derecha, pasa por arriba **del reves** y baja por la izquierda.
    final center = Offset(x, y - loopRadius);
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final angle = math.pi / 2 - (i / steps) * 2 * math.pi;
      _push(
        Offset(
          center.dx + math.cos(angle) * loopRadius,
          center.dy + math.sin(angle) * loopRadius,
        ),
      );
    }
  }

  void _push(Offset point) {
    if (points.isNotEmpty) {
      final last = points.last;
      if ((last.dx - point.dx).abs() < 0.01 &&
          (last.dy - point.dy).abs() < 0.01) {
        return;
      }
    }
    points.add(point);
    final previous = points.length >= 2 ? points[points.length - 2] : null;
    if (previous == null) {
      arcLengths.add(0);
    } else {
      arcLengths.add(arcLengths.last + (point - previous).distance);
    }
  }

  /// Recalcula las tangentes (se hace al terminar de generar).
  void computeAngles() {
    angles.clear();
    for (var i = 0; i < points.length; i++) {
      final previous = points[i == 0 ? 0 : i - 1];
      final next = points[i == points.length - 1 ? i : i + 1];
      final delta = next - previous;
      angles.add(math.atan2(delta.dy, delta.dx));
    }
  }
  /// Posicion del terreno a la distancia [s] (longitud de arco).
  Offset positionAt(double s) {
    if (points.isEmpty) {
      return Offset.zero;
    }
    if (s <= 0) {
      return points.first;
    }
    if (s >= length) {
      return points.last;
    }
    final index = _indexAt(s);
    final next = index + 1 < points.length ? index + 1 : index;
    final a = points[index];
    final b = points[next];
    final span = arcLengths[next] - arcLengths[index];
    final t = span <= 0 ? 0.0 : (s - arcLengths[index]) / span;
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }

  /// Angulo (radianes) del terreno a la distancia [s].
  double angleAt(double s) {
    if (points.isEmpty) {
      return 0;
    }
    if (s <= 0) {
      return angles.first;
    }
    if (s >= length) {
      return angles.last;
    }
    final index = _indexAt(s);
    final next = index + 1 < angles.length ? index + 1 : index;
    final a = angles[index];
    final b = angles[next];
    final span = arcLengths[next] - arcLengths[index];
    final t = span <= 0 ? 0.0 : (s - arcLengths[index]) / span;
    return a + (b - a) * t;
  }

  /// Indice del punto que corresponde a la longitud de arco [s].
  int _indexAt(double s) {
    var low = 0;
    var high = arcLengths.length - 1;
    while (low < high - 1) {
      final mid = (low + high) ~/ 2;
      if (arcLengths[mid] <= s) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return low;
  }
}



