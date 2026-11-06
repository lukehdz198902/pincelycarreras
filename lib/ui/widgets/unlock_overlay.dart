import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/palette.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';

/// Aviso visual cuando el nino desbloquea una recompensa.
///
/// Es una tarjeta grande con el icono de la recompensa: sin texto que
/// leer, solo una imagen y un sonido positivo.
class UnlockOverlay extends StatefulWidget {
  /// Crea el aviso.
  const UnlockOverlay({super.key});

  @override
  State<UnlockOverlay> createState() => _UnlockOverlayState();
}

class _UnlockOverlayState extends State<UnlockOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  UnlockEvent? _event;
  int _lastStars = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _lastStars = context.read<ProgressProvider>().totalStars;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showNext() {
    if (!mounted) {
      return;
    }
    final provider = context.read<ProgressProvider>();
    final events = provider.takePendingUnlocks();
    if (events.isEmpty) {
      return;
    }
    audioServiceOf(context)?.playSfx(SfxKind.unlock);
    HapticFeedback.mediumImpact();
    setState(() => _event = events.first);
    _controller.forward(from: 0);
    Future<void>.delayed(const Duration(milliseconds: 1700), () {
      if (!mounted || _event == null) {
        return;
      }
      setState(() => _event = null);
      _showNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    final stars = context.watch<ProgressProvider>().totalStars;
    if (stars != _lastStars) {
      _lastStars = stars;
      WidgetsBinding.instance.addPostFrameCallback((_) => _showNext());
    }

    final event = _event;
    if (event == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = Curves.easeOutBack.transform(_controller.value);
          return Opacity(
            opacity: _controller.value.clamp(0.0, 1.0),
            child: Center(
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: AppPalette.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.yellow, width: 8),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: event.assetPath.isEmpty
              ? const Icon(
                  Icons.star_rounded,
                  size: 120,
                  color: AppPalette.yellow,
                )
              : Padding(
                  padding: const EdgeInsets.all(28),
                  child: Image.asset(
                    event.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) => const Icon(
                      Icons.star_rounded,
                      size: 120,
                      color: AppPalette.yellow,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
