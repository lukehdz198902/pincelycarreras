import 'package:flutter/foundation.dart';

import '../../core/constants/asset_paths.dart';

/// Pistas disponibles para las carreras.
///
/// La pista la elige el **nivel**, asi que no hay desbloqueo por estrellas:
/// todos los escenarios son accesibles desde el primer nivel que los usa.
/// Cada mundo tiene su **asfalto** y su **bordillo**, para que las pistas no
/// sean todas iguales.
@immutable
class TrackSpec {
  /// Crea la especificacion de una pista.
  const TrackSpec({
    required this.id,
    required this.name,
    required this.assetPath,
    this.asphaltAssetPath = AssetPaths.asphalt,
    this.curbAssetPath = AssetPaths.curb,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre de la pista.
  final String name;

  /// Ruta del fondo (tile repetible).
  final String assetPath;

  /// Ruta del asfalto (la carretera).
  final String asphaltAssetPath;

  /// Ruta del bordillo (las rayas del lateral).
  final String curbAssetPath;
}
