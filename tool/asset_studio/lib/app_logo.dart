// Logotipo e iconos de la app.
//
// El mismo dibujo sirve para el icono del lanzador de Android, el de iOS,
// el favicon de la web y la pantalla de inicio. Se dibuja **por codigo**
// para poder generarlo a cualquier tamano sin pixelarse.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'sprites.dart';
import 'studio.dart';

/// Radio de las esquinas del icono (fraccion del lado).
const double kAppIconRadius = 0.22;

/// Dibuja el **fondo** del icono: cuadrado redondeado con degradado.
///
/// [size] es el lado del icono completo.
void drawAppIconBackground(Canvas canvas, ui.Size size) {
  final rect = Rect.fromLTWH(0, 0, size.width, size.height);
  final path = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(size.width * kAppIconRadius),
      ),
    );
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4D8DFF), Color(0xFF9C5CFF)],
      ).createShader(rect),
  );
  // Brillo suave en la esquina superior izquierda.
  canvas.drawPath(
    path,
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.center,
        colors: [Color(0x33FFFFFF), Color(0x00FFFFFF)],
      ).createShader(rect),
  );
}

/// Dibuja el **contenido** del icono: estrella, coche y pincel.
///
/// [scale] permite reducir el contenido para la zona segura de los iconos
/// adaptativos de Android (el sistema recorta los bordes).
void drawAppIconForeground(
  Canvas canvas,
  ui.Size size, {
  double scale = 1,
  Color? carColor,
  Color? brushColor,
}) {
  final w = size.width;
  final h = size.height;
  final center = Offset(w / 2, h / 2);

  // Estrella grande de fondo (el símbolo de la recompensa).
  final star = starPath(
    center.translate(0, -h * 0.04),
    w * 0.40 * scale,
    w * 0.17 * scale,
  );
  canvas.drawPath(star, fill(const Color(0xFFFFD32A)));
  canvas.drawPath(
    star,
    stroke(darken(const Color(0xFFFFD32A), 0.18), w * 0.022),
  );

  // Coche de carreras (vista cenital, el mismo arte del juego).
  final carSize = ui.Size(w * 0.48 * scale, h * 0.48 * scale);
  canvas.save();
  canvas.translate(
    center.dx - carSize.width / 2,
    center.dy - carSize.height * 0.3,
  );
  drawCar(
    canvas,
    carSize,
    carColor ?? StudioPalette.red,
  );
  canvas.restore();

  // Pincel cruzando por la esquina superior izquierda.
  final brushSize = ui.Size(w * 0.3 * scale, h * 0.3 * scale);
  canvas.save();
  canvas.translate(w * 0.16 * scale, h * 0.12 * scale);
  canvas.rotate(-0.45);
  drawBrushIcon(canvas, brushSize);
  canvas.restore();
}

/// Icono completo (fondo + contenido), opaco: para iOS y la web.
void drawAppIcon(Canvas canvas, ui.Size size) {
  drawAppIconBackground(canvas, size);
  drawAppIconForeground(canvas, size);
}

/// Version **monocroma** (para los iconos con tema de Android 13+).
///
/// Se dibuja todo en negro sobre transparente: el sistema lo tiñe.
void drawAppIconMonochrome(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final center = Offset(w / 2, h / 2);
  final paint = fill(const Color(0xFF000000));

  final star = starPath(center.translate(0, -h * 0.02), w * 0.44, w * 0.19);
  canvas.drawPath(star, paint);

  final carSize = ui.Size(w * 0.5, h * 0.5);
  canvas.save();
  canvas.translate(
    center.dx - carSize.width / 2,
    center.dy - carSize.height * 0.34,
  );
  drawCarMonochrome(canvas, carSize);
  canvas.restore();
}

/// Silueta monocroma de un coche.
void drawCarMonochrome(Canvas canvas, ui.Size size) {
  final w = size.width;
  final h = size.height;
  final paint = fill(const Color(0xFF000000));

  // Carroceria.
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.16, h * 0.1, w * 0.68, h * 0.8),
      Radius.circular(w * 0.25),
    ),
    paint,
  );

  // Ruedas.
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
        paint,
      );
    }
  }
}

/// Icono redondo (para lanzadores que lo piden).
void drawAppIconRound(Canvas canvas, ui.Size size) {
  final rect = Rect.fromLTWH(0, 0, size.width, size.height);
  canvas.drawPath(
    Path()..addOval(rect),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4D8DFF), Color(0xFF9C5CFF)],
      ).createShader(rect),
  );
  drawAppIconForeground(canvas, size, scale: 0.92);
}

/// Emblema del logo para la pantalla de inicio (sin texto).
///
/// El texto **no** se dibuja aqui a proposito: el generador de assets no
/// tiene fuentes del sistema y el texto saldria como un cuadro negro. El
/// nombre de la app lo pone Android en la pantalla de inicio.
void drawAppLogoMark(Canvas canvas, ui.Size size) {
  final badge = size.height;
  final badgeRect = Rect.fromLTWH(0, 0, badge, badge);
  canvas.drawPath(
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          badgeRect,
          Radius.circular(badge * kAppIconRadius),
        ),
      ),
    Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4D8DFF), Color(0xFF9C5CFF)],
      ).createShader(badgeRect),
  );
  drawAppIconForeground(canvas, ui.Size(badge, badge), scale: 0.94);
}

/// helpers: angulos.
double degreesToRadians(double value) => value * math.pi / 180;
