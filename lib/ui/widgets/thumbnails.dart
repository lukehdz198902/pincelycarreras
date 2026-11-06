/// Miniaturas de los recursos seleccionables.
///
/// Viven en un unico sitio porque las usan varias pantallas: el estudio de
/// pintura (lamina), las carreras (coche y pista) y el menu.
library;

import 'package:flutter/material.dart';

import '../../core/constants/palette.dart';

/// Muestra el icono de la lamina activa.
class PageThumbnail extends StatelessWidget {
  /// Crea la miniatura.
  const PageThumbnail({super.key, required this.assetPath, this.size = 56});

  /// Ruta de la imagen.
  final String assetPath;

  /// Lado de la miniatura.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0x33000000), width: 2),
      ),
      padding: EdgeInsets.all(size * 0.06),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Miniatura de coche.
class CarThumbnail extends StatelessWidget {
  /// Crea la miniatura.
  const CarThumbnail({
    super.key,
    required this.assetPath,
    this.size = 56,
    this.locked = false,
  });

  /// Ruta de la imagen.
  final String assetPath;

  /// Lado de la miniatura.
  final double size;

  /// Si el recurso esta bloqueado.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: locked ? const Color(0xFFE0D8C8) : AppPalette.white,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0x33000000), width: 2),
      ),
      padding: EdgeInsets.all(size * 0.06),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              assetPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          ),
          if (locked)
            const Center(
              child: Icon(
                Icons.lock_rounded,
                color: AppPalette.ink,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
