import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/game_content.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/garage_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProgressProvider> pumpGarage(WidgetTester tester) async {
    final service = await ProgressService.create();
    final provider = ProgressProvider(service)..load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: GarageScreen()),
      ),
    );
    await tester.pump();
    return provider;
  }

  group('Garaje', () {
    testWidgets('muestra todos los vehiculos', (tester) async {
      // Pantalla alta: asi el grid construye las diez tarjetas.
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpGarage(tester);

      for (final vehicle in GameContent.vehicles) {
        expect(find.text(vehicle.name), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('los vehiculos bloqueados muestran el candado', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpGarage(tester);

      final locked = GameContent.vehicles.where((v) => !v.isFree).length;
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(locked));
    });

    testWidgets('se puede elegir un vehiculo desbloqueado', (tester) async {
      final provider = await pumpGarage(tester);

      await tester.tap(find.text('Rayo'));
      await tester.pump();

      expect(provider.progress.selectedVehicle, 'azul');
      // El guardado es debounced: se deja terminar el temporizador.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('un vehiculo bloqueado no se puede elegir', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final provider = await pumpGarage(tester);

      await tester.tap(find.text('Bus escolar'));
      await tester.pump();

      expect(provider.progress.selectedVehicle, 'rojo');
    });

    testWidgets('con estrellas se desbloquean mas vehiculos', (tester) async {
      tester.view.physicalSize = const Size(900, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final provider = await pumpGarage(tester);

      provider.addStars(45);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.byIcon(Icons.lock_rounded), findsNothing);

      await tester.tap(find.text('Bus escolar'));
      await tester.pump();

      expect(provider.progress.selectedVehicle, 'bus');
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('no desborda en un movil estrecho', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpGarage(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
