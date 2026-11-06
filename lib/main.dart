import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/providers/progress_provider.dart';
import 'data/services/audio_service.dart';
import 'data/services/progress_service.dart';

/// Punto de entrada de "Pincel & Carreras".
///
/// Arranque sin esperas: se cargan las preferencias locales y se muestra el
/// menu. Ni el audio ni el bloqueo de orientacion se esperan: ambos pueden
/// no responder nunca (criterio A9 del GDD) y el juego debe arrancar siempre.
/// El juego es **100 % offline**.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // El bloqueo de orientacion solo tiene sentido en movil. En web el motor
  // lanza una excepcion al no existir la API de bloqueo de pantalla y la
  // promesa nunca se resuelve, lo que dejaria la app sin arrancar.
  if (!kIsWeb) {
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]).catchError((Object _) {}),
    );
  }

  final progressService = await ProgressService.create();
  final audioService = AudioService();

  // El audio se prepara en segundo plano: en web el `AudioContext` queda
  // suspendido hasta el primer gesto del usuario y su inicializacion puede no
  // resolverse nunca. El juego es jugable en silencio, asi que el audio es
  // un plus, nunca un requisito.
  unawaited(audioService.initialize());

  runApp(
    MultiProvider(
      providers: [
        Provider<ProgressService>.value(value: progressService),
        Provider<AudioService>.value(value: audioService),
        ChangeNotifierProvider<ProgressProvider>(
          create: (_) => ProgressProvider(progressService)..load(),
        ),
      ],
      child: const PincelCarrerasApp(),
    ),
  );
}
