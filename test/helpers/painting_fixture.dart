import 'dart:ui' show Offset, Rect;

import 'package:pincel_y_carreras/data/models/paint_stroke.dart';

/// Datos de prueba para el modelo de dibujo.
class PaintingFixture {
  const PaintingFixture._();

  /// Dibujo de ejemplo con un trazo y un relleno de region.
  static Painting sample() {
    return Painting(
      strokes: [
        PaintStroke(
          points: const [Offset(12, 20), Offset(30, 40)],
          colorValue: 0xFFFF4757,
          width: 24,
        ),
      ],
      fills: [
        RegionFill(
          colorValue: 0xFF2ED573,
          spans: const [Rect.fromLTWH(0, 0, 10, 10)],
        ),
      ],
    );
  }
}
