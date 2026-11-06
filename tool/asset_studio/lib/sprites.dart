// Generadores de sprites: coches, obstaculos, coleccionables, iconos y pegatinas.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'studio.dart';

/// Dibuja un coche visto desde arriba (la camara es cenital).
///
/// [size] define el lienzo; el coche ocupa la mayor parte con margenes.
void drawCar(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 160;

  // Sombra difusa bajo el coche.
  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.9),
      width: w * 0.72,
      height: h * 0.12,
    ),
    sigma: 10 * scale,
  );

  final bodyRect = Rect.fromLTRB(w * 0.16, h * 0.1, w * 0.84, h * 0.9);
  final bodyRadius = Radius.circular(w * 0.25);

  // Ruedas (detras del cuerpo).
  final wheelPaint = fill(StudioPalette.tire);
  final wheelSize = Size(w * 0.12, h * 0.21);
  for (final wheelY in [h * 0.26, h * 0.63]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, wheelY, wheelSize.width, wheelSize.height),
        Radius.circular(w * 0.06),
      ),
      wheelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.78, wheelY, wheelSize.width, wheelSize.height),
        Radius.circular(w * 0.06),
      ),
      wheelPaint,
    );
  }

  // Carroceria.
  final bodyPath = Path()..addRRect(RRect.fromRectAndRadius(bodyRect, bodyRadius));
  canvas.drawPath(bodyPath, fill(color));

  // Brillo lateral suave (da volumen sin aristas).
  canvas.save();
  canvas.clipPath(bodyPath);
  canvas.drawRect(
    Rect.fromLTWH(w * 0.16, h * 0.1, w * 0.16, h * 0.8),
    fill(Color.fromRGBO(255, 255, 255, 0.18)),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.7, h * 0.1, w * 0.14, h * 0.8),
    fill(Color.fromRGBO(0, 0, 0, 0.10)),
  );
  canvas.restore();

  // Contorno.
  canvas.drawPath(
    bodyPath,
    stroke(darken(color, 0.35), 5 * scale),
  );

  // Techo.
  final roofRect = Rect.fromLTRB(w * 0.3, h * 0.32, w * 0.7, h * 0.68);
  canvas.drawRRect(
    RRect.fromRectAndRadius(roofRect, Radius.circular(w * 0.16)),
    fill(darken(color, 0.18)),
  );

  // Parabrisas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.34, h * 0.35, w * 0.66, h * 0.5),
      Radius.circular(w * 0.1),
    ),
    fill(const Color(0xFFCDEEFF)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.34, h * 0.55, w * 0.66, h * 0.65),
      Radius.circular(w * 0.08),
    ),
    fill(const Color(0xFFA9DDF7)),
  );

  // Franjas blancas de carrera (capo y maletero).
  final stripePaint = fill(Color.fromRGBO(255, 255, 255, 0.9));
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.05, h * 0.12, w * 0.1, h * 0.17),
      Radius.circular(w * 0.05),
    ),
    stripePaint,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.05, h * 0.73, w * 0.1, h * 0.14),
      Radius.circular(w * 0.05),
    ),
    stripePaint,
  );

  // Faros delanteros.
  final lampPaint = fill(const Color(0xFFFFF0A8));
  for (final lampX in [w * 0.22, w * 0.62]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampX, h * 0.13, w * 0.16, h * 0.09),
        Radius.circular(w * 0.05),
      ),
      lampPaint,
    );
  }

  // Pilotos traseros.
  for (final lampX in [w * 0.23, w * 0.63]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampX, h * 0.8, w * 0.14, h * 0.07),
        Radius.circular(w * 0.035),
      ),
      fill(const Color(0xFFFF6B6B)),
    );
  }
}

