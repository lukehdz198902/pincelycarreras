import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Tipo de vehiculo del juego.
///
/// El tipo decide el **tamaño en pista** y el **dibujo** de la lamina del
/// garaje: un camion ocupa mas sitio que una moto.
enum VehicleType {
  /// Coche pequeno y agil.
  car,

  /// Camion: ancho y largo, gira mas despacio.
  truck,

  /// Moto: estrecha y rapida.
  moto,

  /// Bus escolar: el mas grande.
  bus,

  /// Tractor: ancho pero corto.
  tractor,

  /// Furgoneta de reparto.
  van,
}

/// Vehiculo jugable.
///
/// Los identificadores son **estables**: se guardan en
/// `shared_preferences`, por lo que no deben renombrarse nunca.
@immutable
class VehicleSpec {
  /// Crea la especificacion de un vehiculo.
  const VehicleSpec({
    required this.id,
    required this.name,
    required this.type,
    required this.assetPath,
    required this.color,
    this.unlockStars = 0,
    this.widthFactor = 1,
    this.heightFactor = 1,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre legible del vehiculo.
  final String name;

  /// Tipo de vehiculo.
  final VehicleType type;

  /// Ruta del sprite visto desde arriba.
  final String assetPath;

  /// Color principal (para las miniaturas y el garage).
  final Color color;

  /// Estrellas necesarias para desbloquearlo (0 = siempre disponible).
  final int unlockStars;

  /// Multiplicador de anchura respecto al coche base.
  final double widthFactor;

  /// Multiplicador de longitud respecto al coche base.
  final double heightFactor;

  /// `true` si el vehiculo esta disponible desde el principio.
  bool get isFree => unlockStars == 0;
}
