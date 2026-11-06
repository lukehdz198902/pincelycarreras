import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'ui/screens/splash_screen.dart';

/// Aplicacion "Pincel & Carreras".
class PincelCarrerasApp extends StatelessWidget {
  /// Crea la aplicacion.
  const PincelCarrerasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pincel & Carreras',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const SplashScreen(),
      builder: (context, child) {
        // El juego se adapta a cualquier tamano de pantalla: el nino puede
        // jugar en vertical y en horizontal.
        return MediaQuery.withClampedTextScaling(
          minScaleFactor: 0.9,
          maxScaleFactor: 1.3,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
