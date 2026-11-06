import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/game_content.dart';
import 'package:pincel_y_carreras/data/models/progress.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/painting_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProgressService', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('guarda y recupera el progreso', () async {
      final service = await ProgressService.create();
      const progress = Progress(
        totalStars: 9,
        unlockedStickers: {'estrella'},
        selectedVehicle: 'azul',
        bestTimes: {'nivel_01': 62},
      );

      service.save(progress);
      await service.flush();

      final restored = service.load();
      expect(restored.totalStars, 9);
      expect(restored.unlockedStickers, {'estrella'});
      expect(restored.selectedVehicle, 'azul');
      expect(restored.bestTimes, {'nivel_01': 62});
    });

    test('guarda y recupera el dibujo de una lamina', () async {
      final service = await ProgressService.create();
      expect(service.loadDrawing('coche').isEmpty, isTrue);

      final painting = PaintingFixture.sample();
      await service.saveDrawing('coche', painting);

      final restored = service.loadDrawing('coche');
      expect(restored.strokes.length, painting.strokes.length);
      expect(restored.fills.length, painting.fills.length);
      expect(restored.strokes.first.points.first.dx, 12);
    });

    test('borrar el dibujo lo elimina', () async {
      final service = await ProgressService.create();
      await service.saveDrawing('coche', PaintingFixture.sample());
      await service.clearDrawing('coche');
      expect(service.loadDrawing('coche').isEmpty, isTrue);
    });
  });

  group('ProgressProvider', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('las estrellas solo suman y nunca se pierden', () async {
      final service = await ProgressService.create();
      final provider = ProgressProvider(service)..load();

      provider.addStars(5);
      expect(provider.totalStars, 5);
      provider.addStars(3);
      expect(provider.totalStars, 8);
    });

    test('desbloquea el vehiculo que corresponde a las estrellas', () async {
      final service = await ProgressService.create();
      final provider = ProgressProvider(service)..load();

      expect(provider.isVehicleUnlocked('rojo'), isTrue);
      expect(provider.isVehicleUnlocked('moto'), isFalse);

      provider.addStars(5);
      expect(provider.isVehicleUnlocked('verde'), isTrue);

      final events = provider.takePendingUnlocks();
      expect(
        events.any((event) => event.kind == UnlockKind.car),
        isTrue,
        reason: 'debe avisar del nuevo vehiculo',
      );
    });

    test('no se puede seleccionar un vehiculo bloqueado', () async {
      final service = await ProgressService.create();
      final provider = ProgressProvider(service)..load();

      provider.selectVehicle('bus');
      expect(provider.progress.selectedVehicle, 'rojo');
    });

    test('el record de tiempo solo mejora', () async {
      final service = await ProgressService.create();
      final provider = ProgressProvider(service)..load();

      provider.recordBestTime('nivel_01', 70);
      expect(provider.bestTimeFor('nivel_01'), 70);

      provider.recordBestTime('nivel_01', 90);
      expect(provider.bestTimeFor('nivel_01'), 70, reason: 'no puede empeorar');

      provider.recordBestTime('nivel_01', 55);
      expect(provider.bestTimeFor('nivel_01'), 55);
    });

    test('los colores base estan siempre disponibles', () async {
      final service = await ProgressService.create();
      final provider = ProgressProvider(service)..load();

      for (final color in GameContent.baseColors) {
        expect(provider.isColorUnlocked(color.id), isTrue);
      }
      expect(provider.isColorUnlocked('dorado'), isFalse);
    });
  });
}