/// Banderin de vuelta (no es la meta final).
///
/// Es una banderita de tela con dos tonos: el niño la ve pasar y sabe que
/// el mundo sigue, pero no es el final.
void drawLapBanner(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  // Palo.
  canvas.drawRect(
    Rect.fromLTWH(w * 0.46, h * 0.06, w * 0.08, h * 0.88),
    fill(const Color(0xFF8A93A6)),
  );

  // Bandera triangular a dos tonos.
  final flag = Path()
    ..moveTo(w * 0.5, h * 0.1)
    ..lineTo(w * 0.96, h * 0.32)
    ..lineTo(w * 0.5, h * 0.54)
    ..close();
  canvas.drawPath(flag, fill(StudioPalette.yellow));
  canvas.drawPath(
    flag,
    stroke(darken(StudioPalette.yellow, 0.3), 5),
  );

  final flag2 = Path()
    ..moveTo(w * 0.5, h * 0.54)
    ..lineTo(w * 0.96, h * 0.76)
    ..lineTo(w * 0.5, h * 0.94)
    ..close();
  canvas.drawPath(flag2, fill(StudioPalette.green));
  canvas.drawPath(
    flag2,
    stroke(darken(StudioPalette.green, 0.3), 5),
  );

  // Punta del palo.
  canvas.drawCircle(
    Offset(w * 0.5, h * 0.06),
    w * 0.07,
    fill(StudioPalette.ink),
  );
}

/// Trofeo de la copa.
void drawStickerTrophy(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  const gold = Color(0xFFFFD700);

  // Copa.
  final cup = Path()
    ..moveTo(w * 0.3, h * 0.18)
    ..lineTo(w * 0.7, h * 0.18)
    ..quadraticBezierTo(w * 0.68, h * 0.55, cx, h * 0.6)
    ..quadraticBezierTo(w * 0.32, h * 0.55, w * 0.3, h * 0.18)
    ..close();
  canvas.drawPath(cup, fill(gold));
  canvas.drawPath(cup, stroke(darken(gold, 0.3), 6));

  // Asas.
  for (final side in [0.3, 0.7]) {
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w * side, h * 0.28),
        width: w * 0.22,
        height: h * 0.24,
      ),
      side < 0.5 ? -math.pi / 2 : math.pi / 2,
      math.pi,
      false,
      stroke(darken(gold, 0.2), 7),
    );
  }

  // Pie.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.42, h * 0.58, w * 0.16, h * 0.2),
      const Radius.circular(6),
    ),
    fill(darken(gold, 0.2)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.76, w * 0.44, h * 0.14),
      const Radius.circular(10),
    ),
    fill(darken(gold, 0.25)),
  );
}

/// Medalla de oro.
void drawStickerMedal(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  const gold = Color(0xFFFFD700);

  // Cintas.
  for (final side in [0.34, 0.66]) {
    canvas.drawPath(
      polygonPath([
        Offset(w * (side - 0.08), h * 0.06),
        Offset(w * (side + 0.08), h * 0.06),
        Offset(w * side, h * 0.5),
      ]),
      fill(side < 0.5 ? StudioPalette.red : StudioPalette.blue),
    );
  }

  // Medalla.
  canvas.drawCircle(Offset(w / 2, h * 0.62), w * 0.28, fill(gold));
  canvas.drawCircle(
    Offset(w / 2, h * 0.62),
    w * 0.28,
    stroke(darken(gold, 0.3), 6),
  );
  canvas.drawCircle(Offset(w / 2, h * 0.62), w * 0.17, fill(StudioPalette.yellow));
}

/// Cohete espacial.
void drawStickerRocket(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;

  final body = Path()
    ..moveTo(cx, h * 0.08)
    ..quadraticBezierTo(w * 0.72, h * 0.42, w * 0.66, h * 0.74)
    ..lineTo(w * 0.34, h * 0.74)
    ..quadraticBezierTo(w * 0.28, h * 0.42, cx, h * 0.08)
    ..close();
  canvas.drawPath(body, fill(StudioPalette.white));
  canvas.drawPath(body, stroke(StudioPalette.ink, 6));

  // Ventana.
  canvas.drawCircle(
    Offset(cx, h * 0.4),
    w * 0.12,
    fill(StudioPalette.cyan),
  );
  canvas.drawCircle(
    Offset(cx, h * 0.4),
    w * 0.12,
    stroke(StudioPalette.ink, 5),
  );

  // Aletas.
  for (final side in [0.3, 0.7]) {
    canvas.drawPath(
      polygonPath([
        Offset(w * (side - 0.1), h * 0.5),
        Offset(w * (side + 0.1), h * 0.74),
        Offset(w * side, h * 0.74),
      ]),
      fill(StudioPalette.red),
    );
  }

  // Llama.
  canvas.drawPath(
    Path()
      ..moveTo(w * 0.42, h * 0.74)
      ..quadraticBezierTo(cx, h * 0.98, w * 0.58, h * 0.74)
      ..close(),
    fill(StudioPalette.orange),
  );
}

