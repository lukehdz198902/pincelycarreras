import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/models/level_catalog.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/audio_service.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/game/racing/racing_game.dart';
import 'package:pincel_y_carreras/ui/screens/garage_screen.dart';
import 'package:pincel_y_carreras/ui/screens/racing_screen.dart';
import 'package:pincel_y_carreras/ui/widgets/big_button.dart';
import 'package:pincel_y_carreras/ui/widgets/star_counter.dart';
import 'package:pincel_y_carreras/ui/widgets/thumbnails.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio falso: cuenta las llamadas para comprobar el ciclo de vida.
class _FakeAudioService extends AudioService {
  int stopCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  final List<BgmTrack> played = [];

  @override
  Future<void> playBgm(BgmTrack track) async => played.add(track);

  @override
  Future<void> stopBgm() async => stopCalls++;

  @override
  Future<void> pauseBgm() async => pauseCalls++;

  @override
  Future<void> resumeBgm() async => resumeCalls++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<_FakeAudioService> pumpRacing(
    WidgetTester tester, {
    String? levelId,
  }) async {
    final service = await ProgressService.create();
    final audio = _FakeAudioService();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          Provider<AudioService>.value(value: audio),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: MaterialApp(home: RacingScreen(levelId: levelId)),
      ),
    );
    // Varios frames: el juego carga sus sprites de forma asincrona.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return audio;
  }

  /// Espera a que el juego termine de cargar sus sprites.
  ///
  /// La carga de assets es asincrona real: dentro de la zona simulada de
  /// los tests hay que dejar correr el bucle real con `runAsync`.
  Future<void> waitForGame(
    WidgetTester tester,
    RacingGame game,
  ) async {
    for (var i = 0; i < 30; i++) {
      if (game.isReady) {
        return;
      }
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 40));
    }
  }

  group('RacingScreen', () {
    testWidgets('arranca directamente en juego, sin menus intermedios',
        (tester) async {
      await pumpRacing(tester);

      expect(find.byType(GameWidget<RacingGame>), findsOneWidget);
      expect(find.byType(RacingScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el juego ocupa la pantalla completa', (tester) async {
      await pumpRacing(tester);

      // Regresion: un hijo NO posicionado en el Stack (la barra superior)
      // hacia que el Stack midiese 80 px en vez de la pantalla completa.
      final rect = tester.getRect(find.byType(GameWidget<RacingGame>));
      expect(rect.width, 800);
      expect(rect.height, 600);
    });

    testWidgets('el origen del mundo es la esquina superior izquierda',
        (tester) async {
      await pumpRacing(tester);

      // Regresion: Flame ancla el viewfinder en el centro del viewport, lo
      // que desplazaba la pista media pantalla y dejaba el coche fuera.
      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      expect(game.camera.viewfinder.anchor, Anchor.topLeft);

      final worldOrigin = game.camera.viewfinder.globalToLocal(Vector2.zero());
      expect(worldOrigin.x, closeTo(0, 0.5));
      expect(worldOrigin.y, closeTo(0, 0.5));
    });

    testWidgets('la barra superior respeta el area tactil minima',
        (tester) async {
      await pumpRacing(tester);

      // Boton de atras y boton de pausa.
      final buttons = find.byType(AppIconButton);
      expect(buttons, findsNWidgets(2));

      for (final element in buttons.evaluate()) {
        final box = element.renderObject as RenderBox;
        expect(box.size.width, greaterThanOrEqualTo(60));
        expect(box.size.height, greaterThanOrEqualTo(60));
      }

      // Las miniaturas de coche tambien son pulsables.
      final thumbnail = tester.getSize(find.byType(CarThumbnail));
      expect(thumbnail.width, greaterThanOrEqualTo(60));
      expect(thumbnail.height, greaterThanOrEqualTo(60));
    });

    testWidgets('muestra controles visibles de izquierda y derecha',
        (tester) async {
      await pumpRacing(tester);

      // El nino debe ver donde tocar: dos flechas grandes en pantalla.
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      final left = find.byKey(const ValueKey<String>('steer_left'));
      final right = find.byKey(const ValueKey<String>('steer_right'));
      expect(left, findsOneWidget);
      expect(right, findsOneWidget);

      final size = tester.getSize(right);
      expect(size.width, greaterThanOrEqualTo(60));
      expect(size.height, greaterThanOrEqualTo(60));
    });

    testWidgets('pulsar la flecha izquierda mueve el coche de carril',
        (tester) async {
      await pumpRacing(tester);

      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      await waitForGame(tester, game);
      expect(game.isReady, isTrue);

      final before = game.carLane;

      await tester.tap(find.byKey(const ValueKey<String>('steer_left')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(game.carLane, isNot(before));
    });

    testWidgets('el boton de pausa muestra y oculta la pausa', (tester) async {
      await pumpRacing(tester);

      expect(find.text('Seguir'), findsNothing);

      await tester.tap(find.byType(AppIconButton).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Seguir'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Seguir'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Seguir'), findsNothing);
    });

    testWidgets('el boton de vehiculo abre el garaje', (tester) async {
      await pumpRacing(tester);

      // El boton de vehiculo abre el garaje con los 10 vehiculos.
      await tester.tap(find.byType(CarThumbnail));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(GarageScreen), findsOneWidget);
      expect(find.text('Furioso'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrastrando el dedo el coche se mueve por la carretera',
        (tester) async {
      await pumpRacing(tester);

      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      await waitForGame(tester, game);
      final startX = game.carX;

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(GameWidget<RacingGame>)),
      );
      await tester.pump();
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await tester.pump();

      expect(game.carX, greaterThan(startX));
    });

    testWidgets('el contador de estrellas permanece visible', (tester) async {
      await pumpRacing(tester);

      expect(find.byType(StarCounter), findsOneWidget);
    });

    testWidgets('usa la pista y el ambiente del mundo elegido',
        (tester) async {
      await pumpRacing(tester, levelId: 'nivel_04');

      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      expect(game.trackAssetPath, contains('nieve'));
      expect(game.effect, LevelCatalog.byId('nivel_04')!.effect);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('la carrera tiene final: la meta cierra el recorrido',
        (tester) async {
      await pumpRacing(tester);

      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      expect(game.isFinished, isFalse);
      expect(game.laps, LevelCatalog.first.laps);
      expect(game.targetSeconds, greaterThanOrEqualTo(60));
    });

    testWidgets('al salir se detienen el juego y la musica', (tester) async {
      final service = await ProgressService.create();
      final audio = _FakeAudioService();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<ProgressService>.value(value: service),
            Provider<AudioService>.value(value: audio),
            ChangeNotifierProvider<ProgressProvider>(
              create: (_) => ProgressProvider(service)..load(),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: BigButton(
                    assetPath: 'assets/images/ui/icono_coche.png',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const RacingScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(BigButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      final game = tester
          .widget<GameWidget<RacingGame>>(find.byType(GameWidget<RacingGame>))
          .game!;
      expect(audio.played, contains(BgmTrack.racing));

      // Salir hacia atras.
      await tester.tap(find.byType(AppIconButton).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Regresion: el juego seguia corriendo en segundo plano y la musica
      // no se callaba nunca.
      expect(game.isHalted, isTrue);
      expect(audio.stopCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('la pantalla no desborda en horizontal', (tester) async {
      tester.view.physicalSize = const Size(1200, 600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpRacing(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('la pantalla no desborda en un movil estrecho',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpRacing(tester);
      expect(tester.takeException(), isNull);
    });
  });
}
