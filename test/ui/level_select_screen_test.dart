import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/garage_screen.dart';
import 'package:pincel_y_carreras/ui/screens/level_select_screen.dart';
import 'package:pincel_y_carreras/ui/screens/racing_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProgressProvider> pumpMap(WidgetTester tester) async {
    final service = await ProgressService.create();
    final provider = ProgressProvider(service)..load();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: LevelSelectScreen()),
      ),
    );
    await tester.pump();
    return provider;
  }

  group('Mapa de niveles', () {
    testWidgets('muestra los doce mundos', (tester) async {
      await pumpMap(tester);

      for (var i = 1; i <= 12; i++) {
        expect(find.text('$i'), findsOneWidget);
      }
      expect(tester.takeException(), isNull);
    });

    testWidgets('solo el primer mundo esta disponible al empezar',
        (tester) async {
      await pumpMap(tester);

      // Los once bloqueados muestran el candado.
      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(11));
    });

    testWidgets('completar un mundo abre el siguiente', (tester) async {
      final provider = await pumpMap(tester);

      provider.completeLevel('nivel_01');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.lock_rounded), findsNWidgets(10));
      // El guardado es debounced: se deja que el temporizador termine.
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('un nivel disponible abre las carreras', (tester) async {
      await pumpMap(tester);

      await tester.tap(find.byKey(const ValueKey<String>('level_nivel_01')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(RacingScreen), findsOneWidget);
    });

    testWidgets('un nivel bloqueado no abre las carreras', (tester) async {
      await pumpMap(tester);

      await tester.tap(find.byKey(const ValueKey<String>('level_nivel_05')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(RacingScreen), findsNothing);
      expect(find.byType(LevelSelectScreen), findsOneWidget);
    });

    testWidgets('el boton de vehiculo abre el garaje', (tester) async {
      await pumpMap(tester);

      await tester.tap(find.byKey(const ValueKey<String>('garage_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GarageScreen), findsOneWidget);
    });

    testWidgets('no desborda en un movil estrecho', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMap(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no desborda en horizontal', (tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMap(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
