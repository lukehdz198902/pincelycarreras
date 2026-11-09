import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/racing/track_generator.dart';

void main() {
  group('TrackGenerator', () {
    test('solo hay un obstaculo por fila: siempre quedan dos carriles libres',
        () {
      final generator = TrackGenerator(seed: 42);
      for (var i = 0; i < 2000; i++) {
        final lane = generator.nextObstacleLane();
        expect(lane, inInclusiveRange(0, 2));
      }
    });

    test('el obstaculo nunca aparece en el mismo carril que el anterior', () {
      final generator = TrackGenerator(seed: 7);
      int? previous;
      for (var i = 0; i < 2000; i++) {
        final lane = generator.nextObstacleLane();
        expect(lane, isNot(previous));
        previous = lane;
      }
    });

    test('la estrella no aparece en el carril del ultimo obstaculo', () {
      final generator = TrackGenerator(seed: 13);
      int? obstacleLane;
      for (var i = 0; i < 2000; i++) {
        final lane = generator.nextStarLane(forbiddenLane: obstacleLane);
        expect(lane, inInclusiveRange(0, 2));
        expect(lane, isNot(obstacleLane));
        obstacleLane = generator.nextObstacleLane();
      }
    });

    test('la estrella no aparece en el mismo carril que la anterior', () {
      final generator = TrackGenerator(seed: 99);
      int? previous;
      for (var i = 0; i < 2000; i++) {
        final lane = generator.nextStarLane();
        expect(lane, isNot(previous));
        previous = lane;
      }
    });

    test('con la misma semilla produce la misma pista', () {
      final a = TrackGenerator(seed: 5);
      final b = TrackGenerator(seed: 5);
      for (var i = 0; i < 50; i++) {
        expect(a.nextObstacleLane(), b.nextObstacleLane());
        expect(a.nextStarLane(), b.nextStarLane());
      }
    });
  });
}