/// Cometa con estela.
void drawStickerComet(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w * 0.66;
  final cy = h * 0.32;

  // Estela.
  final tail = Path()
    ..moveTo(cx - w * 0.08, cy + h * 0.06)
    ..quadraticBezierTo(w * 0.3, h * 0.5, w * 0.08, h * 0.74)
    ..quadraticBezierTo(w * 0.36, h * 0.5, cx - w * 0.08, cy - h * 0.06)
    ..close();
  canvas.drawPath(tail, fill(StudioPalette.cyan));
  canvas.drawPath(tail, stroke(darken(StudioPalette.cyan, 0.25), 5));

  // Nucleo.
  canvas.drawCircle(Offset(cx, cy), w * 0.2, fill(StudioPalette.yellow));
  canvas.drawCircle(
    Offset(cx, cy),
    w * 0.2,
    stroke(darken(StudioPalette.yellow, 0.3), 6),
  );
  canvas.drawCircle(
    Offset(cx, cy),
    w * 0.09,
    fill(StudioPalette.orange),
  );
}

/// Cono de trafico visto desde arriba.
void drawCone(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center, width: r * 1.6, height: r * 0.6),
    sigma: 7,
  );

  canvas.drawCircle(center, r * 0.92, fill(const Color(0xFFD9480F)));
  canvas.drawCircle(center, r * 0.76, fill(StudioPalette.orange));
  canvas.drawCircle(
    center,
    r * 0.5,
    stroke(StudioPalette.white, r * 0.2),
  );
  canvas.drawCircle(center, r * 0.24, fill(const Color(0xFFE8590C)));
}

/// Charco de agua.
void drawPuddle(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final rx = size.width / 2;
  final ry = size.height / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center, width: rx * 1.7, height: ry * 1.5),
    sigma: 6,
    color: const Color(0x33000000),
  );

  final blob = Path();
  for (var i = 0; i <= 48; i++) {
    final angle = i / 48 * 2 * math.pi;
    final wobble = 1 + 0.08 * math.sin(angle * 3) + 0.05 * math.cos(angle * 5);
    final point = Offset(
      center.dx + math.cos(angle) * rx * 0.92 * wobble,
      center.dy + math.sin(angle) * ry * 0.92 * wobble,
    );
    if (i == 0) {
      blob.moveTo(point.dx, point.dy);
    } else {
      blob.lineTo(point.dx, point.dy);
    }
  }
  blob.close();

  canvas.drawPath(blob, fill(const Color(0xFF2C7BBF)));
  canvas.drawPath(
    blob,
    stroke(const Color(0xFF1E5F97), size.width * 0.03),
  );

  // Brillo.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - rx * 0.3, center.dy - ry * 0.35),
      width: rx * 0.42,
      height: ry * 0.24,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.75)),
  );
}

/// Roca redondeada.
void drawRock(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center, width: r * 1.6, height: r * 0.6),
    sigma: 7,
  );

  final rock = Path();
  const sides = 9;
  for (var i = 0; i <= sides; i++) {
    final angle = i / sides * 2 * math.pi;
    final wobble = 1 + 0.12 * math.sin(angle * 2.3 + 0.7);
    final point = Offset(
      center.dx + math.cos(angle) * r * 0.86 * wobble,
      center.dy + math.sin(angle) * r * 0.86 * wobble,
    );
    if (i == 0) {
      rock.moveTo(point.dx, point.dy);
    } else {
      rock.lineTo(point.dx, point.dy);
    }
  }
  rock.close();

  canvas.drawPath(rock, fill(const Color(0xFF9AA5B1)));
  canvas.drawPath(rock, stroke(const Color(0xFF6B7683), size.width * 0.035));
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - r * 0.25, center.dy - r * 0.3),
      width: r * 0.5,
      height: r * 0.28,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.55)),
  );
}

