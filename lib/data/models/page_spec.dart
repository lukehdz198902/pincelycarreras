import 'package:flutter/foundation.dart';

/// Laminas para colorear del estudio de pintura.
@immutable
class ColoringPageSpec {
  /// Crea la especificacion de una lamina.
  const ColoringPageSpec({
    required this.id,
    required this.name,
    required this.assetPath,
    this.unlockStars = 0,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre de la lamina.
  final String name;

  /// Ruta de la imagen de la lamina.
  final String assetPath;

  /// Estrellas necesarias para desbloquearla (0 = siempre disponible).
  final int unlockStars;

  /// `true` si la lamina esta disponible desde el principio.
  bool get isFree => unlockStars == 0;
}
