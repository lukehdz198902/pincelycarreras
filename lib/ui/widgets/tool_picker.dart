import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../game/coloring/brush.dart';
import 'star_counter.dart';

/// Barra de herramientas del estudio de pintura.
///
/// Tres botones grandes (pincel, bote, borrador) y los grosores de pincel.
class ToolPicker extends StatelessWidget {
  /// Crea la barra de herramientas.
  const ToolPicker({
    super.key,
    required this.brush,
    required this.onToolChanged,
    required this.onWidthChanged,
  });

  /// Pincel activo.
  final Brush brush;

  /// Accion al cambiar de herramienta.
  final ValueChanged<ToolKind> onToolChanged;

  /// Accion al cambiar de grosor.
  final ValueChanged<int> onWidthChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, -3),
            blurRadius: 8,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tools = <Widget>[
            _ToolButton(
              assetPath: AssetPaths.iconBrush,
              selected: brush.kind == ToolKind.brush,
              onTap: () => onToolChanged(ToolKind.brush),
            ),
            _ToolButton(
              assetPath: AssetPaths.iconBucket,
              selected: brush.kind == ToolKind.bucket,
              onTap: () => onToolChanged(ToolKind.bucket),
            ),
            _ToolButton(
              assetPath: AssetPaths.iconEraser,
              selected: brush.kind == ToolKind.eraser,
              onTap: () => onToolChanged(ToolKind.eraser),
            ),
          ];

          final dots = <Widget>[
            for (var i = 0; i < Brush.brushWidths.length; i++)
              BrushSizeDot(
                width: Brush.brushWidths[i],
                selected: brush.widthIndex == i,
                onTap: () => onWidthChanged(i),
              ),
          ];

          // En moviles estrechos los grosores de pincel pasan a una segunda
          // fila: en una sola no caben y la barra se desbordaria.
          final oneRow = dots.isEmpty ||
              constraints.maxWidth >= _toolsWidth + _dotsWidth + 8;

          if (oneRow) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [...tools, if (dots.isNotEmpty) ...dots],
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: tools,
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dots,
              ),
            ],
          );
        },
      ),
    );
  }

  /// Ancho que ocupan los tres botones de herramienta.
  static const double _toolsWidth = GameSizes.toolButtonSize * 3;

  /// Ancho que ocupan los tres grosores de pincel.
  static const double _dotsWidth = GameSizes.smallButtonSize * 3;
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.assetPath,
    required this.selected,
    required this.onTap,
  });

  final String assetPath;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: GameSizes.toolButtonSize,
        height: GameSizes.toolButtonSize,
        decoration: BoxDecoration(
          color: selected ? AppPalette.yellow : const Color(0xFFF3EDE0),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? AppPalette.orange : const Color(0x22000000),
            width: 3,
          ),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          assetPath,
          width: GameSizes.toolButtonSize * 0.62,
          height: GameSizes.toolButtonSize * 0.62,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}

/// Boton compacto que abre un panel (colores, laminas, coches...).
class PanelButton extends StatelessWidget {
  /// Crea el boton de panel.
  const PanelButton({
    super.key,
    required this.assetPath,
    required this.onTap,
    this.size = GameSizes.toolButtonSize,
    this.badge,
  });

  /// Ruta del icono.
  final String assetPath;

  /// Accion al pulsar.
  final VoidCallback onTap;

  /// Lado del boton.
  final double size;

  /// Texto opcional en la esquina (por ejemplo, el numero de estrellas).
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(size * 0.3),
          border: Border.all(color: const Color(0x22000000), width: 2),
        ),
        alignment: Alignment.center,
        child: Image.asset(
          assetPath,
          width: size * 0.62,
          height: size * 0.62,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}
