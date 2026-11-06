import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';

/// Especificacion de un color disponible para pintar.
@immutable
class ColorSpec {
  /// Crea una especificacion de color.
  const ColorSpec({
    required this.id,
    required this.color,
    this.unlockStars = 0,
  });

  /// Identificador unico y estable (se usa como clave de guardado).
  final String id;

  /// Color mostrado en el selector.
  final Color color;

  /// Estrellas necesarias para desbloquearlo (0 = siempre disponible).
  final int unlockStars;

  /// Nombre legible (se usa solo en depuracion y pruebas).
  String get label => id;

  /// Devuelve una copia con otro color.
  ColorSpec copyWith({Color? color}) => ColorSpec(
    id: id,
    color: color ?? this.color,
    unlockStars: unlockStars,
  );
}
