// Laminas nuevas: frutas, verduras y garaje de vehiculos.
//
// Mismo estilo que `pages.dart`: escenas completas en rejilla, contornos
// gruesos y ninguna region superpuesta.

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'backgrounds.dart';
import 'pages.dart';
import 'studio.dart';

/// Lamina de las frutas.
///
/// Puesto de mercado con toldo, cesta y ocho frutas distintas.
void drawPageFruits(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Sol del mercado.
  drawSunShape(canvas, Offset(w * 0.09, h * 0.21), w * 0.05);

  // Toldo a rayas: una sola banda con rayas pintadas encima.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, 0, w, h * 0.13)),
    outlineWidth: 13,
  );
  for (var i = 0; i < 5; i++) {
    if (i.isEven) {
      canvas.drawRect(
        Rect.fromLTWH(w * (i / 5), 0, w / 5, h * 0.13),
        fill(const Color(0x33FF6B6B)),
      );
    }
  }

  // Manzana.
  final apple = Offset(w * 0.27, h * 0.34);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: apple, width: w * 0.15, height: h * 0.16),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(apple.dx - w * 0.008, apple.dy - h * 0.12, w * 0.016, h * 0.05),
          const Radius.circular(6),
        ),
      ),
    outlineWidth: 8,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: apple + Offset(w * 0.045, -h * 0.095),
          width: w * 0.07,
          height: h * 0.035,
        ),
      ),
    outlineWidth: 8,
  );

  // Naranja.
  final orange = Offset(w * 0.45, h * 0.27);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: orange, width: w * 0.13, height: h * 0.14),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: orange + Offset(w * 0.035, -h * 0.075),
          width: w * 0.05,
          height: h * 0.026,
        ),
      ),
    outlineWidth: 8,
  );

  // Platanos.
  final banana = Offset(w * 0.68, h * 0.3);
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(banana.dx - w * 0.09, banana.dy - h * 0.03)
      ..quadraticBezierTo(
        banana.dx, banana.dy + h * 0.09,
        banana.dx + w * 0.09, banana.dy - h * 0.02,
      )
      ..quadraticBezierTo(
        banana.dx, banana.dy + h * 0.045,
        banana.dx - w * 0.09, banana.dy - h * 0.03,
      )
      ..close(),
    outlineWidth: 12,
  );

  // Uvas.
  final grapes = Offset(w * 0.87, h * 0.33);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: grapes + Offset(0, h * 0.01),
          width: w * 0.12,
          height: h * 0.14,
        ),
      ),
    outlineWidth: 11,
  );
  for (final data in <(double, double)>[
    (-0.035, 0.03),
    (0.0, 0.035),
    (0.035, 0.03),
    (-0.018, -0.005),
    (0.018, -0.005),
    (0.0, -0.04),
  ]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: grapes + Offset(w * data.$1, h * data.$2),
            width: w * 0.04,
            height: h * 0.045,
          ),
        ),
      outlineWidth: 7,
    );
  }

  // Cesta.
  final basket = Offset(w * 0.5, h * 0.56);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(basket.dx - w * 0.19, basket.dy - h * 0.08, w * 0.38, h * 0.16),
          Radius.circular(w * 0.04),
        ),
      ),
    outlineWidth: 13,
  );
  for (var i = 0; i < 5; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              basket.dx - w * 0.16 + i * w * 0.075,
              basket.dy - h * 0.07,
              w * 0.02,
              h * 0.14,
            ),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 7,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addArc(
        Rect.fromCenter(
          center: basket,
          width: w * 0.3,
          height: h * 0.2,
        ),
        math.pi,
        math.pi,
      ),
    outlineWidth: 12,
  );

  // Fresa.
  final strawberry = Offset(w * 0.24, h * 0.7);
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(strawberry.dx - w * 0.07, strawberry.dy - h * 0.04)
      ..quadraticBezierTo(
        strawberry.dx, strawberry.dy + h * 0.12,
        strawberry.dx + w * 0.07, strawberry.dy - h * 0.04,
      )
      ..close(),
    outlineWidth: 12,
  );
  for (var i = 0; i < 3; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: strawberry + Offset(w * (i - 1) * 0.03, h * 0.015),
            width: w * 0.016,
            height: h * 0.02,
          ),
        ),
      outlineWidth: 5,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: strawberry + Offset(0, -h * 0.055),
          width: w * 0.11,
          height: h * 0.035,
        ),
      ),
    outlineWidth: 9,
  );

  // Pera.
  final pear = Offset(w * 0.4, h * 0.82);
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(pear.dx, pear.dy - h * 0.11)
      ..quadraticBezierTo(
        pear.dx + w * 0.09, pear.dy - h * 0.02,
        pear.dx + w * 0.05, pear.dy + h * 0.08,
      )
      ..quadraticBezierTo(
        pear.dx, pear.dy + h * 0.13,
        pear.dx - w * 0.05, pear.dy + h * 0.08,
      )
      ..quadraticBezierTo(
        pear.dx - w * 0.09, pear.dy - h * 0.02,
        pear.dx, pear.dy - h * 0.11,
      )
      ..close(),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pear.dx - w * 0.008, pear.dy - h * 0.16, w * 0.016, h * 0.05),
          const Radius.circular(6),
        ),
      ),
    outlineWidth: 8,
  );

  // Sandaia.
  final melon = Offset(w * 0.63, h * 0.78);
  drawPageRegion(
    canvas,
    Path()
      ..addArc(
        Rect.fromCenter(center: melon, width: w * 0.22, height: h * 0.22),
        0,
        math.pi,
      )
      ..close(),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addArc(
        Rect.fromCenter(center: melon, width: w * 0.16, height: h * 0.16),
        0,
        math.pi,
      )
      ..close(),
    outlineWidth: 9,
  );
  for (var i = 0; i < 3; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: melon + Offset(w * (i - 1) * 0.04, -h * 0.005),
            width: w * 0.022,
            height: h * 0.028,
          ),
        ),
      outlineWidth: 5,
    );
  }

  // Cerezas.
  final cherries = Offset(w * 0.84, h * 0.72);
  for (final dx in [-0.04, 0.04]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: cherries + Offset(w * dx, h * 0.03),
            width: w * 0.06,
            height: h * 0.065,
          ),
        ),
      outlineWidth: 10,
    );
  }
  canvas.drawLine(
    cherries + Offset(-w * 0.03, 0),
    cherries + Offset(0, -h * 0.06),
    stroke(StudioPalette.outline, 5),
  );
  canvas.drawLine(
    cherries + Offset(w * 0.03, 0),
    cherries + Offset(0, -h * 0.06),
    stroke(StudioPalette.outline, 5),
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: cherries + Offset(w * 0.01, -h * 0.07),
          width: w * 0.06,
          height: h * 0.025,
        ),
      ),
    outlineWidth: 8,
  );

  // Hojas en el suelo.
  drawGrassTuftShape(canvas, Offset(w * 0.12, h * 0.95), h * 0.05);
  drawFlowerShape(canvas, Offset(w * 0.9, h * 0.92), w * 0.035);
}

