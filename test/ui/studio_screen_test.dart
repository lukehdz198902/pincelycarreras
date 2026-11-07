import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/studio_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProgressProvider> pump(
    WidgetTester tester,
    Widget screen,
  ) async {
    final service = await ProgressService.create();
    final provider = ProgressProvider(service)..load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>.value(value: provider),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    // La carga de los sprites es asincrona real: hay que dejar correr el
    // bucle real para que el juego termine de cargarse.
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 40));
    }
    return provider;
  }

  group('Taller', () {
    testWidgets('muestra calcas, colores y personajes', (tester) async {
      await pump(tester, const StudioScreen());

      expect(find.text('Calca'), findsOneWidget);
      expect(find.text('Color'), findsOneWidget);
      expect(find.text('Pasajero'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('decal_estrella')), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('character_robot')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('elegir calca y personaje se guarda', (tester) async {
      final provider = await pump(tester, const StudioScreen());

      await tester.tap(find.byKey(const ValueKey<String>('decal_llama')));
      await tester.pump();
      expect(provider.progress.selectedDecal, 'llama');

      await tester.tap(find.byKey(const ValueKey<String>('character_conejo')));
      await tester.pump();
      expect(provider.progress.selectedCharacter, 'conejo');

      // El guardado es debounced: se deja terminar el temporizador.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('no desborda en un movil estrecho', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pump(tester, const StudioScreen());
      expect(tester.takeException(), isNull);
    });
  });
}
