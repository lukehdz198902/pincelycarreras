/// Carriles posibles de la pista.
///
/// El juego tiene siempre **3 carriles**: el control es un unico toque que
/// nunca puede fallar, pensado para ninos de 3 anos.
enum Lane {
  /// Carril izquierdo.
  left,

  /// Carril central (donde arranca el coche).
  center,

  /// Carril derecho.
  right,
}

/// Indice numerico del carril (0 = izquierda, 1 = centro, 2 = derecha).
extension LaneIndex on Lane {
  /// Devuelve el indice del carril.
  int get index => switch (this) {
    Lane.left => 0,
    Lane.center => 1,
    Lane.right => 2,
  };

  /// Devuelve el carril de un indice (0..2).
  static Lane fromIndex(int index) => switch (index) {
    0 => Lane.left,
    1 => Lane.center,
    _ => Lane.right,
  };
}
