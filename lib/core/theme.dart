import 'package:flutter/material.dart';

import 'constants/palette.dart';

/// Tema visual de la aplicacion.
///
/// Estilo "cartoon infantil": superficies blancas con sombras de color,
/// bordes redondeados y tipografia grande.
class AppTheme {
  const AppTheme._();

  /// Radio de borde de las superficies.
  static const double radius = 28;

  /// Construye el tema claro de la app.
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.blue,
        primary: AppPalette.blue,
        surface: AppPalette.cream,
      ),
      scaffoldBackgroundColor: AppPalette.cream,
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppPalette.ink,
        displayColor: AppPalette.ink,
      ),
      splashFactory: InkRipple.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 88),
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppPalette.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radius)),
        ),
      ),
    );
  }
}
