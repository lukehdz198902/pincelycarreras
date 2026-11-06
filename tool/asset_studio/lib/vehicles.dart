// Vehiculos vistos desde arriba: moto, camion, furgoneta, tractor y bus.
//
// La camara del juego es cenital, asi que todos los vehiculos se dibujan
// desde arriba. El estilo es el mismo que el coche: cartoon redondeado,
// contorno grueso y sombra difusa.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'studio.dart';

/// Ruedas de un vehiculo visto desde arriba.
///
/// [width] y [height] son la medida de cada rueda.
void _drawWheelPair(
  Canvas canvas,
  ui.Size size, {
  required double top,
  required double bottom,
  required double wheelWidth,
  required double wheelHeight,
  required double inset,
}) {
  final paint = fill(StudioPalette.tire);
  for (final wheelY in [top, bottom]) {
    for (final side in [0.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            size.width * (inset + side * (1 - inset * 2)),
            size.height * wheelY,
            size.width * wheelWidth,
            size.height * wheelHeight,
          ),
          Radius.circular(size.width * wheelWidth * 0.35),
        ),
        paint,
      );
    }
  }
}

/// Moto vista desde arriba.
void drawMoto(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 110;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.88),
      width: w * 0.6,
      height: h * 0.1,
    ),
    sigma: 8 * scale,
  );

  _drawWheelPair(
    canvas,
    size,
    top: 0.12,
    bottom: 0.66,
    wheelWidth: 0.16,
    wheelHeight: 0.2,
    inset: 0.06,
  );

  // Cuadro de la moto.
  final bodyPath = Path()
    ..moveTo(cx, h * 0.06)
    ..quadraticBezierTo(w * 0.78, h * 0.3, w * 0.66, h * 0.62)
    ..quadraticBezierTo(w * 0.6, h * 0.82, cx, h * 0.9)
    ..quadraticBezierTo(w * 0.4, h * 0.82, w * 0.34, h * 0.62)
    ..quadraticBezierTo(w * 0.22, h * 0.3, cx, h * 0.06)
    ..close();
  canvas.drawPath(bodyPath, fill(color));
  canvas.drawPath(bodyPath, stroke(darken(color, 0.35), 5 * scale));

  // Manillar.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.1, w * 0.64, h * 0.07),
      Radius.circular(w * 0.06),
    ),
    fill(darken(color, 0.45)),
  );

  // Faro.
  canvas.drawCircle(Offset(cx, h * 0.09), w * 0.13, fill(const Color(0xFFFFF0A8)));
  canvas.drawCircle(
    Offset(cx, h * 0.09),
    w * 0.13,
    stroke(darken(color, 0.35), 4 * scale),
  );

  // Piloto.
  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.38),
      width: w * 0.26,
      height: h * 0.08,
    ),
    sigma: 5 * scale,
  );
  canvas.drawCircle(Offset(cx, h * 0.36), w * 0.15, fill(const Color(0xFF3A3F55)));
  canvas.drawCircle(
    Offset(cx, h * 0.36),
    w * 0.15,
    stroke(StudioPalette.ink, 4 * scale),
  );
  canvas.drawCircle(
    Offset(cx, h * 0.345),
    w * 0.1,
    fill(const Color(0xFFFFD7B0)),
  );

  // Asiento.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.36, h * 0.48, w * 0.28, h * 0.2),
      Radius.circular(w * 0.1),
    ),
    fill(darken(color, 0.4)),
  );
}