/// Estrella coleccionable.
void drawStar(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center, width: r * 1.1, height: r * 0.4),
    sigma: 6,
    color: const Color(0x26000000),
  );

  final star = starPath(center, r * 0.86, r * 0.4);
  canvas.drawPath(star, fill(StudioPalette.yellow));
  canvas.drawPath(star, stroke(const Color(0xFFF08C00), size.width * 0.05));

  // Brillo y destellos.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - r * 0.22, center.dy - r * 0.26),
      width: r * 0.28,
      height: r * 0.16,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.8)),
  );
  for (final spark in <(Offset, double)>[
    (Offset(center.dx + r * 0.55, center.dy - r * 0.5), r * 0.16),
    (Offset(center.dx - r * 0.6, center.dy + r * 0.4), r * 0.12),
  ]) {
    final sparkle = starPath(spark.$1, spark.$2, spark.$2 * 0.35, points: 4);
    canvas.drawPath(sparkle, fill(Color.fromRGBO(255, 255, 255, 0.9)));
  }
}

/// Bandera de meta a cuadros.
void drawFinishBanner(Canvas canvas, ui.Size size) {
  final cell = size.height / 4;
  final cols = (size.width / cell).ceil();
  for (var row = 0; row < 4; row++) {
    for (var col = 0; col < cols; col++) {
      final isDark = (row + col).isEven;
      final rect = Rect.fromLTWH(col * cell, row * cell, cell, cell);
      canvas.drawRect(rect, fill(isDark ? StudioPalette.ink : StudioPalette.white));
    }
  }
  // Borde superior redondeado.
  canvas.drawRect(
    Rect.fromLTWH(0, 0, size.width, size.height * 0.12),
    fill(StudioPalette.ink),
  );
}

/// Icono de pincel.
void drawBrushIcon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  // Mango.
  canvas.drawLine(
    Offset(w * 0.16, h * 0.86),
    Offset(w * 0.6, h * 0.42),
    stroke(StudioPalette.brown, w * 0.16),
  );
  canvas.drawLine(
    Offset(w * 0.18, h * 0.82),
    Offset(w * 0.58, h * 0.41),
    stroke(lighten(StudioPalette.brown, 0.25), w * 0.06),
  );

  // Virola metalica.
  canvas.drawLine(
    Offset(w * 0.58, h * 0.44),
    Offset(w * 0.68, h * 0.34),
    stroke(const Color(0xFFC0C8D0), w * 0.2),
  );

  // Pincel con pintura.
  final tip = Path()
    ..moveTo(w * 0.64, h * 0.38)
    ..quadraticBezierTo(w * 0.8, h * 0.2, w * 0.94, h * 0.08)
    ..quadraticBezierTo(w * 0.98, h * 0.22, w * 0.78, h * 0.46)
    ..close();
  canvas.drawPath(tip, fill(StudioPalette.pink));
  canvas.drawPath(tip, stroke(const Color(0xFFD63FA0), w * 0.03));

  // Gota de pintura.
  final drop = Path()
    ..moveTo(w * 0.9, h * 0.06)
    ..quadraticBezierTo(w * 0.99, h * 0.2, w * 0.9, h * 0.24)
    ..quadraticBezierTo(w * 0.81, h * 0.2, w * 0.9, h * 0.06)
    ..close();
  canvas.drawPath(drop, fill(StudioPalette.pink));
}

