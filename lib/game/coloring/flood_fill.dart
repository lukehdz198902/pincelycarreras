import 'dart:typed_data';
import 'dart:ui' show Rect;

/// Raster de una lamina, usado por el bote de pintura.
///
/// Permite rellenar la region cerrada que hay bajo el dedo, respetando
/// los contornos de la lamina.
class PageRaster {
  /// Crea un raster a partir de pixeles RGBA.
  PageRaster(this.pixels, this.width, this.height);

  /// Pixeles en formato RGBA (4 bytes por pixel).
  final Uint8List pixels;

  /// Ancho en pixeles.
  final int width;

  /// Alto en pixelos.
  final int height;

  /// Color de las zonas rellenables (el papel de la lamina).
  static const int paperRed = 0xF2;
  static const int paperGreen = 0xE6;
  static const int paperBlue = 0xCF;

  /// Tolerancia por canal para considerar que dos pixeles son del mismo color.
  static const int tolerance = 30;

  /// `true` si el pixel pertenece a una zona rellenable.
  bool isFillable(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) {
      return false;
    }
    final index = (y * width + x) * 4;
    final r = pixels[index];
    final g = pixels[index + 1];
    final b = pixels[index + 2];
    final alpha = pixels[index + 3];
    if (alpha < 200) {
      return false;
    }
    return (r - paperRed).abs() <= tolerance &&
        (g - paperGreen).abs() <= tolerance &&
        (b - paperBlue).abs() <= tolerance;
  }

  /// Devuelve los tramos horizontales de la region que contiene (x, y).
  ///
  /// Devuelve una lista vacia si el punto no esta en una zona rellenable.
  List<Rect> fillRegion(int x, int y) {
    if (!isFillable(x, y)) {
      return const [];
    }

    final visited = Uint8List(width * height);
    final stack = <int>[y * width + x];
    final spans = <Rect>[];

    while (stack.isNotEmpty) {
      final seed = stack.removeLast();
      final seedY = seed ~/ width;
      final seedX = seed % width;
      if (visited[seed] != 0 || !isFillable(seedX, seedY)) {
        continue;
      }

      // Expande la fila hacia izquierda y derecha.
      var left = seedX;
      while (left > 0 &&
          visited[seedY * width + left - 1] == 0 &&
          isFillable(left - 1, seedY)) {
        left--;
      }
      var right = seedX;
      while (right < width - 1 &&
          visited[seedY * width + right + 1] == 0 &&
          isFillable(right + 1, seedY)) {
        right++;
      }

      for (var i = left; i <= right; i++) {
        visited[seedY * width + i] = 1;
      }
      spans.add(
        Rect.fromLTRB(
          left.toDouble(),
          seedY.toDouble(),
          right + 1.0,
          seedY + 1.0,
        ),
      );

      // Siembra la fila superior y la inferior.
      for (final neighbourY in [seedY - 1, seedY + 1]) {
        if (neighbourY < 0 || neighbourY >= height) {
          continue;
        }
        var x2 = left;
        while (x2 <= right) {
          if (visited[neighbourY * width + x2] == 0 &&
              isFillable(x2, neighbourY)) {
            stack.add(neighbourY * width + x2);
            while (x2 <= right &&
                visited[neighbourY * width + x2] == 0 &&
                isFillable(x2, neighbourY)) {
              x2++;
            }
          } else {
            x2++;
          }
        }
      }
    }

    // Orden canonico: de arriba abajo y de izquierda a derecha. Asi dos
    // consultas sobre la misma region devuelven exactamente los mismos
    // tramos y se puede detectar si ya esta pintada.
    spans.sort((a, b) {
      final byTop = a.top.compareTo(b.top);
      return byTop != 0 ? byTop : a.left.compareTo(b.left);
    });
    return spans;
  }
}
