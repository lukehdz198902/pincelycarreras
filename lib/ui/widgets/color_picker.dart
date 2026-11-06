import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../data/models/color_spec.dart';
import '../../shared/context_extensions.dart';
import '../../data/services/audio_service.dart';

/// Selector de color con circulos grandes.
///
/// Los circulos son de 64 dp: los dedos de un nino de 3 anos los aciertan
/// sin problema. Los colores bloqueados se ven en gris con candado.
class ColorPicker extends StatelessWidget {
  /// Crea el selector.
  const ColorPicker({
    super.key,
    required this.colors,
    required this.selectedId,
    required this.isUnlocked,
    required this.onSelected,
  });

  /// Colores a mostrar.
  final List<ColorSpec> colors;

  /// Identificador del color seleccionado.
  final String selectedId;

  /// Indica si un color esta desbloqueado.
  final bool Function(String id) isUnlocked;

  /// Accion al elegir un color.
  final ValueChanged<ColorSpec> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 420 ? 8 : 4;
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
          ),
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final spec = colors[index];
            return _ColorSwatch(
              spec: spec,
              selected: spec.id == selectedId,
              unlocked: isUnlocked(spec.id),
              onTap: () {
                if (!isUnlocked(spec.id)) {
                  audioServiceOf(context)?.playSfx(SfxKind.uiTap);
                  HapticFeedback.lightImpact();
                  return;
                }
                HapticFeedback.lightImpact();
                onSelected(spec);
              },
            );
          },
        );
      },
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.spec,
    required this.selected,
    required this.unlocked,
    required this.onTap,
  });

  final ColorSpec spec;
  final bool selected;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? spec.color : const Color(0xFFD8D2C6);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppPalette.ink : const Color(0x22000000),
            width: selected ? 4 : 2,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: unlocked
              ? null
              : const Center(
                  child: Icon(
                    Icons.lock_rounded,
                    size: 20,
                    color: AppPalette.ink,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Muestra de color activa (muestrario grande).
class ColorSample extends StatelessWidget {
  /// Crea el muestrario.
  const ColorSample({
    super.key,
    required this.color,
    this.size = GameSizes.toolButtonSize,
  });

  /// Color mostrado.
  final Color color;

  /// Lado del muestrario.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppPalette.ink, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            offset: Offset(0, 3),
            blurRadius: 5,
          ),
        ],
      ),
    );
  }
}