/// Coche de perfil SIN ruedas (modo "Subidas").
///
/// Las ruedas van aparte (`drawSideWheel`) para poder **girarlas** con la
/// velocidad: asi el vehiculo parece de verdad en movimiento.
void drawSideCarBody(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final scale = w / 240;

  // Carroceria: capo, habitaculo y maletero.
  final body = Path()
    ..moveTo(w * 0.06, h * 0.72)
    ..lineTo(w * 0.08, h * 0.48)
    ..quadraticBezierTo(w * 0.12, h * 0.4, w * 0.24, h * 0.38)
    ..lineTo(w * 0.34, h * 0.38)
    ..lineTo(w * 0.44, h * 0.16)
    ..quadraticBezierTo(w * 0.48, h * 0.1, w * 0.56, h * 0.1)
    ..lineTo(w * 0.7, h * 0.1)
    ..quadraticBezierTo(w * 0.78, h * 0.1, w * 0.82, h * 0.2)
    ..lineTo(w * 0.9, h * 0.4)
    ..quadraticBezierTo(w * 0.96, h * 0.44, w * 0.96, h * 0.54)
    ..lineTo(w * 0.96, h * 0.72)
    ..close();
  canvas.drawPath(body, fill(color));
  canvas.drawPath(body, stroke(darken(color, 0.35), 6 * scale));

  // Ventanas.
  final window = Path()
    ..moveTo(w * 0.47, h * 0.38)
    ..lineTo(w * 0.53, h * 0.2)
    ..lineTo(w * 0.62, h * 0.19)
    ..lineTo(w * 0.66, h * 0.38)
    ..close();
  canvas.drawPath(window, fill(const Color(0xFFCDEEFF)));
  canvas.drawPath(window, stroke(darken(color, 0.4), 4 * scale));

  final rearWindow = Path()
    ..moveTo(w * 0.68, h * 0.38)
    ..lineTo(w * 0.73, h * 0.21)
    ..lineTo(w * 0.79, h * 0.3)
    ..lineTo(w * 0.82, h * 0.38)
    ..close();
  canvas.drawPath(rearWindow, fill(const Color(0xFFCDEEFF)));
  canvas.drawPath(rearWindow, stroke(darken(color, 0.4), 4 * scale));

  // Conductor: cabeza con casco.
  canvas.drawCircle(
    Offset(w * 0.57, h * 0.29),
    w * 0.055,
    fill(const Color(0xFFFFD7B0)),
  );
  canvas.drawPath(
    Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(w * 0.57, h * 0.28),
          width: w * 0.12,
          height: h * 0.12,
        ),
        math.pi,
        math.pi * 2,
      ),
    fill(StudioPalette.ink),
  );

  // Faro y piloto.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.9, h * 0.46, w * 0.05, h * 0.09),
      const Radius.circular(8),
    ),
    fill(const Color(0xFFFFF0A8)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.06, h * 0.48, w * 0.035, h * 0.08),
      const Radius.circular(8),
    ),
    fill(const Color(0xFFFF6B6B)),
  );

  // Aleron.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.36, w * 0.1, h * 0.05),
      const Radius.circular(8),
    ),
    fill(darken(color, 0.3)),
  );

  // Escape.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.02, h * 0.62, w * 0.05, h * 0.035),
      const Radius.circular(8),
    ),
    fill(const Color(0xFF9AA3B8)),
  );
}

/// Rueda de perfil (modo "Subidas").
///
/// Se dibuja aparte para poder girarla con la velocidad del vehiculo.
void drawSideWheel(Canvas canvas, ui.Size size) {
  final center = Offset(size.width / 2, size.height / 2);
  final radius = size.width * 0.44;

  canvas.drawCircle(center, radius, fill(StudioPalette.tire));
  canvas.drawCircle(center, radius, stroke(StudioPalette.ink, 5));
  canvas.drawCircle(center, radius * 0.52, fill(const Color(0xFFE8EAF0)));
  canvas.drawCircle(center, radius * 0.52, stroke(StudioPalette.ink, 3));

  // Radios: dan la sensacion de rueda girando.
  final paint = stroke(StudioPalette.ink, 3);
  for (var i = 0; i < 5; i++) {
    final angle = i / 5 * math.pi * 2;
    canvas.drawLine(
      center,
      center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.5,
      paint,
    );
  }
  canvas.drawCircle(center, radius * 0.16, fill(StudioPalette.ink));
}

