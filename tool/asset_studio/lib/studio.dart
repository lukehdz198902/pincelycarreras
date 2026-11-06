// Utilidades compartidas del estudio de assets de "Pincel & Carreras".
//
// Todo el arte del juego se genera aquí de forma reproducible: no hay
// ficheros binarios editados a mano ni placeholders descargados.

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Paleta maestra del juego.
///
/// Debe mantenerse sincronizada con `lib/core/constants/palette.dart`.
class StudioPalette {
  const StudioPalette._();

  static const Color red = Color(0xFFFF4757);
  static const Color orange = Color(0xFFFF922B);
  static const Color yellow = Color(0xFFFFD32A);
  static const Color green = Color(0xFF2ED573);
  static const Color lime = Color(0xFFA3E635);
  static const Color cyan = Color(0xFF18DCF0);
  static const Color blue = Color(0xFF4D8DFF);
  static const Color violet = Color(0xFF9C5CFF);
  static const Color pink = Color(0xFFFF6BD6);
  static const Color brown = Color(0xFFB07344);
  static const Color ink = Color(0xFF2B2D42);
  static const Color cream = Color(0xFFFFF6E9);
  static const Color white = Color(0xFFFFFFFF);

  /// Papel de las laminas para colorear (difiere del blanco de la paleta).
  static const Color paper = Color(0xFFF2E6CF);

  /// Contorno de las laminas: separa las regiones para el relleno por color.
  static const Color outline = Color(0xFF6B6F76);

  /// Asfalto de las pistas.
  static const Color asphalt = Color(0xFF3A3F55);

  /// Gris de las ruedas.
  static const Color tire = Color(0xFF2B2D42);
}

/// Devuelve un color oscurecido (factor 0..1) conservando el tono.
Color darken(Color color, double factor) {
  assert(factor >= 0 && factor <= 1);
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness * (1 - factor)).clamp(0.0, 1.0))
      .toColor();
}

/// Devuelve un color aclarado (factor 0..1) conservando el tono.
Color lighten(Color color, double factor) {
  assert(factor >= 0 && factor <= 1);
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + (1 - hsl.lightness) * factor)
          .clamp(0.0, 1.0))
      .toColor();
}

/// Aclara u oscurece segun [amount] (positivo aclara, negativo oscurece).
Color shade(Color color, double amount) =>
    amount >= 0 ? lighten(color, amount) : darken(color, -amount);

/// Relleno opaco.
Paint fill(Color color) => Paint()
  ..color = color
  ..style = PaintingStyle.fill
  ..isAntiAlias = true;

/// Contorno suave.
Paint stroke(Color color, double width) => Paint()
  ..color = color
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..isAntiAlias = true;

/// Pintura con sombra difusa (estilo cartoon: nunca sombra dura).
Paint shadowPaint(Color color, double sigma) => Paint()
  ..color = color
  ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma)
  ..isAntiAlias = true;

/// Rectangulo redondeado como [Path].
Path roundRectPath(Rect rect, double radius) =>
    Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

/// Poligono cerrado a partir de una lista de puntos.
Path polygonPath(List<Offset> points) {
  final path = Path();
  if (points.isEmpty) {
    return path;
  }
  path.moveTo(points.first.dx, points.first.dy);
  for (final point in points.skip(1)) {
    path.lineTo(point.dx, point.dy);
  }
  return path..close();
}

