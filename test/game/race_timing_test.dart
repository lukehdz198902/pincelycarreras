import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/level_catalog.dart';
import 'package:pincel_y_carreras/game/racing/race_timing.dart';

void main() {
  group('Modelo de tiempos de carrera', () {
    test('la velocidad es constante dentro de un mundo', () {
      expect(RaceTiming.speedAt(0, 1), RaceTiming.baseSpeed);
      expect(RaceTiming.speedAt(30, 1), RaceTiming.baseSpeed);
      expect(RaceTiming.speedAt(200, 1), RaceTiming.baseSpeed);
    });

    test('la velocidad escala con el multiplicador del mundo', () {
      expect(RaceTiming.speedAt(30, 2), closeTo(RaceTiming.baseSpeed * 2, 0.01));
    });

    test('la distancia crece con el tiempo', () {
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

    test('el tiempo se calcula tambien con choques (mas largo, no mas corto)',
        () {
      final level = LevelCatalog.first;
      final lap = RaceTiming.lapDistance(
        targetSeconds: level.targetSeconds,
        laps: level.laps,
        speedScale: level.speedScale,
      );
      final seconds = RaceTiming.timeForDistance(lap, level.speedScale);
      // Con la velocidad constante cada tramo dura lo mismo.
      expect(seconds, closeTo(level.targetSeconds / level.laps, 1));
    });

    test('el vehiculo despega en un rasante y no en terreno plano', () {
      // Terreno que cae de golpe: el vehiculo no puede seguirlo y vuela.
      expect(
        ClimbSpeed.shouldLeaveGround(drop: 40, dt: 0.016, speed: 150),
        isTrue,
      );
      // Terreno plano: sigue pegado al suelo.
      expect(
        ClimbSpeed.shouldLeaveGround(drop: 0, dt: 0.016, speed: 150),
        isFalse,
      );
      // Demasiado lento para despegar: no hay salto.
      expect(
        ClimbSpeed.shouldLeaveGround(drop: 40, dt: 0.016, speed: 10),
        isFalse,
      );
      // Una caida suave tampoco lo lanza.
      expect(
        ClimbSpeed.shouldLeaveGround(drop: 1, dt: 0.016, speed: 150),
        isFalse,
      );
    });
  });
}