/// Camion de bomberos visto desde arriba.
void drawTruck(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 180;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.92),
      width: w * 0.82,
      height: h * 0.1,
    ),
    sigma: 10 * scale,
  );

  _drawWheelPair(
    canvas,
    size,
    top: 0.12,
    bottom: 0.72,
    wheelWidth: 0.12,
    wheelHeight: 0.17,
    inset: 0.03,
  );

  // Chasis.
  final bodyPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.06, w * 0.76, h * 0.88),
        Radius.circular(w * 0.14),
      ),
    );
  canvas.drawPath(bodyPath, fill(color));
  canvas.drawPath(bodyPath, stroke(darken(color, 0.35), 6 * scale));

  // Cabina (delante).
  final cabPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.18, h * 0.08, w * 0.64, h * 0.26),
        Radius.circular(w * 0.1),
      ),
    );
  canvas.drawPath(cabPath, fill(darken(color, 0.18)));
  canvas.drawPath(cabPath, stroke(darken(color, 0.4), 4 * scale));

  // Parabrisas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.24, h * 0.11, w * 0.52, h * 0.14),
      Radius.circular(w * 0.06),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  // Escalera de rescate.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.4, w * 0.44, h * 0.44),
      Radius.circular(w * 0.04),
    ),
    fill(const Color(0xFFE8EAF0)),
  );
  for (var i = 0; i < 6; i++) {
    canvas.drawLine(
      Offset(w * 0.3, h * (0.42 + i * 0.07)),
      Offset(w * 0.7, h * (0.42 + i * 0.07)),
      stroke(const Color(0xFF9AA3B8), 3 * scale),
    );
  }

  // Focos dewarning.
  for (final lampX in [w * 0.26, w * 0.74]) {
    canvas.drawCircle(Offset(lampX, h * 0.06), w * 0.05, fill(const Color(0xFFFF6B6B)));
    canvas.drawCircle(
      Offset(lampX, h * 0.06),
      w * 0.05,
      stroke(darken(color, 0.35), 3 * scale),
    );
  }
}

/// Furgoneta de reparto vista desde arriba.
void drawVan(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 175;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.92),
      width: w * 0.8,
      height: h * 0.1,
    ),
    sigma: 10 * scale,
  );

  _drawWheelPair(
    canvas,
    size,
    top: 0.14,
    bottom: 0.72,
    wheelWidth: 0.12,
    wheelHeight: 0.18,
    inset: 0.03,
  );

  // Carroceria.
  final bodyPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.05, w * 0.76, h * 0.9),
        Radius.circular(w * 0.16),
      ),
    );
  canvas.drawPath(bodyPath, fill(color));
  canvas.drawPath(bodyPath, stroke(darken(color, 0.35), 6 * scale));

  // Cabina y parabrisas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.08, w * 0.6, h * 0.24),
      Radius.circular(w * 0.1),
    ),
    fill(darken(color, 0.16)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.26, h * 0.11, w * 0.48, h * 0.13),
      Radius.circular(w * 0.05),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  // Caja de reparto con etiqueta.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.38, w * 0.56, h * 0.48),
      Radius.circular(w * 0.06),
    ),
    fill(StudioPalette.white),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.22, h * 0.38, w * 0.56, h * 0.48),
      Radius.circular(w * 0.06),
    ),
    stroke(darken(color, 0.35), 4 * scale),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.3, h * 0.52, w * 0.4, h * 0.2),
    fill(const Color(0xFFFFD32A)),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.3, h * 0.52, w * 0.4, h * 0.2),
    stroke(darken(color, 0.35), 3 * scale),
  );
}

