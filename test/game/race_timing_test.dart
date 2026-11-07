import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/level_catalog.dart';
import 'package:pincel_y_carreras/game/racing/race_timing.dart';

void main() {
  group('Modelo de tiempos de carrera', () {
    test('la velocidad sube solo si el nino acelera', () {
      // Acelerando desde parado la velocidad crece.
      final afterSecond = RaceTiming.speedAt(1, 1);
      expect(afterSecond, greaterThan(0));
      expect(afterSecond, lessThanOrEqualTo(RaceTiming.maxSpeed));

      // El tope es la velocidad maxima del mundo.
      expect(RaceTiming.speedAt(60, 1), RaceTiming.maxSpeed);
      // Y escala con el multiplicador del mundo.
      expect(RaceTiming.speedAt(60, 2), RaceTiming.maxSpeed * 2);
    });

    test('la distancia crece con el tiempo acelerando siempre', () {
      expect(
        RaceTiming.distanceAfter(60, 1),
        greaterThan(RaceTiming.distanceAfter(30, 1)),
      );
    });

    test('la distancia de un tramo cubre el tiempo objetivo', () {
      final level = LevelCatalog.first;
      final lap = RaceTiming.lapDistance(
        targetSeconds: level.targetSeconds,
        laps: level.laps,
        speedScale: level.speedScale,
      );
      final total = lap * level.laps;
      final seconds = RaceTiming.timeForDistance(total, level.speedScale);
      expect(seconds, closeTo(level.targetSeconds, 1));
    });

    test('todos los mundos duran al menos un minuto', () {
      for (final level in LevelCatalog.levels) {
        final lap = RaceTiming.lapDistance(
          targetSeconds: level.targetSeconds,
          laps: level.laps,
          speedScale: level.speedScale,
        );
        final total = lap * level.laps;
        final seconds = RaceTiming.timeForDistance(total, level.speedScale);
        expect(
          seconds,
          greaterThanOrEqualTo(60),
          reason: 'El mundo ${level.id} dura menos de un minuto',
        );
      }
    });

    test('el tiempo de un tramo es el mismo en todos los tramos', () {
      final level = LevelCatalog.first;
      final lap = RaceTiming.lapDistance(
        targetSeconds: level.targetSeconds,
        laps: level.laps,
        speedScale: level.speedScale,
      );
      expect(
        RaceTiming.timeForDistance(lap, level.speedScale),
        closeTo(level.targetSeconds / level.laps, 1),
      );
    });
  });
}
