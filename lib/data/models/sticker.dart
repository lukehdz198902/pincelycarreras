import 'package:flutter/foundation.dart';

/// Pegatina coleccionable del libro de recompensas.
@immutable
class StickerSpec {
  /// Crea la especificacion de una pegatina.
  const StickerSpec({
    required this.id,
    required this.name,
    required this.assetPath,
    this.unlockStars = 0,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre de la pegatina.
  final String name;

  /// Ruta del sprite.
  final String assetPath;

  /// Estrellas necesarias para desbloquearla (0 = siempre disponible).
  final int unlockStars;

  /// `true` si la pegatina esta disponible desde el principio.
  bool get isFree => unlockStars == 0;
}
