import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Pista del modo "Subidas" (vista de lado).
@immutable
class ClimbTrackSpec {
  /// Crea la especificacion de una subida.
  const ClimbTrackSpec({
    required this.id,
    required this.name,
    required this.skyColor,
    required this.hillColor,
    required this.groundColor,
    required this.seed,
    this.loopCount = 1,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre de la subida.
  final String name;

  /// Color del cielo.
  final Color skyColor;

  /// Color de las colinas del fondo.
  final Color hillColor;

  /// Color del terreno.
  final Color groundColor;

  /// Semilla del trazado (cambia las colinas).
  final int seed;

  /// Numero de vueltas de 360 grados.
  final int loopCount;
}

/// Catalogo de las subidas.
///
/// El modo "Subidas" es un extra: **todos** los mundos estan abiertos desde
/// el principio (no hay progresion bloqueante) para que el niño pueda
/// probarlos todos y quedarse con el que mas le guste.
class ClimbCatalog {
  const ClimbCatalog._();

  /// Todas las subidas.
  static const List<ClimbTrackSpec> tracks = [
    ClimbTrackSpec(
      id: 'subida_pradera',
      name: 'Colinas',
      skyColor: Color(0xFF8ED8FF),
      hillColor: Color(0xFF6FBF73),
      groundColor: Color(0xFFB07A45),
      seed: 11,
      loopCount: 1,
    ),
    ClimbTrackSpec(
      id: 'subida_playa',
      name: 'Dunas',
      skyColor: Color(0xFFFFE3A3),
      hillColor: Color(0xFFE8C88C),
      groundColor: Color(0xFFCE9A54),
      seed: 22,
      loopCount: 1,
    ),
    ClimbTrackSpec(
      id: 'subida_noche',
      name: 'Luna',
      skyColor: Color(0xFF2B2D6B),
      hillColor: Color(0xFF3E4C8A),
      groundColor: Color(0xFF3A3F55),
      seed: 33,
      loopCount: 2,
    ),
    ClimbTrackSpec(
      id: 'subida_nieve',
      name: 'Cumbre',
      skyColor: Color(0xFFDFF3FF),
      hillColor: Color(0xFFB9D8EC),
      groundColor: Color(0xFFE8F4FF),
      seed: 44,
      loopCount: 1,
    ),
    ClimbTrackSpec(
      id: 'subida_bosque',
      name: 'Tronco',
      skyColor: Color(0xFFBFE9C0),
      hillColor: Color(0xFF3E8E4E),
      groundColor: Color(0xFF6E4B2A),
      seed: 55,
      loopCount: 2,
    ),
    ClimbTrackSpec(
      id: 'subida_ciudad',
      name: 'Ruedas',
      skyColor: Color(0xFFBFD7FF),
      hillColor: Color(0xFF8A93A6),
      groundColor: Color(0xFF4A5060),
      seed: 66,
      loopCount: 3,
    ),
  ];

  /// Busca una subida por identificador.
  static ClimbTrackSpec? byId(String id) {
    for (final track in tracks) {
      if (track.id == id) {
        return track;
      }
    }
    return null;
  }
}
