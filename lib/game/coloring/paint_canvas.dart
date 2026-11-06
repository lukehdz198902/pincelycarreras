import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../data/models/paint_stroke.dart';
import 'brush.dart';
import 'flood_fill.dart';

/// Tipo de particula de feedback.
enum SparkleKind {
  /// Chispa pequena.
  dot,

  /// Estrella de cuatro puntas.
  star,

  /// Onda de color expansiva (relleno del bote).
  wave,
}

/// Particula de feedback visual al pintar.
class Sparkle {
  /// Crea una particula.
  Sparkle({
    required this.position,
    required this.color,
    required this.life,
    required this.kind,
    this.velocity = Offset.zero,
  });

  /// Posicion en espacio de lamina.
  Offset position;

  /// Velocidad en pixeles de lamina por segundo.
  Offset velocity;

  /// Color de la particula.
  final Color color;

  /// Duracion total de la particula en segundos.
  final double life;

  /// Tipo de particula.
  final SparkleKind kind;

  /// Edad actual en segundos.
  double age = 0;

  /// `true` si la particula ya ha muerto.
  bool get isDead => age >= life;

  /// Avanza la particula un paso de [dt] segundos.
  void update(double dt) {
    age += dt;
    position += velocity * dt;
  }
}

/// Pinta el lienzo: fondo, rellenos de region, trazos y particulas.
class PaintCanvasPainter extends CustomPainter {
  /// Crea el pintor del lienzo.
  PaintCanvasPainter({
    required this.pageImage,
    required this.pageSize,
    required Listenable repaint,
  }) : super(repaint: repaint);

  /// Imagen de fondo de la lamina.
  ui.Image pageImage;

  /// Tamano logico de la lamina (en pixeles de lamina).
  Size pageSize;

  /// Dibujo actual.
  Painting painting = const Painting();

  /// Particulas de feedback activas.
  final List<Sparkle> sparkles = [];

  final Map<RegionFill, Path> _fillPaths = {};

  /// Sustituye el dibujo actual y limpia la cache de rutas.
  void updatePainting(Painting value) {
    painting = value;
    _fillPaths.clear();
  }

  /// Sustituye la lamina de fondo (al cambiar de pagina).
  ///
  /// Sin esto el lienzo seguia pintando la lamina anterior y, como esa
  /// imagen ya se habia liberado, la pantalla se quedaba **en blanco**.
  void updatePage(ui.Image image, Size size) {
    pageImage = image;
    pageSize = size;
    _fillPaths.clear();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / pageSize.width;
    final scaleY = size.height / pageSize.height;

    canvas.save();
    canvas.scale(scaleX, scaleY);
    canvas.drawImage(
      pageImage,
      Offset.zero,
      Paint()..filterQuality = FilterQuality.medium,
    );

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    for (final fill in painting.fills) {
      if (fill.isEmpty) {
        continue;
      }
      final path = _fillPaths.putIfAbsent(
        fill,
        () => buildSpansPath(fill.spans),
      );
      fillPaint.color = fill.color;
      canvas.drawPath(path, fillPaint);
    }

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    for (final stroke in painting.strokes) {
      if (stroke.kind == PaintStrokeKind.eraser || stroke.points.isEmpty) {
        continue;
      }
      strokePaint
        ..color = stroke.color
        ..strokeWidth = stroke.width;
      canvas.drawPath(buildStrokePath(stroke.points), strokePaint);
    }

    _paintSparkles(canvas);
    canvas.restore();
  }

