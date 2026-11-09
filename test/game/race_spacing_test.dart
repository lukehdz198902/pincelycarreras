import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/racing/racing_game.dart';

void main() {
  group('Espaciado de la pista', () {
    test('los obstaculos estan bien separados', () {
      // Un obstaculo cada 3,4 s: el nino tiene tiempo de sobra.
      expect(RacingGame.obstacleSpacing, greaterThanOrEqualTo(3));
    });

    test('las estrellas van mas seguidas que los obstaculos', () {
      expect(RacingGame.starSpacing, lessThan(RacingGame.obstacleSpacing));
    });

    test('una estrella nunca aparece pegada a un obstaculo', () {
      // La separacion minima es de 1,4 s: nunca se empalman.
      expect(RacingGame.minSeparation, greaterThan(1));
    });
  });
}
