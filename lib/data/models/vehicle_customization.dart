import 'package:flutter/foundation.dart';

import '../../core/constants/asset_paths.dart';

/// Calca que se pinta en la carrocería del vehiculo.
///
/// Las calcas se dibujan en blanco: el nino elige el color en el taller y
/// el juego las tiñe en tiempo real.
@immutable
class DecalSpec {
  /// Crea la especificacion de una calca.
  const DecalSpec({
    required this.id,
    required this.name,
    required this.assetPath,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre de la calca.
  final String name;

  /// Ruta de la imagen (en blanco, para tintarla).
  final String assetPath;
}

/// Personaje que viaja con el nino en el vehiculo.
@immutable
class CharacterSpec {
  /// Crea la especificacion de un personaje.
  const CharacterSpec({
    required this.id,
    required this.name,
    required this.assetPath,
  });

  /// Identificador unico y estable.
  final String id;

  /// Nombre del personaje.
  final String name;

  /// Ruta de la imagen.
  final String assetPath;
}

/// Catalogo del taller: calcas y personajes.
class VehicleCustomization {
  const VehicleCustomization._();

  /// Calcas disponibles.
  static const List<DecalSpec> decals = [
    DecalSpec(
      id: 'rayas',
      name: 'Rayas',
      assetPath: AssetPaths.decalStripes,
    ),
    DecalSpec(
      id: 'estrella',
      name: 'Estrella',
      assetPath: AssetPaths.decalStar,
    ),
    DecalSpec(
      id: 'llama',
      name: 'Llama',
      assetPath: AssetPaths.decalFlame,
    ),
    DecalSpec(
      id: 'corazon',
      name: 'Corazón',
      assetPath: AssetPaths.decalHeart,
    ),
    DecalSpec(
      id: 'numero',
      name: 'Número',
      assetPath: AssetPaths.decalNumber,
    ),
  ];

  /// Personajes disponibles.
  static const List<CharacterSpec> characters = [
    CharacterSpec(
      id: 'gato',
      name: 'Gato',
      assetPath: AssetPaths.characterCat,
    ),
    CharacterSpec(
      id: 'perro',
      name: 'Perro',
      assetPath: AssetPaths.characterDog,
    ),
    CharacterSpec(
      id: 'conejo',
      name: 'Conejo',
      assetPath: AssetPaths.characterRabbit,
    ),
    CharacterSpec(
      id: 'robot',
      name: 'Robot',
      assetPath: AssetPaths.characterRobot,
    ),
  ];

  /// Busca una calca por identificador.
  static DecalSpec? decalById(String id) {
    for (final decal in decals) {
      if (decal.id == id) {
        return decal;
      }
    }
    return null;
  }

  /// Busca un personaje por identificador.
  static CharacterSpec? characterById(String id) {
    for (final character in characters) {
      if (character.id == id) {
        return character;
      }
    }
    return null;
  }
}
