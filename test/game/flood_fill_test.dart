import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/coloring/flood_fill.dart';

/// Construye un raster de prueba: un cuadrado de papel rodeado de contorno.
PageRaster _buildRaster({
  required int width,
  required int height,
  required int borderThickness,
}) {
  final pixels = Uint8List(width * height * 4);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final isBorder = x < borderThickness ||
          y < borderThickness ||
          x >= width - borderThickness ||
          y >= height - borderThickness;
      final index = (y * width + x) * 4;
      if (isBorder) {
        pixels[index] = 0x6B;
        pixels[index + 1] = 0x6F;
        pixels[index + 2] = 0x76;
      } else {
        pixels[index] = PageRaster.paperRed;
        pixels[index + 1] = PageRaster.paperGreen;
        pixels[index + 2] = PageRaster.paperBlue;
      }
      pixels[index + 3] = 0xFF;
    }
  }
  return PageRaster(pixels, width, height);
}

/// Construye un raster con un marco de contorno en el centro: hay papel
/// dentro (como una forma cerrada) y papel alrededor (como el cielo).
PageRaster _buildRasterWithHole({
  required int width,
  required int height,
  required int holeSize,
}) {
  final pixels = Uint8List(width * height * 4);
  final start = (width - holeSize) ~/ 2;
  final end = start + holeSize;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final insideHole = x >= start && x < end && y >= start && y < end;
      final isFrame = insideHole &&
          (x == start || x == end - 1 || y == start || y == end - 1);
      final index = (y * width + x) * 4;
      if (isFrame) {
        pixels[index] = 0x6B;
        pixels[index + 1] = 0x6F;
        pixels[index + 2] = 0x76;
      } else {
        pixels[index] = PageRaster.paperRed;
        pixels[index + 1] = PageRaster.paperGreen;
        pixels[index + 2] = PageRaster.paperBlue;
      }
      pixels[index + 3] = 0xFF;
    }
  }
  return PageRaster(pixels, width, height);
}

void main() {
  group('PageRaster', () {
    test('reconoce el papel como zona rellenable', () {
      final raster = _buildRaster(width: 10, height: 10, borderThickness: 2);
      expect(raster.isFillable(5, 5), isTrue);
      expect(raster.isFillable(0, 0), isFalse, reason: 'es el contorno');
    });

    test('rellena solo la region interior', () {
      final raster = _buildRaster(width: 10, height: 10, borderThickness: 2);
      final spans = raster.fillRegion(5, 5);

      final pixels = spans.fold<int>(
        0,
        (total, span) => total + (span.width * span.height).round(),
      );
      expect(pixels, 36, reason: 'el interior es de 6x6');
      expect(spans.length, 6, reason: 'una fila por span');
      for (final span in spans) {
        expect(span.left, greaterThanOrEqualTo(2));
        expect(span.right, lessThanOrEqualTo(8));
      }
    });

    test('rellena por separado el interior y el exterior de una forma', () {
      final raster = _buildRasterWithHole(
        width: 12,
        height: 12,
        holeSize: 6,
      );

      final inside = raster.fillRegion(5, 5);
      final outside = raster.fillRegion(1, 1);

      final insidePixels = inside.fold<int>(
        0,
        (total, span) => total + (span.width * span.height).round(),
      );
      final outsidePixels = outside.fold<int>(
        0,
        (total, span) => total + (span.width * span.height).round(),
      );

      expect(insidePixels, 16, reason: 'el interior es de 4x4');
      expect(outsidePixels, 108, reason: 'el exterior es de 12x12 menos 6x6');
    });

    test('no rellena nada al pulsar sobre el contorno', () {
      final raster = _buildRaster(width: 10, height: 10, borderThickness: 2);
      expect(raster.fillRegion(0, 0), isEmpty);
    });

    test('dos puntos de la misma región devuelven los mismos tramos', () {
      final raster = _buildRaster(width: 10, height: 10, borderThickness: 2);
      final a = raster.fillRegion(3, 3);
      final b = raster.fillRegion(6, 6);
      expect(a.length, b.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i], b[i]);
      }
    });
  });
}
