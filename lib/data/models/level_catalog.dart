import 'level_spec.dart';

/// Catalogo ordenado de los doce mundos de carreras.
///
/// El orden de la lista **es** la progresion: para desbloquear un mundo hay
/// que haber completado el anterior.
class LevelCatalog {
  const LevelCatalog._();

  /// Recorrido completo, de mas facil a mas emocionante.
  static const List<LevelSpec> levels = [
    LevelSpec(
      id: 'nivel_01',
      number: 1,
      name: 'Pradera',
      trackId: 'pradera',
      effect: LevelEffect.petals,
      speedScale: 0.85,
      targetSeconds: 65,
    ),
    LevelSpec(
      id: 'nivel_02',
      number: 2,
      name: 'Playa',
      trackId: 'playa',
      effect: LevelEffect.bubbles,
      speedScale: 0.88,
      targetSeconds: 66,
    ),
    LevelSpec(
      id: 'nivel_03',
      number: 3,
      name: 'Noche',
      trackId: 'noche',
      effect: LevelEffect.fireflies,
      speedScale: 0.92,
      targetSeconds: 68,
    ),
    LevelSpec(
      id: 'nivel_04',
      number: 4,
      name: 'Nieve',
      trackId: 'nieve',
      effect: LevelEffect.snow,
      speedScale: 0.95,
      targetSeconds: 68,
    ),
    LevelSpec(
      id: 'nivel_05',
      number: 5,
      name: 'Bosque',
      trackId: 'bosque',
      effect: LevelEffect.leaves,
      speedScale: 0.98,
      targetSeconds: 70,
    ),
    LevelSpec(
      id: 'nivel_06',
      number: 6,
      name: 'Ciudad',
      trackId: 'ciudad',
      effect: LevelEffect.sparkles,
      speedScale: 1,
      targetSeconds: 70,
    ),
    LevelSpec(
      id: 'nivel_07',
      number: 7,
      name: 'Desierto',
      trackId: 'desierto',
      effect: LevelEffect.sand,
      speedScale: 1.02,
      targetSeconds: 72,
    ),
    LevelSpec(
      id: 'nivel_08',
      number: 8,
      name: 'Selva',
      trackId: 'selva',
      effect: LevelEffect.butterflies,
      speedScale: 1.05,
      targetSeconds: 72,
    ),
    LevelSpec(
      id: 'nivel_09',
      number: 9,
      name: 'Puerto',
      trackId: 'puerto',
      effect: LevelEffect.waves,
      speedScale: 1.07,
      targetSeconds: 74,
    ),
    LevelSpec(
      id: 'nivel_10',
      number: 10,
      name: 'Volcan',
      trackId: 'volcan',
      effect: LevelEffect.embers,
      speedScale: 1.1,
      targetSeconds: 74,
    ),
    LevelSpec(
      id: 'nivel_11',
      number: 11,
      name: 'Espacio',
      trackId: 'espacio',
      effect: LevelEffect.shootingStars,
      speedScale: 1.13,
      targetSeconds: 76,
    ),
    LevelSpec(
      id: 'nivel_12',
      number: 12,
      name: 'Estadio',
      trackId: 'estadio',
      effect: LevelEffect.confetti,
      speedScale: 1.16,
      targetSeconds: 78,
    ),
  ];

  /// Primer nivel de la progresion.
  static LevelSpec get first => levels.first;

  /// Busca un nivel por identificador.
  static LevelSpec? byId(String id) {
    for (final level in levels) {
      if (level.id == id) {
        return level;
      }
    }
    return null;
  }

  /// Posicion del nivel dentro de la progresion (-1 si no existe).
  static int indexOf(String id) {
    for (var i = 0; i < levels.length; i++) {
      if (levels[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  /// Nivel siguiente a [id], o `null` si es el ultimo.
  static LevelSpec? nextAfter(String id) {
    final index = indexOf(id);
    if (index < 0 || index >= levels.length - 1) {
      return null;
    }
    return levels[index + 1];
  }

  /// `true` si [id] es el ultimo nivel.
  static bool isLast(String id) => indexOf(id) == levels.length - 1;
}
