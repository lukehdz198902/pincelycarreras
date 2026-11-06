import 'dart:math' as math;

/// Una fila generada de la pista.
///
/// Nunca se bloquean los tres carriles: siempre queda al menos uno libre
/// para que el nino nunca se quede atrapado.
class TrackRow {
  /// Crea una fila de pista.
  const TrackRow({required this.obstacleLanes, this.starLane});

  /// Carriles ocupados por obstaculos (indices 0..2).
  final Set<int> obstacleLanes;

  /// Carril con una estrella coleccionable (si lo hay).
  final int? starLane;

  /// `true` si esta fila no tiene obstaculos.
  bool get isEmpty => obstacleLanes.isEmpty;
}

/// Genera filas de pista con reglas "amables" para ninos.
///
/// Reglas:
/// - nunca se bloquean los tres carriles a la vez;
/// - dos filas consecutivas no bloquean exactamente los mismos carriles
///   (obligan a mover el coche);
/// - la estrella aparece en un carril libre, para premiar el movimiento.
class TrackGenerator {
  /// Crea un generador con una semilla (util para pruebas deterministas).
  TrackGenerator({int? seed}) : _random = math.Random(seed);

  final math.Random _random;
  Set<int> _lastBlocked = const {};
  int _rowsSinceObstacle = 0;

  /// Genera la siguiente fila de la pista.
  TrackRow next() {
    final freeLane = _random.nextInt(3);

    // La mayoria de las filas bloquean **un solo** carril: siempre queda
    // mucho espacio libre para esquivar. Solo de vez en cuando se bloquean
    // dos (los obstaculos ya van bien espaciados).
    final blockedCount = _random.nextDouble() < 0.25 ? 2 : 1;
    final blocked = <int>{};
    for (var lane = 0; lane < 3 && blocked.length < blockedCount; lane++) {
      if (lane == freeLane) {
        continue;
      }
      blocked.add(lane);
    }

    // Nunca dos filas identicas seguidas.
    if (_sameLanes(blocked, _lastBlocked) && _rowsSinceObstacle > 0) {
      blocked.clear();
      for (var lane = 0; lane < 3; lane++) {
        if (lane != freeLane && !_sameLanes({lane}, _lastBlocked)) {
          blocked.add(lane);
          break;
        }
      }
      if (blocked.isEmpty) {
        blocked.add((freeLane + 1) % 3);
      }
    }

    _lastBlocked = Set<int>.from(blocked);
    _rowsSinceObstacle = blocked.isEmpty ? _rowsSinceObstacle + 1 : 0;

    // La estrella va a un carril libre distinto del de la fila anterior.
    int? starLane;
    if (_random.nextDouble() < 0.55) {
      final candidates = <int>[
        for (var lane = 0; lane < 3; lane++)
          if (!blocked.contains(lane)) lane,
      ];
      if (candidates.isNotEmpty) {
        starLane = candidates[_random.nextInt(candidates.length)];
      }
    }

    return TrackRow(obstacleLanes: blocked, starLane: starLane);
  }

  static bool _sameLanes(Set<int> a, Set<int> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final lane in a) {
      if (!b.contains(lane)) {
        return false;
      }
    }
    return true;
  }
}
