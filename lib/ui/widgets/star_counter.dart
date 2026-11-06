import 'package:flutter/material.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';

/// Contador de estrellas con animacion al cambiar.
///
/// Es la recompensa visible del nino: siempre esta presente, nunca penaliza.
class StarCounter extends StatefulWidget {
  /// Crea el contador.
  const StarCounter({
    super.key,
    required this.stars,
    this.size = 56,
    this.showNumber = true,
  });

  /// Numero de estrellas.
  final int stars;

  /// Lado del icono.
  final double size;

  /// Si se muestra el numero al lado.
  final bool showNumber;

  @override
  State<StarCounter> createState() => _StarCounterState();
}

class _StarCounterState extends State<StarCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = Tween<double>(begin: 1.35, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(covariant StarCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stars != widget.stars) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(scale: _scale.value, child: child);
      },
      child: Container(
        height: widget.size,
        padding: EdgeInsets.symmetric(horizontal: widget.showNumber ? 10 : 6),
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(widget.size),
          border: Border.all(color: AppPalette.yellow, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              offset: Offset(0, 3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.iconStar,
              width: widget.size * 0.72,
              height: widget.size * 0.72,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
            if (widget.showNumber) ...[
              const SizedBox(width: 4),
              Text(
                '${widget.stars}',
                style: TextStyle(
                  fontSize: widget.size * 0.5,
                  fontWeight: FontWeight.w900,
                  color: AppPalette.ink,
                ),
              ),
              const SizedBox(width: 6),
            ],
          ],
        ),
      ),
    );
  }
}

/// Etiqueta de tamano de pincel (punto, medio, grande).
class BrushSizeDot extends StatelessWidget {
  /// Crea el punto.
  const BrushSizeDot({
    super.key,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  /// Grosor del pincel.
  final double width;

  /// Si esta seleccionado.
  final bool selected;

  /// Accion al pulsar.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final diameter = (width * 0.55).clamp(10.0, 30.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: GameSizes.smallButtonSize,
        height: GameSizes.smallButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppPalette.yellow : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: selected ? AppPalette.ink : AppPalette.brown,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
