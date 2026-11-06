// Adornos del vehiculo: calcas (se colorean en tiempo de ejecucion) y
// personajes (el pasajero que viaja con el nino).
//
// Las calcas se dibujan en BLANCO: asi el nino puede pintarlas del color
// que quiera con un filtro de color en el juego.

import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'studio.dart';

/// Calca de rayas de racing.
void drawDecalStripes(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final paint = fill(const Color(0xFFFFFFFF));
  for (var i = 0; i < 3; i++) {
    final x = w * (0.2 + i * 0.25);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 0, w * 0.12, h),
        Radius.circular(w * 0.06),
      ),
      paint,
    );
  }
}

/// Calca de estrella.
void drawDecalStar(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  canvas.drawPath(
    starPath(center, size.width * 0.46, size.width * 0.2),
    fill(const Color(0xFFFFFFFF)),
  );
}

/// Calca de llama.
void drawDecalFlame(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final flame = Path()
    ..moveTo(w * 0.5, h * 0.05)
    ..cubicTo(w * 0.82, h * 0.38, w * 0.78, h * 0.8, w * 0.5, h * 0.96)
    ..cubicTo(w * 0.22, h * 0.8, w * 0.18, h * 0.38, w * 0.5, h * 0.05)
    ..close();
  canvas.drawPath(flame, fill(const Color(0xFFFFFFFF)));
  final inner = Path()
    ..moveTo(w * 0.5, h * 0.38)
    ..cubicTo(w * 0.66, h * 0.58, w * 0.62, h * 0.78, w * 0.5, h * 0.86)
    ..cubicTo(w * 0.38, h * 0.78, w * 0.34, h * 0.58, w * 0.5, h * 0.38)
    ..close();
  canvas.drawPath(inner, fill(const Color(0x33000000)));
}

/// Calca de corazon.
void drawDecalHeart(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  canvas.drawPath(
    heartPath(center, size.width * 0.92, size.height * 0.88),
    fill(const Color(0xFFFFFFFF)),
  );
}

/// Personaje gato (el pasajero).
void drawCharacterCat(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;

  // Orejas.
  for (final ear in [
    Path()
      ..moveTo(w * 0.26, h * 0.42)
      ..lineTo(w * 0.3, h * 0.1)
      ..lineTo(w * 0.48, h * 0.34)
      ..close(),
    Path()
      ..moveTo(w * 0.74, h * 0.42)
      ..lineTo(w * 0.7, h * 0.1)
      ..lineTo(w * 0.52, h * 0.34)
      ..close(),
  ]) {
    canvas.drawPath(ear, fill(StudioPalette.orange));
    canvas.drawPath(ear, stroke(StudioPalette.ink, 4));
  }

  // Cabeza.
  canvas.drawCircle(Offset(cx, h * 0.5), w * 0.28, fill(StudioPalette.orange));
  canvas.drawCircle(
    Offset(cx, h * 0.5),
    w * 0.28,
    stroke(StudioPalette.ink, 4),
  );

  // Ojos y hocico.
  for (final dx in [-0.09, 0.09]) {
    canvas.drawCircle(
      Offset(cx + w * dx, h * 0.44),
      w * 0.035,
      fill(StudioPalette.ink),
    );
  }
  canvas.drawCircle(Offset(cx, h * 0.55), w * 0.045, fill(const Color(0xFFFFB1B1)));
}

/// Personaje perro.
void drawCharacterDog(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;

  // Orejas caidas.
  for (final dx in [-0.26, 0.26]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * dx, h * 0.5),
        width: w * 0.2,
        height: h * 0.42,
      ),
      fill(StudioPalette.brown),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx + w * dx, h * 0.5),
        width: w * 0.2,
        height: h * 0.42,
      ),
      stroke(StudioPalette.ink, 4),
    );
  }

  canvas.drawCircle(Offset(cx, h * 0.5), w * 0.28, fill(StudioPalette.brown));
  canvas.drawCircle(
    Offset(cx, h * 0.5),
    w * 0.28,
    stroke(StudioPalette.ink, 4),
  );

  for (final dx in [-0.09, 0.09]) {
    canvas.drawCircle(
      Offset(cx + w * dx, h * 0.44),
      w * 0.035,
      fill(StudioPalette.ink),
    );
  }
  canvas.drawOval(
    Rect.fromCenter(
      center: Offset(cx, h * 0.58),
      width: w * 0.14,
      height: h * 0.1,
    ),
    fill(const Color(0xFFFFD7B0)),
  );
}

/// Personaje conejo.
void drawCharacterRabbit(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;

  for (final dx in [-0.1, 0.1]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + w * dx - w * 0.05, h * 0.04, w * 0.1, h * 0.4),
        Radius.circular(w * 0.05),
      ),
      fill(const Color(0xFFFFF3F5)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + w * dx - w * 0.05, h * 0.04, w * 0.1, h * 0.4),
        Radius.circular(w * 0.05),
      ),
      stroke(StudioPalette.ink, 4),
    );
  }

  canvas.drawCircle(Offset(cx, h * 0.58), w * 0.26, fill(const Color(0xFFFFF3F5)));
  canvas.drawCircle(
    Offset(cx, h * 0.58),
    w * 0.26,
    stroke(StudioPalette.ink, 4),
  );

  for (final dx in [-0.08, 0.08]) {
    canvas.drawCircle(
      Offset(cx + w * dx, h * 0.52),
      w * 0.032,
      fill(StudioPalette.ink),
    );
  }
  canvas.drawCircle(Offset(cx, h * 0.64), w * 0.04, fill(const Color(0xFFFF9AAE)));
}

/// Personaje robot.
void drawCharacterRobot(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.34, w * 0.56, h * 0.5),
      Radius.circular(w * 0.12),
    ),
    fill(const Color(0xFFB8C4E8)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.34, w * 0.56, h * 0.5),
      Radius.circular(w * 0.12),
    ),
    stroke(StudioPalette.ink, 4),
  );

  // Antena.
  canvas.drawLine(
    Offset(cx, h * 0.34),
    Offset(cx, h * 0.14),
    stroke(StudioPalette.ink, 4),
  );
  canvas.drawCircle(Offset(cx, h * 0.12), w * 0.06, fill(StudioPalette.red));

  // Ojos.
  for (final dx in [-0.1, 0.1]) {
    canvas.drawCircle(
      Offset(cx + w * dx, h * 0.52),
      w * 0.055,
      fill(StudioPalette.ink),
    );
  }
  // Boca.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - w * 0.1, h * 0.66, w * 0.2, h * 0.06),
      Radius.circular(w * 0.03),
    ),
    fill(StudioPalette.ink),
  );
}

/// Numero de racing (tres trazos) para la calca del=numero.
void drawRacingNumber(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  for (var i = 0; i < 3; i++) {
    final offset = i * h * 0.34;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.2, offset, w * 0.6, h * 0.16),
        Radius.circular(h * 0.08),
      ),
      fill(const Color(0xFFFFFFFF)),
    );
  }
}