  void _paintSparkles(Canvas canvas) {
    for (final sparkle in sparkles) {
      final progress = (sparkle.age / sparkle.life).clamp(0.0, 1.0);
      final opacity = (1 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = sparkle.color.withValues(alpha: opacity)
        ..isAntiAlias = true
        ..style = PaintingStyle.fill;

      switch (sparkle.kind) {
        case SparkleKind.dot:
          canvas.drawCircle(
            sparkle.position,
            6 * (1 - progress * 0.4),
            paint,
          );
        case SparkleKind.star:
          final radius = 14 * (1 - progress * 0.5);
          canvas.drawPath(
            buildStarPath(sparkle.position, radius, radius * 0.4),
            paint,
          );
        case SparkleKind.wave:
          final radius = 30 + progress * 90;
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = 10 * opacity;
          canvas.drawCircle(sparkle.position, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PaintCanvasPainter oldDelegate) => true;
}

/// Construye el camino de una region a partir de sus tramos.
Path buildSpansPath(List<Rect> spans) {
  final path = Path();
  for (final span in spans) {
    path.addRect(span);
  }
  return path;
}

/// Construye el camino suave de un trazo.
Path buildStrokePath(List<Offset> points) {
  final path = Path();
  if (points.isEmpty) {
    return path;
  }
  path.moveTo(points.first.dx, points.first.dy);
  if (points.length == 1) {
    path.lineTo(points.first.dx + 0.01, points.first.dy);
    return path;
  }
  for (var i = 1; i < points.length - 1; i++) {
    final current = points[i];
    final next = points[i + 1];
    path.quadraticBezierTo(
      current.dx,
      current.dy,
      (current.dx + next.dx) / 2,
      (current.dy + next.dy) / 2,
    );
  }
  path.lineTo(points.last.dx, points.last.dy);
  return path;
}

/// Construye una estrella de cuatro puntas.
Path buildStarPath(Offset center, double outer, double inner) {
  final path = Path();
  for (var i = 0; i < 8; i++) {
    final angle = -math.pi / 2 + i * math.pi / 4;
    final radius = i.isEven ? outer : inner;
    final point = Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// Lienzo de pintura del estudio.
///
/// Gestiona los gestos (pintar, rellenar, borrar) y delega el dibujo en
/// [PaintCanvasPainter].
class PaintCanvas extends StatefulWidget {
  /// Crea el lienzo.
  const PaintCanvas({
    super.key,
    required this.pageImage,
    required this.pageSize,
    required this.brush,
    required this.painting,
    required this.onPaintingChanged,
    this.onPaintFeedback,
  });

  /// Imagen de fondo de la lamina.
  final ui.Image pageImage;

  /// Tamano logico de la lamina.
  final Size pageSize;

  /// Pincel activo.
  final Brush brush;

  /// Dibujo actual.
  final Painting painting;

  /// Se invoca cuando el dibujo cambia.
  final ValueChanged<Painting> onPaintingChanged;

  /// Se invoca con la posicion en espacio de lamina tras cada accion.
  final void Function(Offset pagePosition, ToolKind kind)? onPaintFeedback;

  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas>
    with SingleTickerProviderStateMixin {
  late Painting _painting;
  late final PaintCanvasPainter _painter;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  final GlobalKey _paintKey = GlobalKey();
  PageRaster? _raster;
  List<Offset> _currentPoints = const [];
  List<Offset> _eraserTrail = const [];
  AnimationController? _sparkleController;
  int _lastSparkleIndex = 0;

  @override
  void initState() {
    super.initState();
    _painting = widget.painting;
    _painter = PaintCanvasPainter(
      pageImage: widget.pageImage,
      pageSize: widget.pageSize,
      repaint: _repaint,
    )..updatePainting(_painting);
    _decodeRaster();
  }

  @override
  void didUpdateWidget(covariant PaintCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.painting, widget.painting)) {
      _painting = widget.painting;
      _painter.updatePainting(_painting);
    }
    if (!identical(oldWidget.pageImage, widget.pageImage) ||
        oldWidget.pageSize != widget.pageSize) {
      // Cambio de lamina: el pintor y el raster (relleno por color) deben
      // apuntar a la nueva pagina.
      _painter.updatePage(widget.pageImage, widget.pageSize);
      _raster = null;
      unawaited(_decodeRaster());
    }
  }

  @override
  void dispose() {
    _sparkleController?.dispose();
    super.dispose();
  }

  Future<void> _decodeRaster() async {
    try {
      final data = await widget.pageImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (data == null || !mounted) {
        return;
      }
      final pixels = Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      _raster = PageRaster(
        pixels,
        widget.pageImage.width,
        widget.pageImage.height,
      );
    } catch (error) {
      debugPrint('[Pincel] No se pudo preparar el relleno por color: $error');
    }
  }

  Offset _toPage(Offset local) {
    // OJO: la conversion debe hacerse con el tamaño REAL del cuadro pintado.
    // Antes se usaba el del LayoutBuilder (toda la pantalla) y el trazo
    // salia desplazado: al tocar, se pintaba en otro sitio.
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    final size = box?.size;
    if (size == null || size.width == 0 || size.height == 0) {
      return local;
    }
    return Offset(
      local.dx / size.width * widget.pageSize.width,
      local.dy / size.height * widget.pageSize.height,
    );
  }

  void _onPanStart(DragStartDetails details) {
    final point = _toPage(details.localPosition);
    switch (widget.brush.kind) {
      case ToolKind.brush:
        _currentPoints = [point];
        widget.onPaintFeedback?.call(point, ToolKind.brush);
      case ToolKind.eraser:
        _eraserTrail = [point];
        _erase(point);
      case ToolKind.bucket:
        break;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = _toPage(details.localPosition);
    switch (widget.brush.kind) {
      case ToolKind.brush:
        _currentPoints = [..._currentPoints, point];
        _spawnSparkles(point);
        widget.onPaintFeedback?.call(point, ToolKind.brush);
      case ToolKind.eraser:
        _eraserTrail = [..._eraserTrail, point].length > 8
            ? [..._eraserTrail, point].sublist(1)
            : [..._eraserTrail, point];
        _erase(point);
      case ToolKind.bucket:
        break;
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (widget.brush.kind != ToolKind.brush || _currentPoints.isEmpty) {
      return;
    }
    final stroke = PaintStroke(
      points: List<Offset>.from(_currentPoints),
      colorValue: widget.brush.colorValue,
      width: widget.brush.width,
    );
    _currentPoints = const [];
    _update(_painting.copyWith(strokes: [..._painting.strokes, stroke]));
  }

  void _onTapDown(TapDownDetails details) {
    final point = _toPage(details.localPosition);
    switch (widget.brush.kind) {
      case ToolKind.bucket:
        _fill(point);
      case ToolKind.brush:
        final stroke = PaintStroke(
          points: [point],
          colorValue: widget.brush.colorValue,
          width: widget.brush.width,
        );
        _spawnSparkles(point);
        widget.onPaintFeedback?.call(point, ToolKind.brush);
        _update(_painting.copyWith(strokes: [..._painting.strokes, stroke]));
      case ToolKind.eraser:
        _eraserTrail = [point];
        _erase(point);
    }
  }

  void _fill(Offset point) {
    final raster = _raster;
    if (raster == null) {
      return;
    }
    final x = point.dx.round();
    final y = point.dy.round();
    final spans = raster.fillRegion(x, y);
    if (spans.isEmpty) {
      return;
    }
    // Si la region ya tiene ese color, no hacemos nada (evita parpadeos).
    final alreadyFilled = _painting.fills.any(
      (fill) =>
          fill.colorValue == widget.brush.colorValue &&
          _sameSpans(fill.spans, spans),
    );
    if (alreadyFilled) {
      return;
    }
    final fill = RegionFill(
      colorValue: widget.brush.colorValue,
      spans: spans,
    );
    _spawnWave(point);
    widget.onPaintFeedback?.call(point, ToolKind.bucket);
    _update(_painting.copyWith(fills: [..._painting.fills, fill]));
  }

  void _erase(Offset point) {
    const radius = 32.0;
    final strokes = <PaintStroke>[];
    for (final stroke in _painting.strokes) {
      if (stroke.kind == PaintStrokeKind.eraser) {
        continue;
      }
      strokes.addAll(_eraseStroke(stroke, radius));
    }
    final fills = _painting.fills
        .where((fill) => !_fillTouches(fill, point, radius))
        .toList();
    widget.onPaintFeedback?.call(point, ToolKind.eraser);
    _update(_painting.copyWith(strokes: strokes, fills: fills));
  }

  List<PaintStroke> _eraseStroke(PaintStroke stroke, double radius) {
    final result = <PaintStroke>[];
    var current = <Offset>[];
    for (final point in stroke.points) {
      if (_distanceToTrail(point) <= radius) {
        if (current.isNotEmpty) {
          result.add(stroke.copyWith(points: current));
          current = <Offset>[];
        }
      } else {
        current.add(point);
      }
    }
    if (current.isNotEmpty) {
      result.add(stroke.copyWith(points: current));
    }
    return result;
  }

  bool _fillTouches(RegionFill fill, Offset point, double radius) {
    for (final span in fill.spans) {
      if (span.inflate(radius).contains(point)) {
        return true;
      }
    }
    return false;
  }

  double _distanceToTrail(Offset point) {
    var minimum = double.infinity;
    for (var i = 0; i < _eraserTrail.length; i++) {
      final a = _eraserTrail[i];
      final b = i + 1 < _eraserTrail.length ? _eraserTrail[i + 1] : a;
      minimum = math.min(minimum, _distanceToSegment(point, a, b));
    }
    return minimum;
  }

  static double _distanceToSegment(Offset point, Offset a, Offset b) {
    final segment = b - a;
    final lengthSquared = segment.dx * segment.dx + segment.dy * segment.dy;
    if (lengthSquared == 0) {
      return (point - a).distance;
    }
    var t = ((point.dx - a.dx) * segment.dx + (point.dy - a.dy) * segment.dy) /
        lengthSquared;
    t = t.clamp(0.0, 1.0);
    final projection = a + segment * t;
    return (point - projection).distance;
  }

  static bool _sameSpans(List<Rect> a, List<Rect> b) {
    if (a.length != b.length || a.isEmpty) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }

  void _update(Painting painting) {
    setState(() {
      _painting = painting;
      _painter.updatePainting(painting);
    });
    widget.onPaintingChanged(painting);
  }

  void _spawnSparkles(Offset point) {
    _sparkleController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tickSparkles);
    _sparkleController!.repeat();
    final random = math.Random(point.dx.round() * 31 + point.dy.round());
    for (var i = 0; i < 2; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final speed = 40 + random.nextDouble() * 60;
      _painter.sparkles.add(
        Sparkle(
          position: point,
          color: i.isEven ? widget.brush.color : const Color(0xFFFFFFFF),
          life: 0.5,
          kind: SparkleKind.dot,
          velocity: Offset(math.cos(angle), math.sin(angle)) * speed,
        ),
      );
    }
    _lastSparkleIndex++;
    if (_lastSparkleIndex % 4 == 0) {
      _painter.sparkles.add(
        Sparkle(
          position: point,
          color: const Color(0xFFFFFFFF),
          life: 0.5,
          kind: SparkleKind.star,
        ),
      );
    }
  }

  void _spawnWave(Offset point) {
    _sparkleController ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_tickSparkles);
    _sparkleController!.repeat();
    _painter.sparkles.add(
      Sparkle(
        position: point,
        color: widget.brush.color,
        life: 0.6,
        kind: SparkleKind.wave,
      ),
    );
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2;
      _painter.sparkles.add(
        Sparkle(
          position: point,
          color: i.isEven ? widget.brush.color : const Color(0xFFFFFFFF),
          life: 0.55,
          kind: SparkleKind.star,
          velocity: Offset(math.cos(angle), math.sin(angle)) * 90,
        ),
      );
    }
  }

  void _tickSparkles() {
    final sparkles = _painter.sparkles;
    for (final sparkle in sparkles) {
      sparkle.update(1 / 60);
    }
    sparkles.removeWhere((sparkle) => sparkle.isDead);
    if (sparkles.isEmpty) {
      _sparkleController?.stop();
    }
    _repaint.value++;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: AspectRatio(
            aspectRatio: widget.pageSize.width / widget.pageSize.height,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTapDown: _onTapDown,
              child: CustomPaint(
                key: _paintKey,
                painter: _painter,
                size: Size.infinite,
              ),
            ),
          ),
        );
      },
    );
  }
}
