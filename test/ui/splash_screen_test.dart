import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/providers/progress_provider.dart';
import 'package:pincel_y_carreras/data/services/progress_service.dart';
import 'package:pincel_y_carreras/ui/screens/menu_screen.dart';
import 'package:pincel_y_carreras/ui/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSplash(WidgetTester tester) async {
    final service = await ProgressService.create();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<ProgressService>.value(value: service),
          ChangeNotifierProvider<ProgressProvider>(
            create: (_) => ProgressProvider(service)..load(),
          ),
        ],
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump();
  }

  group('SplashScreen', () {
    testWidgets('muestra el titulo del juego', (tester) async {
      await pumpSplash(tester);

      expect(find.text('Pincel'), findsOneWidget);
      expect(find.text('& Carreras'), findsOneWidget);
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('el juego arranca solo tras la animacion', (tester) async {
      await pumpSplash(tester);

      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MenuScreen), findsOneWidget);
    });

    testWidgets('un toque salta la animacion', (tester) async {
      await pumpSplash(tester);

      await tester.tap(find.byType(SplashScreen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(MenuScreen), findsOneWidget);
    });

    testWidgets('no desborda en un movil estrecho', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpSplash(tester);
      await tester.pump(const Duration(milliseconds: 800));
      expect(tester.takeException(), isNull);
    });
  });
}
