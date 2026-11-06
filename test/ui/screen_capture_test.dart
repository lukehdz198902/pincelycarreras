import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/coloring_screen.dart';
import 'package:pincel_y_carreras/ui/screens/climb_screen.dart';
import 'package:pincel_y_carreras/ui/screens/garage_screen.dart';
import 'package:pincel_y_carreras/ui/screens/level_select_screen.dart';
import 'package:pincel_y_carreras/ui/screens/studio_screen.dart';
import 'package:pincel_y_carreras/ui/screens/menu_screen.dart';
import 'package:pincel_y_carreras/ui/screens/racing_screen.dart';
import 'package:pincel_y_carreras/ui/screens/splash_screen.dart';
import 'package:pincel_y_carreras/ui/screens/sticker_book_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Captura las cuatro pantallas del juego en `build/screenshots/`.
///
/// No compara contra goldens (eso seria fragil entre maquinas): solo
/// comprueba que **cada pantalla se dibuja sin errores** y deja una imagen
/// PNG para poder revisar el resultado visual a simple vista.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen,
  ) async {
    final service = await ProgressService.create();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: const ValueKey<String>('capture'),
            child: screen,
          ),
        ),
      ),
    );
    // El juego corre en bucle: hay que advanced frames a mano.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  /// Igual que [pumpScreen] pero con el tamano de un movil estrecho.
  Future<void> pumpNarrow(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await pumpScreen(tester, screen);
  }

  Future<void> capture(WidgetTester tester, String name) async {    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey<String>('capture')),
    );

    // `toImage` necesita asincronia real: dentro de la zona simulada de
    // los tests la promesa nunca se completa.
    await tester.runAsync(() async {
      final image = await boundary.toImage(pixelRatio: 1);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      final dir = Directory('build/screenshots');
      dir.createSync(recursive: true);
      File('${dir.path}/$name.png').writeAsBytesSync(
        data!.buffer.asUint8List(),
      );
    });
  }

  group('Captura de pantallas', () {
    testWidgets('la pantalla de inicio se dibuja sin errores',
        (tester) async {
      await pumpScreen(tester, const SplashScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'inicio');
    });

    testWidgets('el menu se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const MenuScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'menu');
    });

    testWidgets('el mapa de niveles se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const LevelSelectScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'niveles');
    });

    testWidgets('el garaje se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const GarageScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'garaje');
    });

    testWidgets('el taller se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const StudioScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'taller');
    });

    testWidgets('el modo subidas se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const ClimbScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'subidas');
    });

    testWidgets('el estudio de pintura se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const ColoringScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'pintura');
    });

    testWidgets('la pantalla de carreras se dibuja sin errores',
        (tester) async {
      await pumpScreen(tester, const RacingScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'carreras');
    });

    testWidgets('el libro de pegatinas se dibuja sin errores', (tester) async {
      await pumpScreen(tester, const StickerBookScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'pegatinas');
    });
  });

  group('Captura en movil estrecho (320 x 640)', () {
    testWidgets('el menu se dibuja sin errores', (tester) async {
      await pumpNarrow(tester, const MenuScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'menu-320');
    });

    testWidgets('el estudio de pintura se dibuja sin errores', (tester) async {
      await pumpNarrow(tester, const ColoringScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'pintura-320');
    });

    testWidgets('la pantalla de carreras se dibuja sin errores',
        (tester) async {
      await pumpNarrow(tester, const RacingScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'carreras-320');
    });

    testWidgets('el libro de pegatinas se dibuja sin errores', (tester) async {
      await pumpNarrow(tester, const StickerBookScreen());
      expect(tester.takeException(), isNull);
      await capture(tester, 'pegatinas-320');
    });
  });
}
