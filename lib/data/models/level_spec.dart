import 'package:flutter/foundation.dart';

/// Animacion ambiental que distingue cada mundo.
///
/// Todas se dibujan con primitivas (sin assets extra): asi cada mundo tiene
/// una personalidad propia sin aumentar el peso de la app.
enum LevelEffect {
  /// Petalos rosas y amarillos que caen meciendose.
  petals,

  /// Mariposas que revolotean en diagonal.
  butterflies,

  /// Burbujas que suben desde el agua.
  bubbles,

  /// Globos de colores que ascienden lentamente.
  balloons,

  /// Luciernagas que parpadean en la oscuridad.
  fireflies,

  /// Estrellas fugaces que cruzan el cielo.
  shootingStars,

  /// Confeti de fiesta que cae girando.
  confetti,

  /// Copos de nieve que caen con viento suave.
  snow,

  /// Hojas de otono que caen en espiral.
  leaves,

  /// Chispas urbanas que titilan.
  sparkles,

  /// Granos de arena que vuelan en el desierto.
  sand,

  /// Olas que rompen en el puerto.
  waves,

  /// Brasas que suben del volcan.
  embers,
}

/// Medalla conseguida en un mundo.
///
/// Es un incentivo, nunca una penalizacion: todo el que llega a la meta
/// consigue al menos la de bronce.
enum LevelMedal {
  /// Sin medalla (el mundo aun no se ha superado).
  none,

  /// Bronce: llego a la meta.
  bronze,

  /// Plata: lo supero en el tiempo previsto.
  silver,

  /// Oro: lo supero con tiempo de sobra.
  gold,
}

/// Definicion de un nivel de carreras.
///
/// Los niveles son una **progresion amable**: se desbloquean en orden al
/// completar el anterior y ninguno se pierde ni se bloquea por fallar.
@immutable
class LevelSpec {
  /// Crea la especificacion de un nivel.
  const LevelSpec({
    required this.id,
    required this.number,
    required this.name,
    required this.trackId,
    required this.effect,
    this.speedScale = 1,
    this.starsPerLap = 3,
    this.laps = 3,
    this.targetSeconds = 70,
  });

  /// Identificador unico y estable (se guarda en `shared_preferences`).
  final String id;

  /// Numero visible del nivel (1..12).
  final int number;

  /// Nombre corto del mundo.
  final String name;

  /// Identificador de la pista que usa.
  final String trackId;

  /// Animacion ambiental exclusiva del mundo.
  final LevelEffect effect;

  /// Multiplicador de velocidad de la pista.
  final double speedScale;

  /// Estrellas que se ganan al cruzar cada banderin.
  final int starsPerLap;

  /// Numero de tramos del recorrido (el ultimo termina en la meta).
  final int laps;

  /// Duracion objetivo de la carrera en segundos (nunca menos de 60).
  ///
  /// El mundo se recorre a una distancia calculada para que la carrera
  /// dure al menos un minuto; si el nino choca, dura todavia mas.
  final int targetSeconds;

  /// `true` si es el primer nivel de la progresion.
  bool get isFirst => number <= 1;

  /// Medalla que se consigue con el tiempo [seconds].
  ///
  /// El tiempo previsto da la plata y un 15 % mas rapido, el oro.
  LevelMedal medalFor(int seconds) {
    if (seconds <= 0) {
      return LevelMedal.none;
    }
    if (seconds <= targetSeconds * 0.85) {
      return LevelMedal.gold;
    }
    if (seconds <= targetSeconds) {
      return LevelMedal.silver;
    }
    return LevelMedal.bronze;
  }

  /// Estrellas de regalo al superar el mundo.
  static const int completionBonus = 5;
}
