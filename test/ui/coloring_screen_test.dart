import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/game/coloring/paint_canvas.dart';
import 'package:pincel_y_carreras/ui/screens/coloring_screen.dart';
import 'package:pincel_y_carreras/ui/widgets/thumbnails.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Deja correr la carga asincrona de la imagen de la lamina.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump(const Duration(milliseconds: 60));
    }
  }

  Future<void> pumpColoring(WidgetTester tester) async {
    final service = await ProgressService.create();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: const MaterialApp(home: ColoringScreen()),
      ),
    );
    await tester.pump();
    await settle(tester);
  }

  /// Cierra la pantalla para cancelar sus temporizadores periodicos.
  Future<void> close(WidgetTester tester) async {
    // El guardado del progreso es debounced (500 ms): hay que dejar que
    // termine para que no queden temporizadores pendientes.
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  /// Busca la miniatura de una lamina por su ruta de asset.
  Finder pageImage(String name) => find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName.contains(name),
      );

  group('ColoringScreen', () {
    testWidgets('carga la lamina inicial y la pinta', (tester) async {
      await pumpColoring(tester);

      expect(find.byType(PaintCanvas), findsOneWidget);
      final canvas = tester.widget<PaintCanvas>(find.byType(PaintCanvas));
      expect(canvas.pageImage.width, 1024);
      expect(canvas.pageImage.height, 768);
      expect(tester.takeException(), isNull);
    });

    testWidgets('al cambiar de lamina se dibuja la nueva y no queda en blanco',
        (tester) async {
      // Pantalla alta: asi se ven todas las miniaturas del panel.
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpColoring(tester);

      final before = tester.widget<PaintCanvas>(find.byType(PaintCanvas));

      // Abrir el panel de laminas y elegir "Frutas".
      await tester.tap(find.byType(PageThumbnail));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(pageImage('pagina_frutas'));
      await tester.pump();
      await settle(tester);

      final after = tester.widget<PaintCanvas>(find.byType(PaintCanvas));

      // Regresion: el pintor se quedaba con la imagen anterior (que ya se
      // habia liberado) y la pantalla quedaba en blanco.
      expect(identical(before.pageImage, after.pageImage), isFalse);
      expect(after.pageImage.width, 1024);
      expect(tester.takeException(), isNull);
      await close(tester);
    });

    testWidgets('el trazo empieza justo donde toca el nino', (tester) async {
      await pumpColoring(tester);

      final canvas = tester.getRect(
        find.descendant(
          of: find.byType(PaintCanvas),
          matching: find.byType(CustomPaint),
        ),
      );
      // Se toca en el 25 % del ancho y el 30 % del alto del lienzo.
      final target = Offset(
        canvas.left + canvas.width * 0.25,
        canvas.top + canvas.height * 0.3,
      );
      await tester.tapAt(target);
      await tester.pump();

      final painting = tester.widget<PaintCanvas>(find.byType(PaintCanvas)).painting;
      expect(painting.strokes, isNotEmpty);

      // Regresion: la conversion de coordenadas usaba el tamaño del
      // LayoutBuilder (toda la pantalla) y el trazo salia en otro sitio.
      final point = painting.strokes.first.points.first;
      expect(point.dx, closeTo(1024 * 0.25, 40));
      expect(point.dy, closeTo(768 * 0.3, 40));
      await close(tester);
    });

    testWidgets('el relleno por color usa la lamina nueva', (tester) async {
      tester.view.physicalSize = const Size(900, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpColoring(tester);

      await tester.tap(find.byType(PageThumbnail));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(pageImage('pagina_frutas'));
      await tester.pump();
      await settle(tester);

      // El raster (relleno por region) debe reconstruirse: si no, el bote
      // rellenaria las regiones de la lamina anterior.
      expect(find.byType(PaintCanvas), findsOneWidget);
      expect(tester.takeException(), isNull);
      await close(tester);
    });
  });
}