/// Icono de coche (vista frontal).
void drawCarIcon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.86),
      width: w * 0.72,
      height: h * 0.14,
    ),
    sigma: 8,
  );

  // Ruedas.
  for (final x in [w * 0.1, w * 0.76]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, h * 0.6, w * 0.15, h * 0.28),
        Radius.circular(w * 0.07),
      ),
      fill(StudioPalette.tire),
    );
  }

  // Techo.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.24, w * 0.52, h * 0.28),
      Radius.circular(w * 0.14),
    ),
    fill(StudioPalette.blue),
  );
  // Parabrisas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.29, w * 0.4, h * 0.17),
      Radius.circular(w * 0.08),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  // Carroceria.
  final body = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.46, w * 0.72, h * 0.34),
        Radius.circular(w * 0.16),
      ),
    );
  canvas.drawPath(body, fill(StudioPalette.blue));
  canvas.drawPath(body, stroke(darken(StudioPalette.blue, 0.3), w * 0.035));

  // Faros.
  for (final x in [w * 0.22, w * 0.68]) {
    canvas.drawCircle(Offset(x, h * 0.6), w * 0.075, fill(const Color(0xFFFFF0A8)));
  }

  // Parachoques.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.72, w * 0.44, h * 0.08),
      Radius.circular(w * 0.04),
    ),
    fill(const Color(0xFFC0C8D0)),
  );
}

/// Icono de triangulo de play.
void drawPlayIcon(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center.translate(0, r * 0.12), width: r * 1.5, height: r * 0.5),
    sigma: 8,
  );
  canvas.drawCircle(center, r * 0.92, fill(StudioPalette.green));
  canvas.drawCircle(center, r * 0.92, stroke(darken(StudioPalette.green, 0.3), r * 0.07));

  final triangle = Path()
    ..moveTo(center.dx - r * 0.28, center.dy - r * 0.4)
    ..lineTo(center.dx + r * 0.42, center.dy)
    ..lineTo(center.dx - r * 0.28, center.dy + r * 0.4)
    ..close();
  canvas.drawPath(triangle, fill(StudioPalette.white));
}

/// Icono de pausa.
void drawPauseIcon(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center.translate(0, r * 0.12), width: r * 1.5, height: r * 0.5),
    sigma: 8,
  );
  canvas.drawCircle(center, r * 0.92, fill(StudioPalette.orange));
  canvas.drawCircle(center, r * 0.92, stroke(darken(StudioPalette.orange, 0.3), r * 0.07));

  for (final x in [center.dx - r * 0.28, center.dx + r * 0.08]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, center.dy - r * 0.38, r * 0.2, r * 0.76),
        Radius.circular(r * 0.08),
      ),
      fill(StudioPalette.white),
    );
  }
}

/// Icono de volver atras.
void drawBackIcon(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(center: center.translate(0, r * 0.12), width: r * 1.5, height: r * 0.5),
    sigma: 8,
  );
  canvas.drawCircle(center, r * 0.92, fill(StudioPalette.blue));
  canvas.drawCircle(center, r * 0.92, stroke(darken(StudioPalette.blue, 0.3), r * 0.07));

  final arrow = arrowPath(
    Rect.fromCenter(
      center: center,
      width: r * 1.0,
      height: r * 0.9,
    ),
  );
  canvas.drawPath(arrow, fill(StudioPalette.white));
}

/// Icono de libro (coleccion de pegatinas).
void drawBookIcon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.86),
      width: w * 0.8,
      height: h * 0.14,
    ),
    sigma: 8,
  );

  // Paginas.
  final leftPage = Path()
    ..moveTo(w * 0.5, h * 0.36)
    ..quadraticBezierTo(w * 0.3, h * 0.24, w * 0.1, h * 0.3)
    ..lineTo(w * 0.1, h * 0.76)
    ..quadraticBezierTo(w * 0.3, h * 0.7, w * 0.5, h * 0.82)
    ..close();
  final rightPage = Path()
    ..moveTo(w * 0.5, h * 0.36)
    ..quadraticBezierTo(w * 0.7, h * 0.24, w * 0.9, h * 0.3)
    ..lineTo(w * 0.9, h * 0.76)
    ..quadraticBezierTo(w * 0.7, h * 0.7, w * 0.5, h * 0.82)
    ..close();

  canvas.drawPath(leftPage, fill(StudioPalette.white));
  canvas.drawPath(rightPage, fill(StudioPalette.cream));
  canvas.drawPath(leftPage, stroke(StudioPalette.blue, w * 0.045));
  canvas.drawPath(rightPage, stroke(StudioPalette.blue, w * 0.045));

  // Estrella en la pagina.
  canvas.drawPath(
    starPath(Offset(w * 0.68, h * 0.5), w * 0.13, w * 0.06),
    fill(StudioPalette.yellow),
  );
  canvas.drawPath(
    starPath(Offset(w * 0.68, h * 0.5), w * 0.13, w * 0.06),
    stroke(const Color(0xFFF08C00), w * 0.025),
  );
}