/// Estrella de [points] puntas centrada en [center].
Path starPath(
  Offset center,
  double outerRadius,
  double innerRadius, {
  int points = 5,
  double rotation = -math.pi / 2,
}) {
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outerRadius : innerRadius;
    final angle = rotation + i * math.pi / points;
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

/// Corazon centrado en [center].
Path heartPath(Offset center, double width, double height) {
  final path = Path();
  final w = width / 2;
  final h = height / 2;
  path.moveTo(center.dx, center.dy + h * 0.95);
  path.cubicTo(
    center.dx - w * 1.25,
    center.dy + h * 0.05,
    center.dx - w * 0.55,
    center.dy - h * 0.95,
    center.dx,
    center.dy - h * 0.25,
  );
  path.cubicTo(
    center.dx + w * 0.55,
    center.dy - h * 0.95,
    center.dx + w * 1.25,
    center.dy + h * 0.05,
    center.dx,
    center.dy + h * 0.95,
  );
  return path..close();
}

/// Arco iris con [bands] bandas de arriba abajo.
Path rainbowPath(Rect rect, int bands) {
  final path = Path();
  final bandHeight = rect.height / bands;
  for (var i = 0; i < bands; i++) {
    final band = Rect.fromLTWH(
      rect.left,
      rect.top + i * bandHeight,
      rect.width,
      bandHeight * 1.6,
    );
    path.addArc(band, math.pi, math.pi);
  }
  return path;
}

/// Nube cartoon con contorno suave y una sola silueta cerrada.
Path cloudPath(Offset center, double width, double height) {
  final w = width / 2;
  final h = height / 2;
  final path = Path()
    ..moveTo(center.dx - w * 0.9, center.dy + h * 0.3)
    ..cubicTo(
      center.dx - w * 1.05,
      center.dy - h * 0.2,
      center.dx - w * 0.6,
      center.dy - h * 0.8,
      center.dx - w * 0.15,
      center.dy - h * 0.35,
    )
    ..cubicTo(
      center.dx + w * 0.05,
      center.dy - h * 1.05,
      center.dx + w * 0.78,
      center.dy - h * 0.9,
      center.dx + w * 0.8,
      center.dy - h * 0.3,
    )
    ..cubicTo(
      center.dx + w * 1.05,
      center.dy - h * 0.15,
      center.dx + w * 1.0,
      center.dy + h * 0.4,
      center.dx + w * 0.78,
      center.dy + h * 0.42,
    )
    ..lineTo(center.dx - w * 0.78, center.dy + h * 0.42)
    ..cubicTo(
      center.dx - w * 1.0,
      center.dy + h * 0.4,
      center.dx - w * 1.02,
      center.dy + h * 0.25,
      center.dx - w * 0.9,
      center.dy + h * 0.3,
    )
    ..close();
  return path;
}

/// Flor de [petals] petalos como silueta unica.
Path flowerPath(Offset center, double radius, {int petals = 5}) {
  final path = Path();
  const samples = 48;
  for (var i = 0; i <= samples; i++) {
    final angle = i / samples * 2 * math.pi;
    final petal = 0.74 + 0.26 * math.cos(angle * petals);
    final point = Offset(
      center.dx + math.cos(angle) * radius * petal,
      center.dy + math.sin(angle) * radius * petal,
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// Flecha gruesa apuntando a la izquierda.
Path arrowPath(Rect rect) {
  final w = rect.width;
  final h = rect.height;
  return polygonPath([
    Offset(rect.left, rect.top + h * 0.5),
    Offset(rect.left + w * 0.45, rect.top),
    Offset(rect.left + w * 0.45, rect.top + h * 0.28),
    Offset(rect.right, rect.top + h * 0.28),
    Offset(rect.right, rect.bottom - h * 0.28),
    Offset(rect.left + w * 0.45, rect.bottom - h * 0.28),
    Offset(rect.left + w * 0.45, rect.bottom),
  ]);
}

/// Corona de [tips] puntas.
Path crownPath(Rect rect) {
  final w = rect.width;
  final h = rect.height;
  return polygonPath([
    Offset(rect.left, rect.bottom),
    Offset(rect.left, rect.top + h * 0.15),
    Offset(rect.left + w * 0.25, rect.top + h * 0.45),
    Offset(rect.left + w * 0.5, rect.top),
    Offset(rect.left + w * 0.75, rect.top + h * 0.45),
    Offset(rect.right, rect.top + h * 0.15),
    Offset(rect.right, rect.bottom),
  ]);
}

/// Dibuja una sombra difusa bajo [shape].
void drawSoftShadow(
  Canvas canvas,
  Path shape, {
  Offset offset = const Offset(0, 6),
  double sigma = 9,
  Color color = const Color(0x33000000),
}) {
  canvas.save();
  canvas.translate(offset.dx, offset.dy);
  canvas.drawPath(shape, shadowPaint(color, sigma));
  canvas.restore();
}

/// Dibuja una sombra eliptica difusa (sombra de objetos sobre el suelo).
void drawEllipseShadow(
  Canvas canvas,
  Rect rect, {
  double sigma = 8,
  Color color = const Color(0x40000000),
}) {
  canvas.drawOval(rect, shadowPaint(color, sigma));
}

/// Raiz del proyecto "pincel_y_carreras" (buscando el pubspec correcto).
Directory resolveProjectRoot() {
  var dir = Directory.current;
  while (true) {
    final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: pincel_y_carreras')) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('No se encuentra el proyecto pincel_y_carreras.');
    }
    dir = parent;
  }
}

/// Renderiza [draw] en un canvas y guarda el resultado como PNG en [path].
Future<void> writePng(
  String path,
  ui.Size size,
  void Function(Canvas canvas) draw,
) async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  draw(canvas);
  final picture = recorder.endRecording();

  final image = await picture.toImage(
    size.width.round(),
    size.height.round(),
  );
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();

  if (byteData == null) {
    throw StateError('No se pudo codificar el PNG de $path');
  }

  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
}

/// Metodo auxiliar para dibujar texto (etiquetas internas de los assets).
void drawLabel(
  Canvas canvas,
  String text,
  Offset center, {
  double size = 28,
  Color color = StudioPalette.ink,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    center - Offset(painter.width / 2, painter.height / 2),
  );
}
