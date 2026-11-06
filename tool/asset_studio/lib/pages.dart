// Laminas para colorear: coche, animales, dinosaurio y ciudad.
//
// Son escenas completas (no un objeto suelto): cada region queda cerrada y
// con contorno grueso para que el bote de pintura rellene sin derrames.
// La composicion sigue una rejilla: ningun elemento se solapa con otro
// salvo por profundidad (colinas detras de los animales).

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'backgrounds.dart';
import 'studio.dart';

/// Sol con rayos.
void drawSunShape(Canvas canvas, Offset center, double radius) {
  for (var i = 0; i < 10; i++) {
    final angle = i / 10 * 2 * math.pi;
    canvas.drawLine(
      center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.15,
      center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.5,
      stroke(StudioPalette.outline, 9),
    );
  }
  drawPageRegion(
    canvas,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    outlineWidth: 12,
  );
}

/// Nube cartoon.
void drawCloudShape(
  Canvas canvas,
  Offset center,
  double width,
  double height,
) {
  drawPageRegion(
    canvas,
    cloudPath(center, width, height),
    outlineWidth: 12,
  );
}

/// Rueda de coche con llanta y buje.
void drawWheelShape(Canvas canvas, Offset center, double radius) {
  drawPageRegion(
    canvas,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.6)),
    outlineWidth: 10,
  );
  drawPageRegion(
    canvas,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.2)),
    outlineWidth: 8,
  );
}

/// Flor de [petals] petalos.
void drawFlowerShape(
  Canvas canvas,
  Offset center,
  double radius, {
  int petals = 6,
}) {
  for (var i = 0; i < petals; i++) {
    final angle = i / petals * 2 * math.pi;
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: center +
                Offset(math.cos(angle), math.sin(angle)) * radius * 0.62,
            width: radius * 0.95,
            height: radius * 0.95,
          ),
        ),
      outlineWidth: 9,
    );
  }
  drawPageRegion(
    canvas,
    Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.42)),
    outlineWidth: 8,
  );
}

/// Mata de hierba.
void drawGrassTuftShape(Canvas canvas, Offset base, double height) {
  for (var i = -1; i <= 1; i++) {
    canvas.drawLine(
      base,
      base + Offset(i * height * 0.32, -height),
      stroke(StudioPalette.outline, 9),
    );
  }
}

/// Estrella de cinco puntas (sin texto: las laminas no llevan letras).
void drawStarShape(Canvas canvas, Offset center, double radius) {
  drawPageRegion(
    canvas,
    starPath(center, radius, radius * 0.45),
    outlineWidth: 9,
  );
}