/// Tractor visto desde arriba.
void drawTractor(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 170;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.9),
      width: w * 0.8,
      height: h * 0.1,
    ),
    sigma: 9 * scale,
  );

  // Ruedas Traseras grandes.
  canvas.drawCircle(Offset(w * 0.26, h * 0.7), w * 0.19, fill(StudioPalette.tire));
  canvas.drawCircle(
    Offset(w * 0.26, h * 0.7),
    w * 0.19,
    stroke(StudioPalette.ink, 5 * scale),
  );
  canvas.drawCircle(Offset(w * 0.26, h * 0.7), w * 0.075, fill(const Color(0xFF8A93A6)));
  canvas.drawCircle(Offset(w * 0.74, h * 0.7), w * 0.19, fill(StudioPalette.tire));
  canvas.drawCircle(
    Offset(w * 0.74, h * 0.7),
    w * 0.19,
    stroke(StudioPalette.ink, 5 * scale),
  );
  canvas.drawCircle(Offset(w * 0.74, h * 0.7), w * 0.075, fill(const Color(0xFF8A93A6)));

  // Ruedas delanteras pequenas.
  for (final wheelX in [w * 0.38, w * 0.62]) {
    canvas.drawCircle(
      Offset(wheelX, h * 0.22),
      w * 0.11,
      fill(StudioPalette.tire),
    );
    canvas.drawCircle(
      Offset(wheelX, h * 0.22),
      w * 0.11,
      stroke(StudioPalette.ink, 4 * scale),
    );
  }

  // Capo.
  final hoodPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.12, w * 0.4, h * 0.38),
        Radius.circular(w * 0.1),
      ),
    );
  canvas.drawPath(hoodPath, fill(color));
  canvas.drawPath(hoodPath, stroke(darken(color, 0.35), 5 * scale));

  // Asiento y volante.
  canvas.drawCircle(Offset(cx, h * 0.56), w * 0.11, fill(darken(color, 0.45)));
  canvas.drawCircle(
    Offset(cx, h * 0.56),
    w * 0.11,
    stroke(StudioPalette.ink, 4 * scale),
  );
  canvas.drawCircle(Offset(cx, h * 0.4), w * 0.09, fill(const Color(0xFF3A3F55)));

  // Faros.
  for (final lampX in [w * 0.4, w * 0.6]) {
    canvas.drawCircle(Offset(lampX, h * 0.15), w * 0.045, fill(const Color(0xFFFFF0A8)));
  }
}

/// Bus escolar visto desde arriba.
void drawBus(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  final cx = w / 2;
  final scale = w / 190;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(cx, h * 0.93),
      width: w * 0.82,
      height: h * 0.09,
    ),
    sigma: 10 * scale,
  );

  _drawWheelPair(
    canvas,
    size,
    top: 0.1,
    bottom: 0.76,
    wheelWidth: 0.1,
    wheelHeight: 0.15,
    inset: 0.02,
  );

  // Carroceria.
  final bodyPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.1, h * 0.04, w * 0.8, h * 0.92),
        Radius.circular(w * 0.12),
      ),
    );
  canvas.drawPath(bodyPath, fill(color));
  canvas.drawPath(bodyPath, stroke(darken(color, 0.35), 6 * scale));

  // Parabrisas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.06, w * 0.6, h * 0.13),
      Radius.circular(w * 0.05),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  // Techo y ventanas.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.24, w * 0.64, h * 0.6),
      Radius.circular(w * 0.06),
    ),
    fill(darken(color, 0.14)),
  );
  for (var i = 0; i < 4; i++) {
    for (final side in [0.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * (0.21 + side * 0.44),
            h * (0.29 + i * 0.13),
            w * 0.34,
            h * 0.08,
          ),
          Radius.circular(w * 0.03),
        ),
        fill(const Color(0xFFCDEEFF)),
      );
    }
  }

  // Franja de la escuela.
  canvas.drawRect(
    Rect.fromLTWH(w * 0.18, h * 0.86, w * 0.64, h * 0.06),
    fill(const Color(0xFFFF6B6B)),
  );
}