/// Lamina de las verduras.
///
/// Puesto de mercado con mantel a cuadros y nueve verduras.
void drawPageVerduras(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Mantel a cuadros.
  for (var row = 0; row < 8; row++) {
    for (var col = 0; col < 8; col++) {
      if ((row + col).isEven) {
        drawPageRegion(
          canvas,
          Path()
            ..addRect(
              Rect.fromLTWH(
                w * col / 8,
                h * row / 8,
                w / 8,
                h / 8,
              ),
            ),
          outlineWidth: 6,
        );
      }
    }
  }

  // Zanahoria.
  final carrot = Offset(w * 0.2, h * 0.28);
  drawPageRegion(
    canvas,
    Path()
      ..moveTo(carrot.dx - w * 0.05, carrot.dy - h * 0.05)
      ..quadraticBezierTo(
        carrot.dx, carrot.dy + h * 0.16,
        carrot.dx + w * 0.05, carrot.dy - h * 0.05,
      )
      ..close(),
    outlineWidth: 12,
  );
  for (var i = 0; i < 3; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: carrot + Offset(w * (i - 1) * 0.022, -h * 0.095),
            width: w * 0.03,
            height: h * 0.05,
          ),
        ),
      outlineWidth: 7,
    );
  }

  // Tomate.
  final tomato = Offset(w * 0.47, h * 0.24);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: tomato, width: w * 0.13, height: h * 0.13),
      ),
    outlineWidth: 13,
  );
  for (var i = 0; i < 4; i++) {
    final angle = i / 4 * 2 * math.pi;
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: tomato +
                Offset(math.cos(angle) * w * 0.04, math.sin(angle) * h * 0.02),
            width: w * 0.035,
            height: h * 0.03,
          ),
        ),
      outlineWidth: 7,
    );
  }

  // Pimiento.
  final pepper = Offset(w * 0.76, h * 0.26);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pepper.dx - w * 0.07, pepper.dy - h * 0.09, w * 0.14, h * 0.18),
          Radius.circular(w * 0.06),
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(pepper.dx - w * 0.012, pepper.dy - h * 0.13, w * 0.024, h * 0.05),
          const Radius.circular(8),
        ),
      ),
    outlineWidth: 8,
  );

  // Calabacin.
  final zucchini = Offset(w * 0.2, h * 0.53);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(zucchini.dx - w * 0.06, zucchini.dy - h * 0.09, w * 0.12, h * 0.18),
          Radius.circular(w * 0.06),
        ),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(zucchini.dx - w * 0.012, zucchini.dy - h * 0.12, w * 0.024, h * 0.04),
          const Radius.circular(8),
        ),
      ),
    outlineWidth: 8,
  );

  // Lechuga.
  final lettuce = Offset(w * 0.47, h * 0.52);
  for (var i = 0; i < 6; i++) {
    final angle = i / 6 * 2 * math.pi;
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: lettuce +
                Offset(math.cos(angle) * w * 0.055, math.sin(angle) * h * 0.05),
            width: w * 0.09,
            height: h * 0.08,
          ),
        ),
      outlineWidth: 9,
    );
  }
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: lettuce, width: w * 0.09, height: h * 0.08),
      ),
    outlineWidth: 10,
  );

  // Berenjena.
  final eggplant = Offset(w * 0.77, h * 0.53);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: eggplant, width: w * 0.11, height: h * 0.16),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(eggplant.dx - w * 0.012, eggplant.dy - h * 0.12, w * 0.024, h * 0.04),
          const Radius.circular(8),
        ),
      ),
    outlineWidth: 8,
  );

  // Maiz.
  final corn = Offset(w * 0.26, h * 0.8);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: corn, width: w * 0.11, height: h * 0.18),
      ),
    outlineWidth: 13,
  );
  for (var i = 0; i < 3; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              corn.dx - w * 0.045 + i * w * 0.03,
              corn.dy - h * 0.07,
              w * 0.014,
              h * 0.14,
            ),
            const Radius.circular(6),
          ),
        ),
      outlineWidth: 6,
    );
  }

  // Brocoli.
  final broccoli = Offset(w * 0.55, h * 0.79);
  for (var i = 0; i < 5; i++) {
    final angle = -math.pi / 2 + (i - 2) * 0.5;
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: broccoli + Offset(math.cos(angle) * w * 0.045, math.sin(angle) * h * 0.04),
            width: w * 0.075,
            height: h * 0.07,
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
          Rect.fromLTWH(
            broccoli.dx - w * 0.022,
            broccoli.dy,
            w * 0.044,
            h * 0.09,
          ),
          const Radius.circular(8),
        ),
      ),
    outlineWidth: 9,
  );

  // Cebolla.
  final onion = Offset(w * 0.83, h * 0.79);
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(center: onion, width: w * 0.13, height: h * 0.13),
      ),
    outlineWidth: 13,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addArc(
        Rect.fromCenter(center: onion, width: w * 0.13, height: h * 0.13),
        -math.pi / 2,
        math.pi / 2,
      )
      ..close(),
    outlineWidth: 8,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(onion.dx - w * 0.008, onion.dy - h * 0.11, w * 0.016, h * 0.05),
          const Radius.circular(6),
        ),
      ),
    outlineWidth: 8,
  );

  // Setas.
  final mushroom = Offset(w * 0.08, h * 0.82);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            mushroom.dx - w * 0.018,
            mushroom.dy,
            w * 0.036,
            h * 0.06,
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
          center: mushroom,
          width: w * 0.11,
          height: h * 0.08,
        ),
        math.pi,
        math.pi,
      ),
    outlineWidth: 9,
  );
}