/// Lamina del coche de carreras.
///
/// Cielo con sol y nubes, colinas al fondo, circuito con banderas y un coche
/// de lado con todos los detalles: aleron, escape, retrovisor, ventanillas,
/// faros, dorsal y ruedas con llanta.
void drawPageCar(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Cielo.
  drawSunShape(canvas, Offset(w * 0.12, h * 0.15), w * 0.065);
  drawCloudShape(canvas, Offset(w * 0.62, h * 0.09), w * 0.24, h * 0.11);
  drawCloudShape(canvas, Offset(w * 0.88, h * 0.21), w * 0.18, h * 0.08);

  // Colinas del fondo.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.22, h * 0.6),
          width: w * 0.66,
          height: h * 0.4,
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.88, h * 0.62),
          width: w * 0.5,
          height: h * 0.3,
        ),
      ),
    outlineWidth: 13,
  );

  // Bandera a cuadros al fondo.
  canvas.drawLine(
    Offset(w * 0.94, h * 0.32),
    Offset(w * 0.94, h * 0.66),
    stroke(StudioPalette.outline, 10),
  );
  for (var row = 0; row < 3; row++) {
    for (var col = 0; col < 4; col++) {
      final isBlack = (row + col).isEven;
      final cell = Rect.fromLTWH(
        w * 0.862 + col * w * 0.02,
        h * 0.32 + row * h * 0.03,
        w * 0.02,
        h * 0.03,
      );
      canvas.drawRect(
        cell,
        fill(isBlack ? StudioPalette.ink : StudioPalette.white),
      );
      canvas.drawRect(cell, stroke(StudioPalette.outline, 3));
    }
  }

  // Cesped, circuito y cesped inferior.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.58, w, h * 0.08)),
    outlineWidth: 13,
  );
  for (var i = 0; i < 6; i++) {
    drawGrassTuftShape(
      canvas,
      Offset(w * (0.08 + i * 0.17), h * 0.63),
      h * 0.05,
    );
  }
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.66, w, h * 0.24)),
    outlineWidth: 13,
  );
  for (var i = 0; i < 7; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * (0.04 + i * 0.14), h * 0.78, w * 0.08, h * 0.03),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 8,
    );
  }
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.9, w, h * 0.1)),
    outlineWidth: 13,
  );
  for (var i = 0; i < 7; i++) {
    drawGrassTuftShape(
      canvas,
      Offset(w * (0.07 + i * 0.14), h * 0.975),
      h * 0.045,
    );
  }

  // Sombra del coche.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.48, h * 0.7),
          width: w * 0.6,
          height: h * 0.05,
        ),
      ),
    outlineWidth: 9,
  );

  // Lineas de velocidad detras del coche.
  for (final data in <(double, double, double)>[
    (0.03, 0.47, 0.13),
    (0.05, 0.525, 0.09),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * data.$1,
              h * data.$2,
              w * data.$3,
              h * 0.016,
            ),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 7,
    );
  }

  // Escape.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.165, h * 0.6, w * 0.035, h * 0.022),
          const Radius.circular(6),
        ),
      ),
    outlineWidth: 9,
  );

  // Aleron trasero.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.175, h * 0.415, w * 0.1, h * 0.03),
          const Radius.circular(10),
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.195, h * 0.43, w * 0.022, h * 0.045),
          const Radius.circular(6),
        ),
      ),
    outlineWidth: 9,
  );

  // Carroceria.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.18, h * 0.46, w * 0.62, h * 0.16),
          const Radius.circular(24),
        ),
      ),
    outlineWidth: 14,
  );

  // Techo: trompa con las esquinas superiores redondeadas.
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(w * 0.3, h * 0.46)
      ..lineTo(w * 0.355, h * 0.315)
      ..quadraticBezierTo(w * 0.375, h * 0.29, w * 0.415, h * 0.29)
      ..lineTo(w * 0.545, h * 0.29)
      ..quadraticBezierTo(w * 0.585, h * 0.29, w * 0.605, h * 0.325)
      ..lineTo(w * 0.66, h * 0.46)
      ..close(),
    outlineWidth: 14,
  );

  // Ventanas.
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(w * 0.325, h * 0.45),
      Offset(w * 0.38, h * 0.325),
      Offset(w * 0.455, h * 0.325),
      Offset(w * 0.455, h * 0.45),
    ]),
    outlineWidth: 10,
  );
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(w * 0.49, h * 0.45),
      Offset(w * 0.49, h * 0.325),
      Offset(w * 0.555, h * 0.335),
      Offset(w * 0.595, h * 0.45),
    ]),
    outlineWidth: 10,
  );

  // Retrovisor.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.295, h * 0.395),
          width: w * 0.04,
          height: h * 0.04,
        ),
      ),
    outlineWidth: 9,
  );

  // Franja de carrera.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.19, h * 0.505, w * 0.6, h * 0.028),
          const Radius.circular(10),
        ),
      ),
    outlineWidth: 8,
  );

  // Dorsal con una estrella (sin numeros: las laminas no llevan texto).
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w * 0.44, h * 0.565), radius: h * 0.042),
      ),
    outlineWidth: 10,
  );
  drawStarShape(canvas, Offset(w * 0.44, h * 0.565), h * 0.026);

  // Faros y piloto trasero.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.765, h * 0.48, w * 0.03, h * 0.045),
          const Radius.circular(10),
        ),
      ),
    outlineWidth: 9,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.186, h * 0.485, w * 0.026, h * 0.04),
          const Radius.circular(9),
        ),
      ),
    outlineWidth: 9,
  );

  // Ruedas.
  drawWheelShape(canvas, Offset(w * 0.3, h * 0.63), h * 0.08);
  drawWheelShape(canvas, Offset(w * 0.69, h * 0.63), h * 0.08);
}

