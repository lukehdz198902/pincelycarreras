import 'dart:math' as math;

/// Genera el contenido de la pista con reglas **amables** para ninos.
///
/// Las reglas son deliberadamente conservadoras:
///
/// - **un solo obstaculo** por fila: siempre quedan dos carriles libres;
/// - el obstaculo **nunca** aparece en el mismo carril que el anterior, asi
///   que el nino siempre tiene que moverse un poco;
/// - la estrella va a un carril distinto del ultimo obstaculo y de la ultima
///   estrella, y ademas el juego la separa en el tiempo del obstaculo para
///   que **nunca se empalmen**.
class TrackGenerator {
  /// Crea un generador con una semilla (util para pruebas deterministas).
  TrackGenerator({int? seed}) : _random = math.Random(seed);

  final math.Random _random;

  /// Ultimo carril con un obstaculo.
  int? _lastObstacleLane;

  /// Ultimo carril con una estrella.
  int? _lastStarLane;

  /// Elige el carril del proximo obstaculo.
  ///
  /// Nunca repite el carril del obstaculo anterior: el nino tiene que
  /// apartarse en cada obstaculo.
  int nextObstacleLane() {
    final options = <int>[
      for (var lane = 0; lane < 3; lane++)
        if (lane != _lastObstacleLane) lane,
    ];
    final lane = options[_random.nextInt(options.length)];
    _lastObstacleLane = lane;
    return lane;
  }

  /// Elige el carril de la proxima estrella.
  ///
  /// No puede ser el carril del [forbiddenLane] (el del ultimo obstaculo)
  /// ni el de la ultima estrella.
  int nextStarLane({int? forbiddenLane}) {
    final options = <int>[
      for (var lane = 0; lane < 3; lane++)
        if (lane != forbiddenLane && lane != _lastStarLane) lane,
    ];
    if (options.isEmpty) {
      // Caso imposible (3 carriles y 2 exclusiones), pero por seguridad.
      return forbiddenLane ?? _lastStarLane ?? 1;
    }
    final lane = options[_random.nextInt(options.length)];
    _lastStarLane = lane;
    return lane;
  }
}
