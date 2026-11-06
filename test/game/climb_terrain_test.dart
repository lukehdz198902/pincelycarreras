import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/racing/climb_terrain.dart';

void main() {
  group('Terreno de las subidas', () {
    test('genera un recorrido largo con colinas', () {
      final terrain = ClimbTerrain(seed: 7);
      expect(terrain.length, greaterThan(3000));
      expect(terrain.points.length, greaterThan(200));
      expect(
        terrain.segments.any((s) => s.kind == ClimbSegmentKind.hill),
        isTrue,
      );
    });

    test('la superficie avanza hacia la derecha', () {
      final terrain = ClimbTerrain(seed: 3);
      // Fuera de los loops el terreno solo va hacia la derecha; dentro de
      // un loop el vehiculo da la vuelta y vuelve hacia atras.
      expect(terrain.points.last.dx, greaterThan(terrain.points.first.dx));
      var backwards = 0;
      for (var i = 1; i < terrain.points.length; i++) {
        if (terrain.points[i].dx < terrain.points[i - 1].dx - 0.01) {
          backwards++;
        }
      }
      // Solo hay retrocesos en los loops: son pocos puntos seguidos.
      expect(backwards, lessThan(terrain.points.length ~/ 4));
    });

    test('incluye vueltas de 360 grados', () {
      final terrain = ClimbTerrain(seed: 5, loopCount: 2);
      final loops = terrain.segments
          .where((s) => s.kind == ClimbSegmentKind.loop)
          .length;
      expect(loops, greaterThanOrEqualTo(1));
    });

    test('en la vuelta el vehiculo queda del reves', () {
      final terrain = ClimbTerrain(seed: 5, loopCount: 2);
      final loop = terrain.segments
          .firstWhere((s) => s.kind == ClimbSegmentKind.loop);
      // A mitad del loop el terreno va hacia la izquierda: el vehiculo
      // esta boca arriba (angulo cercano a PI).
      final middle = terrain.angleAt(loop.startX + loop.length / 2);
      expect(middle.abs(), greaterThan(math.pi / 2));
    });

    test('la posicion y el angulo son continuos', () {
      final terrain = ClimbTerrain(seed: 9);
      var previous = terrain.positionAt(0);
      for (var s = 20.0; s < terrain.length - 20; s += 20) {
        final position = terrain.positionAt(s);
        // Dentro de un loop el vehiculo va hacia la izquierda, pero el
        // terreno nunca da saltos verticales (el niño no marea).
        expect(
          (position.dy - previous.dy).abs(),
          lessThan(40),
          reason: 'el terreno no debe dar saltos',
        );
        previous = position;
      }
    });

    test('fuera del rango devuelve los extremos', () {
      final terrain = ClimbTerrain(seed: 4);
      expect(terrain.positionAt(-50), terrain.points.first);
      expect(terrain.positionAt(terrain.length + 500), terrain.points.last);
    });

    test('cada subida tiene un trazado reproducible', () {
      final a = ClimbTerrain(seed: 42);
      final b = ClimbTerrain(seed: 42);
      expect(a.points.length, b.points.length);
      expect(a.points.last.dx, b.points.last.dx);
    });
  });
}