/// Icono de bote de pintura.
void drawBucketIcon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.88),
      width: w * 0.7,
      height: h * 0.12,
    ),
    sigma: 8,
  );

  // Chorro de pintura multicolor.
  const paintColors = [
    StudioPalette.red,
    StudioPalette.yellow,
    StudioPalette.green,
    StudioPalette.cyan,
    StudioPalette.violet,
  ];
  for (var i = 0; i < paintColors.length; i++) {
    final x = w * (0.2 + i * 0.15);
    canvas.drawLine(
      Offset(x, h * 0.06),
      Offset(w * 0.5, h * 0.34),
      stroke(paintColors[i], w * 0.1),
    );
  }

  // Bote.
  final bucket = Path()
    ..moveTo(w * 0.28, h * 0.38)
    ..lineTo(w * 0.72, h * 0.38)
    ..lineTo(w * 0.64, h * 0.86)
    ..lineTo(w * 0.36, h * 0.86)
    ..close();
  canvas.drawPath(bucket, fill(const Color(0xFFC0C8D0)));
  canvas.drawPath(bucket, stroke(const Color(0xFF8A94A0), w * 0.035));

  // Pintura dentro.
  canvas.save();
  canvas.clipPath(bucket);
  canvas.drawRect(
    Rect.fromLTWH(w * 0.28, h * 0.38, w * 0.44, h * 0.16),
    fill(StudioPalette.pink),
  );
  canvas.restore();

  // Asa.
  canvas.drawArc(
    Rect.fromLTWH(w * 0.3, h * 0.12, w * 0.4, h * 0.5),
    math.pi,
    math.pi,
    false,
    stroke(const Color(0xFF8A94A0), w * 0.045),
  );
}

/// Icono de borrador.
void drawEraserIcon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.84),
      width: w * 0.66,
      height: h * 0.14,
    ),
    sigma: 8,
  );

  canvas.save();
  canvas.translate(w * 0.5, h * 0.5);
  canvas.rotate(-0.35);

  final block = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(-w * 0.32, -h * 0.16, w * 0.64, h * 0.32),
        Radius.circular(w * 0.1),
      ),
    );
  canvas.drawPath(block, fill(StudioPalette.pink));
  canvas.drawPath(block, stroke(const Color(0xFFD63FA0), w * 0.035));

  // Franja del otro color.
  canvas.save();
  canvas.clipPath(block);
  canvas.drawRect(
    Rect.fromLTWH(-w * 0.06, -h * 0.16, w * 0.12, h * 0.32),
    fill(const Color(0xFFC0C8D0)),
  );
  canvas.restore();
  canvas.restore();
}

/// Icono de estrella.
void drawStarIcon(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final r = size.width / 2;
  final star = starPath(center, r * 0.85, r * 0.4);
  canvas.drawPath(star, fill(StudioPalette.yellow));
  canvas.drawPath(star, stroke(const Color(0xFFF08C00), size.width * 0.05));
}

/// Dibuja un icono con borde blanco de pegatina.
void drawStickerFrame(Canvas canvas, Path shape, double width) {
  canvas.drawPath(shape, stroke(StudioPalette.white, width));
}

/// Pegatina: estrella.
void drawStickerStar(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final star = starPath(center, size.width * 0.34, size.width * 0.16);
  drawStickerFrame(canvas, star, size.width * 0.1);
  canvas.drawPath(star, fill(StudioPalette.yellow));
  canvas.drawPath(star, stroke(const Color(0xFFF08C00), size.width * 0.035));
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - size.width * 0.08, center.dy - size.height * 0.1),
      width: size.width * 0.1,
      height: size.height * 0.06,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.8)),
  );
}

