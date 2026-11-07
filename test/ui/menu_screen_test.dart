import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/coloring_screen.dart';
import 'package:pincel_y_carreras/ui/screens/level_select_screen.dart';
import 'package:pincel_y_carreras/ui/screens/menu_screen.dart';
import 'package:pincel_y_carreras/ui/screens/sticker_book_screen.dart';
import 'package:pincel_y_carreras/ui/screens/studio_screen.dart';
import 'package:pincel_y_carreras/ui/widgets/menu_tile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpMenu(WidgetTester tester) async {
    final service = await ProgressService.create();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: const MaterialApp(home: MenuScreen()),
      ),
    );
    await tester.pump();
  }

  group('MenuScreen', () {
    testWidgets('muestra cuatro secciones grandes con icono', (tester) async {
      await pumpMenu(tester);

      final tiles = find.byType(MenuTile);
      expect(tiles, findsNWidgets(4));

      // Ninguna tarjeta puede ser mas pequena de 60 dp (accesibilidad).
      for (final element in tiles.evaluate()) {
        final box = element.renderObject as RenderBox?;
        expect(box, isNotNull);
        expect(box!.size.width, greaterThanOrEqualTo(60));
        expect(box.size.height, greaterThanOrEqualTo(60));
      }
    });

    testWidgets('un toque lleva al estudio de pintura', (tester) async {
      await pumpMenu(tester);
      await tester.tap(find.byType(MenuTile).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(ColoringScreen), findsOneWidget);
    });

    testWidgets('un toque lleva al mapa de niveles', (tester) async {
      await pumpMenu(tester);
      await tester.tap(find.byType(MenuTile).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(LevelSelectScreen), findsOneWidget);
    });


    testWidgets('un toque lleva al taller', (tester) async {
      await pumpMenu(tester);
      await tester.tap(find.byType(MenuTile).at(2));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(StudioScreen), findsOneWidget);
    });

    testWidgets('un toque lleva al libro de pegatinas', (tester) async {
      await pumpMenu(tester);
      await tester.tap(find.byType(MenuTile).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(StickerBookScreen), findsOneWidget);
    });

    testWidgets('el menu no desborda en horizontal', (tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMenu(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el menu no desborda en un movil estrecho', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpMenu(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
