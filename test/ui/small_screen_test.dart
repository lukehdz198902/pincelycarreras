import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/coloring_screen.dart';
import 'package:pincel_y_carreras/ui/screens/garage_screen.dart';
import 'package:pincel_y_carreras/ui/screens/level_select_screen.dart';
import 'package:pincel_y_carreras/ui/screens/studio_screen.dart';
import 'package:pincel_y_carreras/ui/screens/menu_screen.dart';
import 'package:pincel_y_carreras/ui/screens/racing_screen.dart';
import 'package:pincel_y_carreras/ui/screens/splash_screen.dart';
import 'package:pincel_y_carreras/ui/screens/sticker_book_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Comprueba que las pantallas no se desbordan en moviles pequenos.
///
/// Un movil de 320 dp de ancho es el caso limite habitual, asi que se
/// prueban las cuatro pantallas en ese tamano y en vertical.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSmall(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final service = await ProgressService.create();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: MaterialApp(home: screen),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  group('Pantallas en un movil pequeno (320 x 640)', () {
    testWidgets('la pantalla de inicio no se desborda', (tester) async {
      await pumpSmall(tester, const SplashScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('el menu no se desborda', (tester) async {
      await pumpSmall(tester, const MenuScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('el mapa de niveles no se desborda', (tester) async {
      await pumpSmall(tester, const LevelSelectScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('el garaje no se desborda', (tester) async {
      await pumpSmall(tester, const GarageScreen());
      expect(tester.takeException(), isNull);
    });


    testWidgets('el taller no se desborda', (tester) async {
      await pumpSmall(tester, const StudioScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('el estudio de pintura no se desborda', (tester) async {
      await pumpSmall(tester, const ColoringScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('la pantalla de carreras no se desborda', (tester) async {
      await pumpSmall(tester, const RacingScreen());
      expect(tester.takeException(), isNull);
    });

    testWidgets('el libro de pegatinas no se desborda', (tester) async {
      await pumpSmall(tester, const StickerBookScreen());
      expect(tester.takeException(), isNull);
    });
  });
}
