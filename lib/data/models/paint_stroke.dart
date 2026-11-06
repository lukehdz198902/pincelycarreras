import 'dart:ui' show Color, Offset, Rect;

import 'package:flutter/foundation.dart';

/// Tipo de trazo pintado sobre la lamina.
enum PaintStrokeKind {
  /// Trazo de pintura.
  brush,

  /// Borrado (elimina otros trazos, no pinta de blanco).
  eraser,
}

/// Un trazo continuo sobre la lamina.
///
/// Las coordenadas se guardan en el **espacio logico de la lamina**
/// (independiente de la resolucion de la pantalla) para que el dibujo
/// se vea igual en cualquier dispositivo.
@immutable
class PaintStroke {
  /// Crea un trazo.
  const PaintStroke({
    required this.points,
    required this.colorValue,
    required this.width,
    this.kind = PaintStrokeKind.brush,
  });

  /// Puntos del trazo en espacio de lamina.
  final List<Offset> points;

  /// Color del trazo (valor ARGB).
  final int colorValue;

  /// Grosor del trazo en pixeles de lamina.
  final double width;

  /// Tipo de trazo.
  final PaintStrokeKind kind;

  /// Color del trazo.
  Color get color => Color(colorValue);

  /// Devuelve una copia del trazo.
  PaintStroke copyWith({
    List<Offset>? points,
    int? colorValue,
    double? width,
    PaintStrokeKind? kind,
  }) {
    return PaintStroke(
      points: points ?? this.points,
      colorValue: colorValue ?? this.colorValue,
      width: width ?? this.width,
      kind: kind ?? this.kind,
    );
  }

  /// Serializa a JSON.
  Map<String, dynamic> toJson() => {
    'c': colorValue,
    'w': width,
    'k': kind.index,
    'p': <double>[
      for (final point in points) ...[point.dx, point.dy],
    ],
  };

  /// Reconstruye un trazo desde JSON.
  factory PaintStroke.fromJson(Map<String, dynamic> json) {
    final raw = (json['p'] as List?) ?? const <double>[];
    final points = <Offset>[];
    for (var i = 0; i + 1 < raw.length; i += 2) {
      points.add(
        Offset(
          (raw[i] as num).toDouble(),
          (raw[i + 1] as num).toDouble(),
        ),
      );
    }
    return PaintStroke(
      points: points,
      colorValue: (json['c'] as num?)?.toInt() ?? 0xFF000000,
      width: (json['w'] as num?)?.toDouble() ?? 24,
      kind: PaintStrokeKind.values[(json['k'] as num?)?.toInt() ?? 0],
    );
  }
}

/// Una region de la lamina rellenada con el bote de pintura.
///
/// Se almacena como una lista de tramos horizontales (`Rect`) en vez de
/// pixeles sueltos: ocupa poco y se dibuja muy rapido.
@immutable
class RegionFill {
  /// Crea un relleno de region.
  const RegionFill({required this.colorValue, required this.spans});

  /// Color del relleno (valor ARGB).
  final int colorValue;

  /// Tramos horizontales que componen la region.
  final List<Rect> spans;

  /// Color del relleno.
  Color get color => Color(colorValue);

  /// `true` si la region no tiene tramos (relleno vacio).
  bool get isEmpty => spans.isEmpty;

  /// Serializa a JSON.
  Map<String, dynamic> toJson() => {
    'c': colorValue,
    'r': <double>[
      for (final span in spans) ...[
        span.left,
        span.top,
        span.width,
        span.height,
      ],
    ],
  };

  /// Reconstruye un relleno desde JSON.
  factory RegionFill.fromJson(Map<String, dynamic> json) {
    final raw = (json['r'] as List?) ?? const <double>[];
    final spans = <Rect>[];
    for (var i = 0; i + 3 < raw.length; i += 4) {
      spans.add(
        Rect.fromLTWH(
          (raw[i] as num).toDouble(),
          (raw[i + 1] as num).toDouble(),
          (raw[i + 2] as num).toDouble(),
          (raw[i + 3] as num).toDouble(),
        ),
      );
    }
    return RegionFill(
      colorValue: (json['c'] as num?)?.toInt() ?? 0xFF000000,
      spans: spans,
    );
  }
}

/// El dibujo completo de una lamina: trazos y rellenos de region.
@immutable
class Painting {
  /// Crea un dibujo.
  const Painting({this.strokes = const [], this.fills = const []});

  /// Trazos de pincel.
  final List<PaintStroke> strokes;

  /// Rellenos de bote de pintura.
  final List<RegionFill> fills;

  /// `true` si el dibujo esta vacio.
  bool get isEmpty => strokes.isEmpty && fills.isEmpty;

  /// Devuelve una copia con los campos indicados modificados.
  Painting copyWith({
    List<PaintStroke>? strokes,
    List<RegionFill>? fills,
  }) {
    return Painting(
      strokes: strokes ?? this.strokes,
      fills: fills ?? this.fills,
    );
  }

  /// Serializa a JSON.
  Map<String, dynamic> toJson() => {
    's': strokes.map((stroke) => stroke.toJson()).toList(),
    'f': fills.map((fill) => fill.toJson()).toList(),
  };

  /// Reconstruye un dibujo desde JSON.
  factory Painting.fromJson(Map<String, dynamic> json) {
    final strokes = (json['s'] as List?) ?? const [];
    final fills = (json['f'] as List?) ?? const [];
    return Painting(
      strokes: strokes
          .map((item) => PaintStroke.fromJson(item as Map<String, dynamic>))
          .toList(),
      fills: fills
          .map((item) => RegionFill.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
