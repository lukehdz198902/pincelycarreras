import 'dart:math' as math;

/// Modelo matematico de la velocidad de la pista.
///
/// El niño **marca el ritmo**: mantiene pulsado el acelerador para avanzar y
/// suelta o frena cuando quiere. Por eso la velocidad **no cambia sola**.
///
/// Es codigo puro (sin Flutter): se puede testear de forma aislada.
class RaceTiming {
  const RaceTiming._();

  /// Velocidad maxima del mundo (con el acelerador a tope), en px/s.
  ///
  /// Es suave a proposito: el niño pequeño tiene que poder seguir el ritmo.
  static const double maxSpeed = 180;

  /// Aceleracion al pulsar el acelerador (px/s por segundo).
  static const double acceleration = 260;

  /// Freno (px/s por segundo).
  static const double braking = 420;

  /// Rozamiento: al soltar el acelerador el coche baja de velocidad (px/s^2).
  static const double coasting = 190;

  /// Velocidad a los [seconds] segundos, a aceleracion constante.
  static double speedAt(double seconds, double speedScale) =>
      math.min(maxSpeed * speedScale, acceleration * seconds);

  /// Distancia maxima recorrida en [seconds] segundos acelerando siempre.
  static double distanceAfter(double seconds, double speedScale) {
    final vmax = maxSpeed * speedScale;
    final rampTime = vmax / acceleration;
    if (seconds <= rampTime) {
      return 0.5 * acceleration * seconds * seconds;
    }
    final rampDistance = 0.5 * acceleration * rampTime * rampTime;
    return rampDistance + vmax * (seconds - rampTime);
  }

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

  /// Tiempo necesario para recorrer [distance] acelerando siempre.
  static double timeForDistance(double distance, double speedScale) {
    final vmax = maxSpeed * speedScale;
    final rampTime = vmax / acceleration;
    final rampDistance = 0.5 * acceleration * rampTime * rampTime;
    if (distance <= rampDistance) {
      return math.sqrt(2 * distance / acceleration);
    }
    return rampTime + (distance - rampDistance) / vmax;
  }
}
