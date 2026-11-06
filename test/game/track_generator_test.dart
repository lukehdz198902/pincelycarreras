import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/racing/track_generator.dart';

void main() {
  group('TrackGenerator', () {
    test('nunca bloquea los tres carriles a la vez', () {
      final generator = TrackGenerator(seed: 42);
      for (var i = 0; i < 2000; i++) {
        final row = generator.next();
        expect(
          row.obstacleLanes.length,
          lessThan(3),
          reason: 'siempre debe quedar un carril libre',
        );
      }
    });

    test('la estrella nunca aparece en un carril bloqueado', () {
      final generator = TrackGenerator(seed: 7);
      for (var i = 0; i < 2000; i++) {
        final row = generator.next();
        final starLane = row.starLane;
        if (starLane != null) {
          expect(row.obstacleLanes.contains(starLane), isFalse);
        }
      }
    });

    test('los carriles bloqueados siempre estan en rango', () {
      final generator = TrackGenerator(seed: 99);
      for (var i = 0; i < 500; i++) {
        final row = generator.next();
        for (final lane in row.obstacleLanes) {
          expect(lane, inInclusiveRange(0, 2));
        }
        final starLane = row.starLane;
        if (starLane != null) {
          expect(starLane, inInclusiveRange(0, 2));
        }
      }
    });

    test('con la misma semilla produce la misma pista', () {
      final a = TrackGenerator(seed: 5);
      final b = TrackGenerator(seed: 5);
      for (var i = 0; i < 50; i++) {
        final rowA = a.next();
        final rowB = b.next();
        expect(rowA.obstacleLanes, rowB.obstacleLanes);
        expect(rowA.starLane, rowB.starLane);
      }
    });
  });
}
