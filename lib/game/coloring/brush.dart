import 'dart:ui' show Color;

/// Herramientas disponibles en el estudio de pintura.
enum ToolKind {
  /// Pincel: dibuja trazos continuos.
  brush,

  /// Bote de pintura: rellena la region cerrada bajo el dedo.
  bucket,

  /// Borrador: elimina trazos y rellenos.
  eraser,
}

/// Estado del pincel activo.
///
/// Inmutable: la pantalla crea una copia nueva cada vez que el nino
/// cambia de herramienta, color o grosor.
class Brush {
  /// Crea un pincel.
  const Brush({
    required this.kind,
    required this.colorValue,
    this.widthIndex = 1,
  });

  /// Herramienta activa.
  final ToolKind kind;

  /// Color seleccionado (valor ARGB).
  final int colorValue;

  /// Indice dentro de `GameSizes.brushWidths`.
  final int widthIndex;

  /// Color del pincel.
  Color get color => Color(colorValue);

  /// Grosor actual del trazo en pixeles de lamina.
  double get width => brushWidths[widthIndex.clamp(0, brushWidths.length - 1)];

  /// Grosores disponibles (pixeles de lamina).
  static const List<double> brushWidths = [12, 24, 40];

  /// Devuelve una copia del pincel.
  Brush copyWith({
    ToolKind? kind,
    int? colorValue,
    int? widthIndex,
  }) {
    return Brush(
      kind: kind ?? this.kind,
      colorValue: colorValue ?? this.colorValue,
      widthIndex: widthIndex ?? this.widthIndex,
    );
  }
}