/// Lamina de los animales del prado.
///
/// Gato, perro, conejo, pajaro, pez, mariposa y abeja, repartidos en una
/// rejilla para que nada se solape: estanque, arbol, flores y setas.
void drawPageAnimals(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Cielo.
  drawSunShape(canvas, Offset(w * 0.9, h * 0.1), w * 0.055);
  drawCloudShape(canvas, Offset(w * 0.42, h * 0.08), w * 0.22, h * 0.1);
  drawCloudShape(canvas, Offset(w * 0.6, h * 0.16), w * 0.17, h * 0.075);

  // Pajaro en una rama.
  final bird = Offset(w * 0.14, h * 0.13);
  canvas.drawLine(
    Offset(w * 0.03, h * 0.19),
    Offset(w * 0.29, h * 0.185),
    stroke(StudioPalette.outline, 11),
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: bird, width: w * 0.12, height: h * 0.1),
      ),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: bird + Offset(w * 0.04, h * 0.012),
          width: w * 0.07,
          height: h * 0.055,
        ),
      ),
    outlineWidth: 9,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: bird + Offset(-w * 0.02, -h * 0.055),
          width: w * 0.07,
          height: h * 0.07,
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(bird.dx - w * 0.05, bird.dy - h * 0.065),
      Offset(bird.dx - w * 0.09, bird.dy - h * 0.045),
      Offset(bird.dx - w * 0.05, bird.dy - h * 0.03),
    ]),
    outlineWidth: 8,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: bird + Offset(-w * 0.028, -h * 0.062),
          width: w * 0.02,
          height: h * 0.024,
        ),
      ),
    outlineWidth: 7,
  );
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(bird.dx + w * 0.055, bird.dy + h * 0.025),
      Offset(bird.dx + w * 0.12, bird.dy + h * 0.055),
      Offset(bird.dx + w * 0.05, bird.dy + h * 0.07),
    ]),
    outlineWidth: 9,
  );

  // Colina del fondo.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.2, h * 0.66),
          width: w * 0.62,
          height: h * 0.34,
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.82, h * 0.7),
          width: w * 0.5,
          height: h * 0.28,
        ),
      ),
    outlineWidth: 13,
  );

  // Prado.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.55, w, h * 0.45)),
    outlineWidth: 13,
  );

  // Gato sentado.
  final cat = Offset(w * 0.18, h * 0.62);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: cat + Offset(0, h * 0.045),
          width: w * 0.15,
          height: h * 0.2,
        ),
      ),
    outlineWidth: 13,
  );
  for (final ear in [
    polygonPath([
      Offset(w * 0.125, h * 0.56),
      Offset(w * 0.13, h * 0.45),
      Offset(w * 0.19, h * 0.53),
    ]),
    polygonPath([
      Offset(w * 0.255, h * 0.56),
      Offset(w * 0.25, h * 0.45),
      Offset(w * 0.19, h * 0.53),
    ]),
  ]) {
    drawPageRegion(canvas, ear, outlineWidth: 11);
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: cat + Offset(0, -h * 0.05),
          width: w * 0.16,
          height: h * 0.15,
        ),
      ),
    outlineWidth: 13,
  );
  for (final dx in [-0.03, 0.03]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: cat + Offset(w * dx, -h * 0.065),
            width: w * 0.03,
            height: h * 0.04,
          ),
        ),
      outlineWidth: 8,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: cat + Offset(0, -h * 0.02),
          width: w * 0.024,
          height: h * 0.02,
        ),
      ),
    outlineWidth: 8,
  );
  for (var i = 0; i < 3; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: cat + Offset(w * (0.045 - i * 0.045), h * 0.035),
            width: w * 0.018,
            height: h * 0.03,
          ),
        ),
      outlineWidth: 7,
    );
  }
  // Cola.
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(w * 0.12, h * 0.74)
      ..cubicTo(
        w * 0.05, h * 0.75,
        w * 0.04, h * 0.67,
        w * 0.08, h * 0.64,
      )
      ..cubicTo(
        w * 0.1, h * 0.66,
        w * 0.09, h * 0.7,
        w * 0.11, h * 0.71,
      )
      ..close(),
    outlineWidth: 11,
  );

  // Perro.
  final dog = Offset(w * 0.47, h * 0.62);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: dog + Offset(0, h * 0.03),
          width: w * 0.17,
          height: h * 0.17,
        ),
      ),
    outlineWidth: 13,
  );
  for (final dx in [-0.055, 0.055]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              dog.dx + w * dx - w * 0.022,
              dog.dy + h * 0.07,
              w * 0.044,
              h * 0.08,
            ),
            const Radius.circular(10),
          ),
        ),
      outlineWidth: 10,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: dog + Offset(0, -h * 0.075),
          width: w * 0.14,
          height: h * 0.13,
        ),
      ),
    outlineWidth: 13,
  );
  for (final dx in [-0.065, 0.065]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: dog + Offset(w * dx, -h * 0.065),
            width: w * 0.06,
            height: h * 0.1,
          ),
        ),
      outlineWidth: 10,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: dog + Offset(0, -h * 0.03),
          width: w * 0.07,
          height: h * 0.05,
        ),
      ),
    outlineWidth: 9,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: dog + Offset(0, -h * 0.048),
          width: w * 0.024,
          height: h * 0.02,
        ),
      ),
    outlineWidth: 8,
  );
  for (final dx in [-0.03, 0.03]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: dog + Offset(w * dx, -h * 0.1),
            width: w * 0.024,
            height: h * 0.028,
          ),
        ),
      outlineWidth: 8,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            dog.dx - w * 0.065,
            dog.dy - h * 0.005,
            w * 0.13,
            h * 0.026,
          ),
          const Radius.circular(10),
        ),
      ),
    outlineWidth: 9,
  );

  // Conejo.
  final rabbit = Offset(w * 0.71, h * 0.63);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: rabbit + Offset(0, h * 0.03),
          width: w * 0.13,
          height: h * 0.12,
        ),
      ),
    outlineWidth: 12,
  );
  for (final dx in [-0.026, 0.026]) {
    drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            rabbit.dx + w * dx - w * 0.016,
            rabbit.dy - h * 0.12,
            w * 0.032,
            h * 0.11,
          ),
          const Radius.circular(16),
        ),
      ),
    outlineWidth: 10,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: rabbit + Offset(0, -h * 0.045),
          width: w * 0.11,
          height: h * 0.095,
        ),
      ),
    outlineWidth: 12,
  );
  for (final dx in [-0.022, 0.022]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: rabbit + Offset(w * dx, -h * 0.058),
            width: w * 0.02,
            height: h * 0.024,
          ),
        ),
      outlineWidth: 7,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: rabbit + Offset(0, -h * 0.015),
          width: w * 0.02,
          height: h * 0.016,
        ),
      ),
    outlineWidth: 7,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCircle(
          center: rabbit + Offset(w * 0.06, h * 0.035),
          radius: w * 0.02,
        ),
      ),
    outlineWidth: 9,
  );

  // Arbol a la derecha.
  canvas.drawLine(
    Offset(w * 0.86, h * 0.56),
    Offset(w * 0.86, h * 0.78),
    stroke(StudioPalette.outline, 13),
  );
  for (final data in <(double, double, double)>[
    (0.86, 0.46, 0.16),
    (0.81, 0.54, 0.12),
    (0.92, 0.55, 0.11),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(w * data.$1, h * data.$2),
            width: w * data.$3,
            height: w * data.$3 * 0.85,
          ),
        ),
      outlineWidth: 12,
    );
  }
  for (final data in <(double, double)>[
    (0.83, 0.45),
    (0.9, 0.52),
    (0.8, 0.57),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCircle(center: Offset(w * data.$1, h * data.$2), radius: w * 0.026),
        ),
      outlineWidth: 9,
    );
  }

  // Estanque con pez y nenufar.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.1, h * 0.89),
          width: w * 0.2,
          height: h * 0.13,
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.085, h * 0.89),
          width: w * 0.1,
          height: h * 0.06,
        ),
      ),
    outlineWidth: 10,
  );
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(w * 0.117, h * 0.89),
      Offset(w * 0.15, h * 0.872),
      Offset(w * 0.15, h * 0.908),
    ]),
    outlineWidth: 9,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.085, h * 0.878),
          width: w * 0.022,
          height: h * 0.022,
        ),
      ),
    outlineWidth: 8,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.04, h * 0.918),
          width: w * 0.036,
          height: h * 0.018,
        ),
      ),
    outlineWidth: 9,
  );

  // Mariposa.
  final butterfly = Offset(w * 0.3, h * 0.89);
  for (final data in <(double, double, double, double)>[
    (-0.062, -0.05, 0.1, 0.085),
    (0.062, -0.05, 0.1, 0.085),
    (-0.052, 0.05, 0.085, 0.07),
    (0.052, 0.05, 0.085, 0.07),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: butterfly + Offset(w * data.$1, h * data.$2),
            width: w * data.$3,
            height: h * data.$4,
          ),
        ),
      outlineWidth: 9,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: butterfly,
            width: w * 0.026,
            height: h * 0.15,
          ),
          const Radius.circular(10),
        ),
      ),
    outlineWidth: 8,
  );

  // Abeja.
  final bee = Offset(w * 0.42, h * 0.87);
  for (final dx in [-0.03, 0.03]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: bee + Offset(w * dx, -h * 0.025),
            width: w * 0.05,
            height: h * 0.03,
          ),
        ),
      outlineWidth: 8,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: bee, width: w * 0.1, height: h * 0.06),
      ),
    outlineWidth: 10,
  );
  for (final dx in [-0.022, 0.008]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              bee.dx + w * dx,
              bee.dy - h * 0.028,
              w * 0.018,
              h * 0.056,
            ),
            const Radius.circular(6),
          ),
        ),
      outlineWidth: 8,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCircle(
          center: bee + Offset(-w * 0.058, -h * 0.005),
          radius: w * 0.02,
        ),
      ),
    outlineWidth: 8,
  );

  // Flores, setas y hierba.
  for (final data in <(double, double, double)>[
    (0.55, 0.87, 0.038),
    (0.61, 0.94, 0.03),
  ]) {
    canvas.drawLine(
      Offset(w * data.$1, h * data.$2 + data.$3),
      Offset(w * (data.$1 + 0.008), h * (data.$2 + 0.055)),
      stroke(StudioPalette.outline, 8),
    );
    drawFlowerShape(canvas, Offset(w * data.$1, h * data.$2), w * data.$3);
  }
  for (final data in <(double, double, double)>[
    (0.69, 0.88, 0.034),
    (0.75, 0.95, 0.027),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * data.$1 - w * data.$3 * 0.24,
              h * data.$2 + h * 0.012,
              w * data.$3 * 0.48,
              h * 0.042,
            ),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 9,
    );
    drawPageRegion(
      canvas,
      Path()
        ..addArc(
          Rect.fromCenter(
            center: Offset(w * data.$1, h * data.$2),
            width: w * data.$3 * 1.5,
            height: h * 0.042,
          ),
          math.pi,
          math.pi,
        ),
      outlineWidth: 9,
    );
  }
  for (final data in <(double, double)>[
    (0.83, 0.97),
    (0.92, 0.97),
  ]) {
    drawGrassTuftShape(canvas, Offset(w * data.$1, h * data.$2), h * 0.04);
  }
}

