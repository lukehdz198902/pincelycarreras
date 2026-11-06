import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/progress.dart';

void main() {
  group('Progress', () {
    test('arranca vacio pero con selecciones validas', () {
      const progress = Progress();
      expect(progress.totalStars, 0);
      expect(progress.selectedVehicle, 'rojo');
      expect(progress.selectedTrack, 'pradera');
      expect(progress.selectedPage, 'coche');
      expect(progress.selectedLevel, 'nivel_01');
      expect(progress.bestTimes, isEmpty);
    });

    test('copyWith solo cambia los campos indicados', () {
      const progress = Progress(totalStars: 3);
      final updated = progress.copyWith(totalStars: 7);
      expect(updated.totalStars, 7);
      expect(updated.selectedVehicle, 'rojo');
      expect(progress.totalStars, 3, reason: 'el original es inmutable');
    });

    test('sobrevive a una ida y vuelta por JSON', () {
      final original = Progress(
        totalStars: 12,
        sessionStars: 3,
        unlockedStickers: {'estrella'},
        unlockedColors: {'dorado'},
        unlockedCars: {'amarillo'},
        unlockedPages: {'casa'},
        completedLevels: {'nivel_01'},
        bestTimes: const {'nivel_01': 65},
        selectedVehicle: 'amarillo',
        selectedTrack: 'playa',
        selectedPage: 'casa',
        selectedLevel: 'nivel_02',
        bestLaps: 4,
      );

      final restored = Progress.fromJson(original.toJson());

      expect(restored.totalStars, 12);
      expect(restored.sessionStars, 3);
      expect(restored.unlockedStickers, {'estrella'});
      expect(restored.unlockedColors, {'dorado'});
      expect(restored.unlockedCars, {'amarillo'});
      expect(restored.unlockedPages, {'casa'});
      expect(restored.completedLevels, {'nivel_01'});
      expect(restored.bestTimes, {'nivel_01': 65});
      expect(restored.selectedVehicle, 'amarillo');
      expect(restored.selectedTrack, 'playa');
      expect(restored.selectedPage, 'casa');
      expect(restored.selectedLevel, 'nivel_02');
      expect(restored.bestLaps, 4);
    });

    test('un JSON vacio no rompe el modelo', () {
      final restored = Progress.fromJson(const {});
      expect(restored.totalStars, 0);
      expect(restored.unlockedColors, isEmpty);
    });
  });
}
