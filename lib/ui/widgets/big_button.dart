import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';

/// Boton grande con icono, rebote al pulsarse, sonido y vibracion.
///
/// Es el unico control que usan los ninos: por eso el area tactil es
/// generosa (minimo 60 dp) y la respuesta es inmediata.
class BigButton extends StatefulWidget {
  /// Crea un boton grande.
  const BigButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.size = GameSizes.menuButtonSize,
    this.backgroundColor = AppPalette.white,
    this.borderColor,
    this.iconScale = 0.72,
    this.enabled = true,
  });

  /// Ruta del icono.
  final String assetPath;

  /// Accion al pulsar.
  final VoidCallback onPressed;

  /// Lado del boton.
  final double size;

  /// Color de fondo.
  final Color backgroundColor;

  /// Color del borde (por defecto, una version oscura del fondo).
  final Color? borderColor;

  /// Proporcion del icono respecto al boton.
  final double iconScale;

  /// Si el boton responde.
  final bool enabled;

  @override
  State<BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton>
    with TickerProviderStateMixin {
  late final AnimationController _press;
  late final AnimationController _pop;
  late final Animation<double> _pressScale;
  late final Animation<double> _popScale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _pressScale = Tween<double>(begin: 1, end: 0.9).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
    _popScale = Tween<double>(begin: 1.08, end: 1).animate(
      CurvedAnimation(parent: _pop, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    _pop.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) {
      return;
    }
    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
    HapticFeedback.lightImpact();
    _pop.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final border = widget.borderColor ?? _darken(widget.backgroundColor);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => _press.forward() : null,
        onTapUp: widget.enabled ? (_) => _press.reverse() : null,
        onTapCancel: widget.enabled ? () => _press.reverse() : null,
        onTap: widget.enabled ? _handleTap : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_press, _pop]),
          builder: (context, child) {
            final scale = _pressScale.value * _popScale.value;
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.enabled
                  ? widget.backgroundColor
                  : widget.backgroundColor.withValues(alpha: 0.5),
              shape: BoxShape.circle,
              border: Border.all(color: border, width: widget.size * 0.045),
              boxShadow: [
                BoxShadow(
                  color: border.withValues(alpha: 0.28),
                  offset: Offset(0, widget.size * 0.07),
                  blurRadius: widget.size * 0.12,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Image.asset(
              widget.assetPath,
              width: widget.size * widget.iconScale,
              height: widget.size * widget.iconScale,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }

  static Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness * 0.82).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Boton circular compacto para las barras superiores (atras, pausa...).
class AppIconButton extends StatelessWidget {
  /// Crea un boton de icono.
  const AppIconButton({
    super.key,
    required this.assetPath,
    required this.onPressed,
    this.size = GameSizes.smallButtonSize,
    this.backgroundColor = AppPalette.white,
  });

  /// Ruta del icono.
  final String assetPath;

  /// Accion al pulsar.
  final VoidCallback onPressed;

  /// Lado del boton.
  final double size;

  /// Color de fondo.
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final audio = audioServiceOf(context);
    return Semantics(
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          audio?.playSfx(SfxKind.uiTap);
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0x33000000),
              width: size * 0.04,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
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
      ),
    );
  }
}