/// Lamina del garaje de vehiculos.
///
/// Un taller con un coche, una moto, un camion, un bus y sus herramientas.
void drawPageGarage(Canvas canvas, ui.Size size) {
  drawPaper(canvas, size);
  final w = size.width;
  final h = size.height;

  // Pared del taller.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, 0, w, h * 0.2)),
    outlineWidth: 13,
  );

  // Ventanas con travesanos.
  for (var i = 0; i < 3; i++) {
    final left = w * (0.06 + i * 0.14);
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(left, h * 0.04, w * 0.1, h * 0.11),
            Radius.circular(w * 0.015),
          ),
        ),
      outlineWidth: 9,
    );
    canvas.drawLine(
      Offset(left, h * 0.095),
      Offset(left + w * 0.1, h * 0.095),
      stroke(StudioPalette.outline, 5),
    );
    canvas.drawLine(
      Offset(left + w * 0.05, h * 0.04),
      Offset(left + w * 0.05, h * 0.15),
      stroke(StudioPalette.outline, 5),
    );
  }

  // Herramientas colgadas.
  for (final dx in [-0.03, 0.0, 0.03]) {
    drawPageRegion(
      canvas,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              w * (0.78 + dx),
              h * 0.04,
              w * 0.014,
              h * 0.09,
            ),
            const Radius.circular(8),
          ),
        ),
      outlineWidth: 7,
    );
  }

  // Suelo de hormigon.
  drawPageRegion(
    canvas,
    Path()..addRect(Rect.fromLTWH(0, h * 0.2, w, h * 0.8)),
    outlineWidth: 13,
  );

  // Camion (arriba a la izquierda, visto de frente).
  final truck = Offset(w * 0.22, h * 0.33);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(truck.dx - w * 0.09, truck.dy - h * 0.08, w * 0.18, h * 0.16),
          Radius.circular(w * 0.03),
        ),
      ),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(truck.dx - w * 0.065, truck.dy - h * 0.055, w * 0.13, h * 0.05),
          Radius.circular(w * 0.02),
        ),
      ),
    outlineWidth: 9,
  );
  for (final dx in [-0.06, 0.06]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: truck + Offset(w * dx, h * 0.05),
            width: w * 0.03,
            height: h * 0.035,
          ),
        ),
      outlineWidth: 8,
    );
  }

  // Bus (arriba a la derecha, visto de frente).
  final bus = Offset(w * 0.76, h * 0.32);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bus.dx - w * 0.11, bus.dy - h * 0.07, w * 0.22, h * 0.14),
          Radius.circular(w * 0.03),
        ),
      ),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bus.dx - w * 0.085, bus.dy - h * 0.05, w * 0.17, h * 0.055),
          Radius.circular(w * 0.02),
        ),
      ),
    outlineWidth: 9,
  );
  for (final dx in [-0.075, 0.075]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: bus + Offset(w * dx, h * 0.045),
            width: w * 0.028,
            height: h * 0.032,
          ),
        ),
      outlineWidth: 8,
    );
  }

  // Coche grande en el centro.
  final car = Offset(w * 0.4, h * 0.63);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(car.dx - w * 0.13, car.dy - h * 0.1, w * 0.26, h * 0.2),
          Radius.circular(w * 0.05),
        ),
      ),
    outlineWidth: 14,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(car.dx - w * 0.095, car.dy - h * 0.15, w * 0.19, h * 0.09),
          Radius.circular(w * 0.04),
        ),
      ),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(car.dx - w * 0.075, car.dy - h * 0.135, w * 0.15, h * 0.06),
          Radius.circular(w * 0.03),
        ),
      ),
    outlineWidth: 9,
  );
  for (final dx in [-0.085, 0.085]) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: car + Offset(w * dx, h * 0.06),
            width: w * 0.035,
            height: h * 0.04,
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
          Rect.fromLTWH(car.dx - w * 0.04, car.dy + h * 0.02, w * 0.08, h * 0.03),
          Radius.circular(10),
        ),
      ),
    outlineWidth: 8,
  );

  // Moto a la derecha.
  final moto = Offset(w * 0.83, h * 0.64);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(moto.dx - w * 0.045, moto.dy - h * 0.1, w * 0.09, h * 0.2),
          Radius.circular(w * 0.04),
        ),
      ),
    outlineWidth: 12,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addOval(
        Rect.fromCenter(
          center: moto + Offset(0, -h * 0.07),
          width: w * 0.08,
          height: h * 0.055,
        ),
      ),
    outlineWidth: 10,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(moto.dx - w * 0.065, moto.dy - h * 0.08, w * 0.13, h * 0.028),
          Radius.circular(10),
        ),
      ),
    outlineWidth: 9,
  );

  // Neumaticos apilados.
  final tires = Offset(w * 0.12, h * 0.86);
  for (var i = 0; i < 2; i++) {
    drawPageRegion(
      canvas,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: tires + Offset(0, -h * 0.03 * i),
            width: w * 0.13,
            height: h * 0.06,
          ),
        ),
      outlineWidth: 10,
    );
  }

  // Caja de herramientas.
  final toolbox = Offset(w * 0.58, h * 0.9);
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(toolbox.dx - w * 0.08, toolbox.dy - h * 0.05, w * 0.16, h * 0.1),
          Radius.circular(w * 0.02),
        ),
      ),
    outlineWidth: 11,
  );
  drawPageRegion(
    canvas,
    Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(toolbox.dx - w * 0.025, toolbox.dy - h * 0.085, w * 0.05, h * 0.04),
          Radius.circular(10),
        ),
      ),
    outlineWidth: 9,
  );
}