/// Lamina del dinosaurio.
///
/// Un dinosaurio simpatico en un valle con volcan, palmera, huevos y sol.
void drawPageDinosaur(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Cielo.
  drawSunShape(canvas, Offset(w * 0.88, h * 0.1), w * 0.06);
  drawCloudShape(canvas, Offset(w * 0.33, h * 0.09), w * 0.22, h * 0.1);

  // Volcan al fondo.
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(w * 0.78, h * 0.62),
      Offset(w * 0.9, h * 0.26),
      Offset(w * 1.0, h * 0.62),
    ]),
    outlineWidth: 14,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(w * 0.9, h * 0.26),
          width: w * 0.12,
          height: h * 0.08,
        ),
        math.pi,
        math.pi,
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    polygonPath([
      Offset(w * 0.878, h * 0.28),
      Offset(w * 0.9, h * 0.36),
      Offset(w * 0.922, h * 0.28),
    ]),
    outlineWidth: 9,
  );

  // Colina y suelo.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.42, h * 0.72),
          width: w * 0.98,
          height: h * 0.5,
        ),
      ),
    outlineWidth: 14,
  );
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.78, w, h * 0.22)),
    outlineWidth: 13,
  );

  // Palmera a la izquierda.
  final palm = Offset(w * 0.1, h * 0.46);
  canvas.drawLine(
    Offset(palm.dx, palm.dy + h * 0.32),
    palm,
    stroke(StudioPalette.outline, 13),
  );
  for (var i = 0; i < 5; i++) {
    final angle = -math.pi / 2 + (i - 2) * 0.6;
    final tip = palm +
        Offset(math.cos(angle) * w * 0.1, math.sin(angle) * w * 0.1);
    drawPageRegion(
      canvas,
      Path()
        ..moveTo(palm.dx, palm.dy)
        ..quadraticBezierTo(
          palm.dx + math.cos(angle) * w * 0.055,
          palm.dy + math.sin(angle) * w * 0.055 - h * 0.022,
          tip.dx,
          tip.dy,
        )
        ..quadraticBezierTo(
          palm.dx + math.cos(angle) * w * 0.045,
          palm.dy + math.sin(angle) * w * 0.045 + h * 0.016,
          palm.dx,
          palm.dy,
        )
        ..close(),
      outlineWidth: 10,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: palm + Offset(0, h * 0.016),
          width: w * 0.034,
          height: h * 0.034,
        ),
      ),
    outlineWidth: 9,
  );

  // Cuerpo del dinosaurio.
  final dino = Offset(w * 0.44, h * 0.56);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: dino, width: w * 0.4, height: h * 0.3),
      ),
    outlineWidth: 15,
  );
  // Vientre.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: dino + Offset(w * 0.01, h * 0.055),
          width: w * 0.26,
          height: h * 0.15,
        ),
      ),
    outlineWidth: 11,
  );
  // Cuello inclinado.
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(w * 0.34, h * 0.52)
      ..lineTo(w * 0.27, h * 0.3)
      ..quadraticBezierTo(w * 0.26, h * 0.24, w * 0.3, h * 0.235)
      ..lineTo(w * 0.35, h * 0.235)
      ..quadraticBezierTo(w * 0.39, h * 0.24, w * 0.38, h * 0.3)
      ..lineTo(w * 0.43, h * 0.52)
      ..close(),
    outlineWidth: 14,
  );
  // Cabeza.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.3, h * 0.2),
          width: w * 0.16,
          height: h * 0.14,
        ),
      ),
    outlineWidth: 14,
  );
  // Hocico.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.235, h * 0.225),
          width: w * 0.09,
          height: h * 0.075,
        ),
      ),
    outlineWidth: 12,
  );
  // Ojo.
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(w * 0.285, h * 0.175),
          width: w * 0.026,
          height: h * 0.032,
        ),
      ),
    outlineWidth: 8,
  );
  // Placas de la espalda.
  for (var i = 0; i < 4; i++) {
    final x = dino.dx - w * 0.09 + i * w * 0.085;
    drawPageRegion(
      canvas,
      polygonPath([
        Offset(x, dino.dy - h * 0.13),
        Offset(x + w * 0.032, dino.dy - h * 0.2),
        Offset(x + w * 0.064, dino.dy - h * 0.13),
      ]),
      outlineWidth: 9,
    );
  }
  // Patas.
  for (final dx in [-0.15, -0.05, 0.06, 0.15]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              dino.dx + w * dx,
              dino.dy + h * 0.1,
              w * 0.062,
              h * 0.13,
            ),
            const Radius.circular(14),
          ),
        ),
      outlineWidth: 12,
    );
  }
  // Cola corta.
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(dino.dx + w * 0.18, h * 0.51)
      ..cubicTo(
        dino.dx + w * 0.25, h * 0.52,
        dino.dx + w * 0.27, h * 0.57,
        dino.dx + w * 0.28, h * 0.61,
      )
      ..cubicTo(
        dino.dx + w * 0.24, h * 0.59,
        dino.dx + w * 0.21, h * 0.58,
        dino.dx + w * 0.17, h * 0.6,
      )
      ..close(),
    outlineWidth: 13,
  );

  // Huevos.
  for (var i = 0; i < 3; i++) {
    final center = Offset(w * (0.15 + i * 0.06), h * 0.87);
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(center: center, width: w * 0.05, height: h * 0.08),
        ),
      outlineWidth: 11,
    );
    for (var j = 0; j < 3; j++) {
      drawPageRegion(
        canvas,
        Path()
          ..addOval(
            Rect.fromCenter(
              center: center +
                  Offset(w * (j - 1) * 0.011, h * (j.isEven ? -0.016 : 0.016)),
              width: w * 0.011,
              height: h * 0.016,
            ),
          ),
        outlineWidth: 6,
      );
    }
  }

  // Flor y hierba.
  drawFlowerShape(canvas, Offset(w * 0.7, h * 0.87), w * 0.04);
  drawGrassTuftShape(canvas, Offset(w * 0.64, h * 0.94), h * 0.05);
  drawGrassTuftShape(canvas, Offset(w * 0.92, h * 0.94), h * 0.05);
}

