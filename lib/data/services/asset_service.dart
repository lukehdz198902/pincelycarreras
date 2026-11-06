import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Carga y precarga de imagenes del juego.
///
/// Se usa `rootBundle` + `instantiateImageCodec` para obtener el `ui.Image`
/// que necesita el lienzo de pintura (y que Flame no expone todavia).
class AssetService {
  const AssetService._();

  /// Carga una imagen desde los assets.
  static Future<ui.Image> loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  /// Precarga una lista de imagenes ignorando los fallos.
  ///
  /// Un asset que falle no debe impedir que el juego arranque.
  static Future<void> preloadImages(List<String> assetPaths) async {
    for (final path in assetPaths) {
      try {
        final image = await loadImage(path);
        image.dispose();
      } catch (error) {
        debugPrint('[Pincel] No se pudo precargar $path: $error');
      }
    }
  }
}
