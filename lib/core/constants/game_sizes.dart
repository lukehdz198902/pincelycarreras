/// Medidas de la interfaz y del mundo de juego.
///
/// Todos los valores tactiles respetan el minimo de 60 dp definido en
/// `AGENTS.md` (regla de accesibilidad infantil).
class GameSizes {
  const GameSizes._();

  /// Minimo absoluto del area tactil (regla de accesibilidad).
  static const double minTouchTarget = 64;

  /// Lado de los botones grandes del menu.
  static const double menuButtonSize = 128;

  /// Lado de los botones medianos (barras de herramientas).
  static const double toolButtonSize = 72;

  /// Lado de los botones pequenos (barra superior).
  static const double smallButtonSize = 60;

  /// Diametro de un circulo de color.
  static const double colorSwatchSize = 64;

  /// Ancho de la carretera en pixeles logicos (maximo).
  static const double maxRoadWidth = 420;

  /// Fraccion de la ALTURA de la pantalla que ocupa la carretera.
  ///
  /// El mundo del juego esta girado 90 grados (la pantalla esta en
  /// `RotatedBox`), asi que `size.x` del juego es la altura de la pantalla.
  /// La carretera ocupa solo una parte: el resto es decorado, para que se
  /// vea que el coche corre por un sitio y no por una pared.
  static const double roadWidthFraction = 0.58;

  /// Ancho de un carril.
  static const double laneWidth = 120;

  /// Ancho del coche.
  static const double carWidth = 76;

  /// Alto del coche.
  static const double carHeight = 116;

  /// Margen lateral de la carretera respecto a la pantalla.
  static const double roadMargin = 24;

  /// Segundos de inmovilizacion tras un choque (nunca hay "game over").
  static const double crashStunSeconds = 1;

  /// Grosores de pincel disponibles (en pixeles de lamina).
  static const List<double> brushWidths = [12, 24, 40];

  /// Radio de borrado (en pixeles de lamina).
  static const double eraserRadius = 32;
}
