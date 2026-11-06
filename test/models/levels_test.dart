import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/game_content.dart';
import 'package:pincel_y_carreras/data/models/level_catalog.dart';
import 'package:pincel_y_carreras/data/models/level_spec.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Catalogo de mundos', () {
    test('hay al menos doce mundos', () {
      expect(LevelCatalog.levels.length, greaterThanOrEqualTo(12));
    });

    test('los identificadores son unicos y estan en orden', () {
      final ids = LevelCatalog.levels.map((level) => level.id).toSet();
      expect(ids.length, LevelCatalog.levels.length);

      for (var i = 0; i < LevelCatalog.levels.length; i++) {
        expect(LevelCatalog.levels[i].number, i + 1);
      }
    });

    test('cada mundo tiene un ambiente animado diferente', () {
      final effects = LevelCatalog.levels.map((level) => level.effect).toSet();
      expect(effects.length, LevelCatalog.levels.length);
    });

    test('cada mundo usa una pista existente del catalogo', () {
      for (final level in LevelCatalog.levels) {
        expect(
          GameContent.trackById(level.trackId),
          isNotNull,
          reason: 'La pista ${level.trackId} no existe',
        );
      }
    });

    test('la velocidad sube de forma progresiva', () {
      for (var i = 1; i < LevelCatalog.levels.length; i++) {
        expect(
          LevelCatalog.levels[i].speedScale,
          greaterThan(LevelCatalog.levels[i - 1].speedScale),
        );
      }
    });

    test('cada carrera dura al menos un minuto', () {
      for (final level in LevelCatalog.levels) {
        expect(level.targetSeconds, greaterThanOrEqualTo(60));
      }
    });

    test('el siguiente mundo se encadena correctamente', () {
      expect(LevelCatalog.nextAfter('nivel_01')?.id, 'nivel_02');
      expect(
        LevelCatalog.nextAfter(LevelCatalog.levels.last.id),
        isNull,
      );
      expect(LevelCatalog.isLast(LevelCatalog.levels.last.id), isTrue);
      expect(LevelCatalog.indexOf('nivel_03'), 2);
      expect(LevelCatalog.indexOf('nivel_99'), -1);
    });
  });

  group('Catalogo de vehiculos', () {
    test('hay coches, moto, camion, bus, tractor y furgoneta', () {
      final types = GameContent.vehicles.map((v) => v.type).toSet();
      expect(types.length, greaterThanOrEqualTo(6));
      expect(
        GameContent.vehicles.any((v) => v.type.name == 'moto'),
        isTrue,
      );
      expect(
        GameContent.vehicles.any((v) => v.type.name == 'truck'),
        isTrue,
      );
      expect(
        GameContent.vehicles.any((v) => v.type.name == 'bus'),
        isTrue,
      );
    });

    test('los identificadores de vehiculo son unicos', () {
      final ids = GameContent.vehicles.map((v) => v.id).toSet();
      expect(ids.length, GameContent.vehicles.length);
    });

    test('los vehiculos grandes ocupan mas ancho que la moto', () {
      final moto = GameContent.vehicles.firstWhere((v) => v.type.name == 'moto');
      final bus = GameContent.vehicles.firstWhere((v) => v.type.name == 'bus');
      expect(bus.widthFactor, greaterThan(moto.widthFactor));
      expect(bus.heightFactor, greaterThan(moto.heightFactor));
    });

    test('todos los vehiculos tienen un asset asignado', () {
      for (final vehicle in GameContent.vehicles) {
        expect(vehicle.assetPath, startsWith('assets/images/cars/'));
      }
    });
  });

  group('Progresion de mundos', () {
    late ProgressService service;
    late ProgressProvider provider;

    setUp(() async {
      service = await ProgressService.create();
      provider = ProgressProvider(service)..load();
    });

    test('solo el primer mundo esta desbloqueado al empezar', () {
      expect(provider.isLevelUnlocked('nivel_01'), isTrue);
      expect(provider.isLevelUnlocked('nivel_02'), isFalse);
      expect(provider.completedLevelCount, 0);
    });

    test('completar un mundo abre el siguiente', () {
      expect(provider.completeLevel('nivel_01'), isTrue);
      expect(provider.isLevelCompleted('nivel_01'), isTrue);
      expect(provider.isLevelUnlocked('nivel_02'), isTrue);
      expect(provider.isLevelUnlocked('nivel_03'), isFalse);
      expect(provider.completedLevelCount, 1);
    });

    test('un mundo bloqueado no se puede completar', () {
      expect(provider.completeLevel('nivel_05'), isFalse);
      expect(provider.completedLevelCount, 0);
    });

    test('completar dos veces el mismo mundo no cuenta doble', () {
      expect(provider.completeLevel('nivel_01'), isTrue);
      expect(provider.completeLevel('nivel_01'), isFalse);
      expect(provider.completedLevelCount, 1);
    });

    test('la seleccion avanza al mundo siguiente', () {
      provider.completeLevel('nivel_01');
      expect(provider.selectedLevel.id, 'nivel_02');
      provider.selectLevel('nivel_01');
      expect(provider.selectedLevel.id, 'nivel_01');
    });

    test('no se puede seleccionar un mundo bloqueado', () {
      provider.selectLevel('nivel_04');
      expect(provider.selectedLevel.id, 'nivel_01');
    });

    test('el progreso de mundos se guarda y se recupera', () async {
      provider.completeLevel('nivel_01');
      await service.flush();

      final reloaded = ProgressProvider(service)..load();
      expect(reloaded.isLevelCompleted('nivel_01'), isTrue);
      expect(reloaded.isLevelUnlocked('nivel_02'), isTrue);
      expect(reloaded.selectedLevel.id, 'nivel_02');
    });

    test('los vehiculos se desbloquean con estrellas', () {
      expect(provider.isVehicleUnlocked('rojo'), isTrue);
      expect(provider.isVehicleUnlocked('moto'), isFalse);
      provider.addStars(20);
      expect(provider.isVehicleUnlocked('moto'), isTrue);
      expect(provider.isVehicleUnlocked('camion'), isTrue);
    });
  });

  test('los ambientes son los trece definidos', () {
    expect(LevelEffect.values.length, 13);
  });
}
