import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/palette.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';

/// Tarjeta grande del menu con icono, etiqueta opcional y respuesta tactil.
///
/// La etiqueta es una ayuda para el adulto: el icono sigue siendo el
/// protagonista y toda la tarjeta es pulsable (minimo 60 dp).
class MenuTile extends StatefulWidget {
  /// Crea una tarjeta del menu.
  const MenuTile({
    super.key,
    required this.assetPath,
    required this.label,
    required this.colors,
    required this.onPressed,
    this.badge,
    this.badgeColor = AppPalette.ink,
    this.compact = false,
  });

  /// Ruta del icono.
  final String assetPath;

  /// Texto corto bajo el icono.
  final String label;

  /// Gradiente de fondo (dos colores).
  final List<Color> colors;

  /// Accion al pulsar.
  final VoidCallback onPressed;

  /// Texto opcional de progreso en la esquina.
  final String? badge;

  /// Color del texto del contador.
  final Color badgeColor;

  /// Version compacta para menus con muchas secciones.
  final bool compact;

  @override
  State<MenuTile> createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scale = Tween<double>(begin: 1, end: 0.94).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _handleTap() {
    audioServiceOf(context)?.playSfx(SfxKind.uiTap);
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.colors.length >= 2
        ? widget.colors
        : [widget.colors.first, widget.colors.first];
    final shadow = gradient.last;

    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _press.forward(),
        onTapUp: (_) => _press.reverse(),
        onTapCancel: () => _press.reverse(),
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) =>
              Transform.scale(scale: _scale.value, child: child),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final side = math.min(
                constraints.maxWidth,
                constraints.maxHeight,
              );
              final minIcon = widget.compact ? 42.0 : 54.0;
              final iconSize = (side * 0.52).clamp(minIcon, 150.0);
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppPalette.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: shadow.withValues(alpha: 0.34),
                      offset: const Offset(0, 9),
                      blurRadius: 18,
                    ),
                  ],
                ),
                padding: EdgeInsets.all(widget.compact ? 6 : 12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              color: AppPalette.white.withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22000000),
                                  offset: Offset(0, 4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(iconSize * 0.14),
                            child: Image.asset(
                              widget.assetPath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                          SizedBox(height: widget.compact ? 4 : 8),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              widget.label,
                              style: TextStyle(
                                color: AppPalette.white,
                                fontSize: widget.compact ? 16 : 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                                shadows: const [
                                  Shadow(
                                    color: Color(0x44000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.badge != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppPalette.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.badge!,
                            style: TextStyle(
                              color: widget.badgeColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
