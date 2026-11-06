import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

/// Fondo que se desplaza de forma infinita bajo la pista.
///
/// Dibuja tres capas: el fondo tileable de la pista, el asfalto con los
/// carriles y los bordillos laterales.
class TrackScroller extends PositionComponent {
  /// Crea el fondo de la pista.
  TrackScroller({
    required this.backgroundImage,
    required this.asphaltImage,
    required this.curbImage,
    required this.roadWidth,
  });

  /// Imagen del fondo tileable (cesped, arena o noche).
  final ui.Image backgroundImage;

  /// Imagen del asfalto con los separadores de carril.
  final ui.Image asphaltImage;

  /// Imagen del bordillo.
  final ui.Image curbImage;

  /// Ancho logico de la carretera.
  double roadWidth;

  /// Distancia recorrida por el mundo (en pixeles).
  double scroll = 0;

  /// Lado del tile de fondo.
  static const double backgroundTileSize = 256;

  /// Ancho del bordillo en pantalla.
  static const double curbWidth = 18;

  @override
  void render(Canvas canvas) {
    final width = size.x;
    final height = size.y;
    if (width <= 0 || height <= 0) {
      return;
    }

    _drawTiles(
      canvas,
      backgroundImage,
      origin: Offset.zero,
      tileWidth: backgroundTileSize,
      tileHeight: backgroundTileSize,
      target: Rect.fromLTWH(0, 0, width, height),
      scroll: scroll,
      quality: FilterQuality.low,
    );

    final roadLeft = (width - roadWidth) / 2;
    _drawTiles(
      canvas,
      asphaltImage,
      origin: Offset(roadLeft, 0),
      tileWidth: roadWidth,
      tileHeight: roadWidth,
      target: Rect.fromLTWH(roadLeft, 0, roadWidth, height),
      scroll: scroll,
      quality: FilterQuality.medium,
    );

    final curbHeight = curbWidth * 2;
    _drawTiles(
      canvas,
      curbImage,
      origin: Offset(roadLeft - curbWidth, 0),
      tileWidth: curbWidth,
      tileHeight: curbHeight,
      target: Rect.fromLTWH(roadLeft - curbWidth, 0, curbWidth, height),
      scroll: scroll,
      quality: FilterQuality.medium,
    );
    _drawTiles(
      canvas,
      curbImage,
      origin: Offset(roadLeft + roadWidth, 0),
      tileWidth: curbWidth,
      tileHeight: curbHeight,
      target: Rect.fromLTWH(roadLeft + roadWidth, 0, curbWidth, height),
      scroll: scroll,
      quality: FilterQuality.medium,
    );
  }

  void _drawTiles(
    Canvas canvas,
    ui.Image image, {
    required Offset origin,
    required double tileWidth,
    required double tileHeight,
    required Rect target,
    required double scroll,
    required FilterQuality quality,
  }) {
    final source = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final paint = Paint()..filterQuality = quality;
    final offsetY = scroll % tileHeight;
    for (var y = offsetY - tileHeight; y < target.height; y += tileHeight) {
      for (var x = 0.0; x < target.width; x += tileWidth) {
        canvas.drawImageRect(
          image,
          source,
          Rect.fromLTWH(origin.dx + x, origin.dy + y, tileWidth, tileHeight),
          paint,
        );
      }
    }
  }
}