/// Pegatina: corazon.
void drawStickerHeart(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final heart = heartPath(center, size.width * 0.46, size.width * 0.44);
  drawStickerFrame(canvas, heart, size.width * 0.1);
  canvas.drawPath(heart, fill(StudioPalette.red));
  canvas.drawPath(heart, stroke(const Color(0xFFD63FA0), size.width * 0.035));
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - size.width * 0.09, center.dy - size.height * 0.08),
      width: size.width * 0.1,
      height: size.height * 0.06,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.65)),
  );
}

/// Pegatina: arco iris.
void drawStickerRainbow(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  const colors = [
    StudioPalette.red,
    StudioPalette.orange,
    StudioPalette.yellow,
    StudioPalette.green,
    StudioPalette.cyan,
    StudioPalette.blue,
    StudioPalette.violet,
  ];

  // Nubes.
  for (final cx in [w * 0.24, w * 0.76]) {
    canvas.drawCircle(Offset(cx, h * 0.76), w * 0.13, fill(StudioPalette.white));
    canvas.drawCircle(Offset(cx + w * 0.1, h * 0.79), w * 0.1, fill(StudioPalette.white));
    canvas.drawCircle(Offset(cx - w * 0.1, h * 0.79), w * 0.1, fill(StudioPalette.white));
  }

  for (var i = 0; i < colors.length; i++) {
    final rect = Rect.fromLTWH(
      w * 0.16 + i * w * 0.012,
      h * 0.2 + i * h * 0.055,
      w * 0.68 - i * w * 0.024,
      h * 0.5,
    );
    canvas.drawArc(rect, math.pi, math.pi, false, stroke(colors[i], h * 0.055));
  }
}

/// Pegatina: corona.
void drawStickerCrown(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final crown = crownPath(Rect.fromLTWH(w * 0.16, h * 0.24, w * 0.68, h * 0.5));
  drawStickerFrame(canvas, crown, w * 0.1);
  canvas.drawPath(crown, fill(StudioPalette.yellow));
  canvas.drawPath(crown, stroke(const Color(0xFFE0A800), w * 0.035));

  for (final jewel in [
    Offset(w * 0.3, h * 0.62),
    Offset(w * 0.5, h * 0.55),
    Offset(w * 0.7, h * 0.62),
  ]) {
    canvas.drawCircle(jewel, w * 0.055, fill(StudioPalette.red));
    canvas.drawCircle(jewel, w * 0.055, stroke(const Color(0xFFD63FA0), w * 0.018));
  }
}

/// Pegatina: flecha.
void drawStickerArrow(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  canvas.save();
  canvas.translate(w / 2, h / 2);
  canvas.rotate(math.pi);
  final arrow = arrowPath(Rect.fromLTWH(-w * 0.3, -h * 0.24, w * 0.6, h * 0.48));
  drawStickerFrame(canvas, arrow, w * 0.1);
  canvas.drawPath(arrow, fill(StudioPalette.orange));
  canvas.drawPath(arrow, stroke(const Color(0xFFD9480F), w * 0.035));
  canvas.restore();
}

/// Pegatina: globo.
void drawStickerBalloon(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final center = Offset(w * 0.5, h * 0.42);

  // Cuerda.
  final string = Path()
    ..moveTo(w * 0.5, h * 0.62)
    ..quadraticBezierTo(w * 0.58, h * 0.76, w * 0.5, h * 0.9);
  canvas.drawPath(string, stroke(const Color(0xFF8A94A0), w * 0.025));

  final balloon = Path()
    ..addOval(Rect.fromCenter(center: center, width: w * 0.5, height: h * 0.56));
  drawStickerFrame(canvas, balloon, w * 0.09);
  canvas.drawPath(balloon, fill(StudioPalette.red));
  canvas.drawPath(balloon, stroke(const Color(0xFFD63FA0), w * 0.035));

  // Reflejo.
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(center.dx - w * 0.1, center.dy - h * 0.1),
      width: w * 0.1,
      height: h * 0.13,
    ),
    fill(Color.fromRGBO(255, 255, 255, 0.65)),
  );

  // Nudillo.
  canvas.drawCircle(Offset(w * 0.5, h * 0.63), w * 0.05, fill(StudioPalette.red));
}