/// Lamina de la ciudad.
///
/// Edificios con ventanas, arbol, farola, calle con paso de cebra y dos
/// coches vistos de frente.
void drawPageCity(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Cielo.
  drawSunShape(canvas, Offset(w * 0.12, h * 0.11), w * 0.06);
  drawCloudShape(canvas, Offset(w * 0.5, h * 0.08), w * 0.22, h * 0.1);
  drawCloudShape(canvas, Offset(w * 0.84, h * 0.17), w * 0.17, h * 0.075);

  // Cuatro edificios con ventanas.
  final buildings = <(double, double)>[
    (0.02, 0.3),
    (0.2, 0.2),
    (0.38, 0.34),
    (0.56, 0.24),
  ];
  for (final building in buildings) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * building.$1,
              h * building.$2,
              w * 0.16,
              h * (0.66 - building.$2),
            ),
            const Radius.circular(14),
          ),
        ),
      outlineWidth: 13,
    );
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 2; col++) {
        drawPageRegion(
          canvas,
          Path()
            ..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  w * building.$1 + w * (0.03 + col * 0.06),
                  h * (building.$2 + 0.06 + row * 0.09),
                  w * 0.04,
                  h * 0.045,
                ),
                const Radius.circular(8),
              ),
            ),
          outlineWidth: 8,
        );
      }
    }
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * building.$1 + w * 0.055,
              h * 0.59,
              w * 0.05,
              h * 0.07,
            ),
            const Radius.circular(10),
          ),
        ),
      outlineWidth: 9,
    );
  }

  // Arbol y farola a la derecha.
  final tree = Offset(w * 0.86, h * 0.5);
  canvas.drawLine(
    Offset(tree.dx, tree.dy),
    Offset(tree.dx, tree.dy + h * 0.16),
    stroke(StudioPalette.outline, 13),
  );
  for (final data in <(double, double, double)>[
    (0.86, 0.43, 0.2),
    (0.79, 0.51, 0.14),
    (0.93, 0.52, 0.13),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(w * data.$1, h * data.$2),
            width: w * data.$3,
            height: w * data.$3 * 0.85,
          ),
        ),
      outlineWidth: 12,
    );
  }
  final lamp = Offset(w * 0.73, h * 0.5);
  canvas.drawLine(
    Offset(lamp.dx, lamp.dy - h * 0.06),
    Offset(lamp.dx, lamp.dy + h * 0.16),
    stroke(StudioPalette.outline, 10),
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(lamp.dx, lamp.dy - h * 0.08),
          radius: w * 0.03,
        ),
      ),
    outlineWidth: 9,
  );

  // Acera y calle.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.66, w, h * 0.06)),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28)),
    outlineWidth: 13,
  );
  for (var i = 0; i < 4; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(w * (0.05 + i * 0.13), h * 0.87, w * 0.08, h * 0.03),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 8,
    );
  }

  // Paso de cebra.
  for (var i = 0; i < 5; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addRect(
          Rect.fromLTWH(w * (0.8 + i * 0.035), h * 0.73, w * 0.022, h * 0.26),
        ),
      outlineWidth: 8,
    );
  }

  // Dos coches vistos de frente.
  _drawCityCar(canvas, Offset(w * 0.22, h * 0.82), w * 0.13);
  _drawCityCar(canvas, Offset(w * 0.52, h * 0.9), w * 0.16);
}

