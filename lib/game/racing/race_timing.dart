/// Modelo matematico de la velocidad de la pista.
///
/// La velocidad es **constante**: el niño no tiene que ir mas rapido ni
/// mas despacio a mitad de carrera y la pista no "se le escapa". Cada mundo
/// tiene su velocidad (via `speedScale`), pero dentro de un mundo **nunca
/// cambia**.
///
/// Es codigo puro (sin Flutter): se puede testear de forma aislada.
class RaceTiming {
  const RaceTiming._();

  /// Velocidad base de la pista (px/s).
  ///
  /// Deliberadamente suave: el niño pequeno debe poder seguir el ritmo.
  static const double baseSpeed = 150;

  /// Velocidad a los [seconds] segundos.
  ///
  /// Siempre la misma: la carrera no acelera ni frena sola.
  static double speedAt(double seconds, double speedScale) =>
      baseSpeed * speedScale;

  /// Distancia recorrida en [seconds] segundos **sin chocar**.
  ///
  /// Si el nino choca, el mundo se para: la carrera tarda mas, nunca menos.
  static double distanceAfter(double seconds, double speedScale) =>
      baseSpeed * speedScale * seconds;

  /// Distancia de cada tramo del recorrido.
  ///
  /// Con [laps] tramos y la distancia total calculada para
  /// [targetSeconds], la meta aparece exactamente en el minuto previsto.
  static double lapDistance({
    required int targetSeconds,
    required int laps,
    required double speedScale,
  }) {
    if (laps <= 0) {
      return distanceAfter(targetSeconds.toDouble(), speedScale);
    }
    return distanceAfter(targetSeconds.toDouble(), speedScale) / laps;
  }

  /// Tiempo necesario para recorrer [distance].
  static double timeForDistance(double distance, double speedScale) =>
      distance / (baseSpeed * speedScale);
}

/// Velocidades de los modos de juego (px/s).
class ClimbSpeed {
  const ClimbSpeed._();

  /// Velocidad maxima al acelerar a tope.
  static const double maxSpeed = 210;

  /// Velocidad cuando no se pulsa nada (el vehiculo sigue rodando).
  static const double cruiseSpeed = 70;

  /// Velocidad minima al frenar.
  static const double minSpeed = 0;

  /// Aceleracion al pulsar el boton de acelerar (px/s por segundo).
  static const double acceleration = 150;

  /// Freno (px/s por segundo).
  static const double braking = 260;

  /// Gravedad del mundo (px/s^2): decide como de alto vuela el vehiculo.
  static const double gravity = 900;

  /// Velocidad minima para despegar en un rasante.
  static const double minLaunchSpeed = 40;

  /// ¿El vehiculo tiene que **despegar** en este frame?
  ///
  /// El terreno cae [drop] pixeles de golpe. Si cae mas rapido de lo que la
  /// gravedad permite seguir (en un frame), el vehiculo **se queda en el
  /// aire** y empieza la parabola: ese es el salto.
  static bool shouldLeaveGround({
    required double drop,
    required double dt,
    required double speed,
  }) {
    if (speed < minLaunchSpeed || drop <= 0) {
      return false;
    }
    final freeFall = 0.5 * gravity * dt * dt;
    return drop > freeFall + 1.5;
  }
}
