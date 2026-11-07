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

/// Conductor del vehiculo (visto desde arriba).
///
/// Es el "personaje" que viaja con el nino: se ve la cabeza con el gorro
/// asomando por la cabina.
void drawDriverHead(
  Canvas canvas,
  ui.Size size, {
  Offset? at,
  double radiusFactor = 0.11,
  Color hat = const Color(0xFF2B2D42),
}) {
  final w = size.width;
  final center = at ?? Offset(w * 0.5, size.height * 0.52);
  final radius = w * radiusFactor;

  // Pelo.
  canvas.drawCircle(center, radius, fill(const Color(0xFF6B4A2F)));
  // Gorro.
  canvas.drawArc(
    Rect.fromCircle(center: center.translate(0, -radius * 0.12), radius: radius),
    math.pi,
    math.pi,
    true,
    fill(hat),
  );
  // Visera del gorro.
  canvas.drawArc(
    Rect.fromCircle(center: center, radius: radius * 0.86),
    -math.pi / 2,
    math.pi,
    false,
    stroke(hat, radius * 0.32),
  );
}

/// Calca pegada en la carrocerÃ­a del vehiculo.
void drawBodySticker(
  Canvas canvas,
  ui.Size size, {
  Offset? at,
  double radiusFactor = 0.085,
  Color color = const Color(0xFFFFD32A),
}) {
  final w = size.width;
  final center = at ?? Offset(w * 0.5, size.height * 0.78);
  final radius = w * radiusFactor;
  final star = starPath(center, radius, radius * 0.45);
  canvas.drawPath(star, fill(color));
  canvas.drawPath(star, stroke(darken(color, 0.3), radius * 0.16));
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

  // Conductor y calca: el camion nunca va vacio.
  drawDriverHead(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.34),
    radiusFactor: 0.075,
    hat: const Color(0xFFFFD32A),
  );
  drawBodySticker(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.66),
    radiusFactor: 0.055,
    color: const Color(0xFFFFD32A),
  );
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

  // Conductor y calca.
  drawDriverHead(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.22),
    radiusFactor: 0.07,
  );
  drawBodySticker(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.62),
    radiusFactor: 0.05,
    color: const Color(0xFFFF6B6B),
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

  // Conductor y nanny con los ninos en las ventanas.
  drawDriverHead(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.16),
    radiusFactor: 0.06,
  );
  for (final dy in [0.42, 0.56]) {
    drawDriverHead(
      canvas,
      size,
      at: Offset(w * 0.24, h * dy),
      radiusFactor: 0.045,
      hat: const Color(0xFFFF6B6B),
    );
    drawDriverHead(
      canvas,
      size,
      at: Offset(w * 0.76, h * dy),
      radiusFactor: 0.045,
      hat: const Color(0xFFFF6B6B),
    );
  }
}

/// Coche de policia visto desde arriba.
///
/// Coche azul con sirena, franja blanca y calca de estrella.
void drawPoliceCar(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  const police = Color(0xFF2D6CDF);
  final scale = w / 160;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.9),
      width: w * 0.72,
      height: h * 0.12,
    ),
    sigma: 10 * scale,
  );

  for (final wheelY in [h * 0.26, h * 0.63]) {
    for (final side in [0.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * (0.1 + side * 0.78),
            wheelY,
            w * 0.12,
            h * 0.21,
          ),
          Radius.circular(w * 0.06),
        ),
        fill(StudioPalette.tire),
      );
    }
  }

  final bodyPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.16, h * 0.1, w * 0.68, h * 0.8),
        Radius.circular(w * 0.25),
      ),
    );
  canvas.drawPath(bodyPath, fill(police));
  canvas.drawPath(bodyPath, stroke(darken(police, 0.35), 5 * scale));

  canvas.drawRect(
    Rect.fromLTWH(w * 0.16, h * 0.52, w * 0.68, h * 0.1),
    fill(const Color(0xFFFFFFFF)),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.32, w * 0.4, h * 0.36),
      Radius.circular(w * 0.16),
    ),
    fill(darken(police, 0.18)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.34, h * 0.35, w * 0.32, h * 0.15),
      Radius.circular(w * 0.1),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  // Sirena.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.38, h * 0.16, w * 0.1, h * 0.12),
      Radius.circular(w * 0.04),
    ),
    fill(const Color(0xFFFF6B6B)),
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.54, h * 0.16, w * 0.1, h * 0.12),
      Radius.circular(w * 0.04),
    ),
    fill(const Color(0xFF4D8DFF)),
  );

  for (final lampX in [w * 0.22, w * 0.62]) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(lampX, h * 0.13, w * 0.16, h * 0.09),
        Radius.circular(w * 0.05),
      ),
      fill(const Color(0xFFFFF0A8)),
    );
  }

  drawDriverHead(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.56),
    radiusFactor: 0.085,
    hat: police,
  );
  drawBodySticker(
    canvas,
    size,
    at: Offset(w * 0.32, h * 0.68),
    radiusFactor: 0.06,
    color: const Color(0xFFFFD32A),
  );
}

/// Ambulancia vista desde arriba.
///
/// Camioneta blanca con cruz roja, sirena y calca.
void drawAmbulance(Canvas canvas, ui.Size size, Color color) {
  final w = size.width;
  final h = size.height;
  const white = Color(0xFFF4F6FB);
  final scale = w / 160;

  drawEllipseShadow(
    canvas,
    Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.9),
      width: w * 0.76,
      height: h * 0.12,
    ),
    sigma: 10 * scale,
  );

  for (final wheelY in [h * 0.24, h * 0.68]) {
    for (final side in [0.0, 1.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            w * (0.08 + side * 0.8),
            wheelY,
            w * 0.12,
            h * 0.19,
          ),
          Radius.circular(w * 0.06),
        ),
        fill(StudioPalette.tire),
      );
    }
  }

  final bodyPath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.08, w * 0.72, h * 0.84),
        Radius.circular(w * 0.2),
      ),
    );
  canvas.drawPath(bodyPath, fill(white));
  canvas.drawPath(bodyPath, stroke(darken(white, 0.3), 5 * scale));

  canvas.drawRect(
    Rect.fromLTWH(w * 0.14, h * 0.56, w * 0.72, h * 0.12),
    fill(const Color(0xFFFF4757)),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.44, h * 0.38, w * 0.1, h * 0.34),
    fill(const Color(0xFFFF4757)),
  );
  canvas.drawRect(
    Rect.fromLTWH(w * 0.33, h * 0.5, w * 0.32, h * 0.1),
    fill(const Color(0xFFFF4757)),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.14, w * 0.44, h * 0.24),
      Radius.circular(w * 0.12),
    ),
    fill(const Color(0xFFCDEEFF)),
  );

  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.4, h * 0.1, w * 0.2, h * 0.05),
      Radius.circular(w * 0.03),
    ),
    fill(const Color(0xFF4D8DFF)),
  );

  drawDriverHead(
    canvas,
    size,
    at: Offset(w * 0.5, h * 0.28),
    radiusFactor: 0.075,
    hat: const Color(0xFFFF4757),
  );
  drawBodySticker(
    canvas,
    size,
    at: Offset(w * 0.32, h * 0.78),
    radiusFactor: 0.055,
    color: const Color(0xFF4D8DFF),
  );
}