/// Coche de frente para la lamina de la ciudad.
void _drawCityCar(Canvas canvas, Offset center, double width) {
  final height = width * 0.8;

  // Ruedas detras de la carroceria.
  for (final dx in [-1, 1]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: center + Offset(width * 0.3 * dx, height * 0.42),
            width: width * 0.26,
            height: width * 0.26,
          ),
        ),
      outlineWidth: 11,
    );
  }

  // Carroceria.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: width, height: height),
          Radius.circular(width * 0.2),
        ),
      ),
    outlineWidth: 12,
  );

  // Techo.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center - Offset(0, height * 0.22),
            width: width * 0.72,
            height: height * 0.44,
          ),
          Radius.circular(width * 0.16),
        ),
      ),
    outlineWidth: 11,
  );

  // Parabrisas.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center - Offset(0, height * 0.24),
            width: width * 0.52,
            height: height * 0.26,
          ),
          Radius.circular(width * 0.1),
        ),
      ),
    outlineWidth: 9,
  );

  // Faros.
  for (final dx in [-1, 1]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: center + Offset(width * 0.32 * dx, height * 0.14),
            width: width * 0.17,
            height: height * 0.17,
          ),
        ),
      outlineWidth: 9,
    );
  }

  // Parrilla.
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: center + Offset(0, height * 0.3),
            width: width * 0.28,
            height: height * 0.1,
          ),
          Radius.circular(width * 0.05),
        ),
      ),
    outlineWidth: 9,
    );
}

