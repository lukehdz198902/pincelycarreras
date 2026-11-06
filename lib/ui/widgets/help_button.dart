import 'package:flutter/material.dart';

import '../../core/constants/palette.dart';

/// Boton de ayuda: explica al nino (y a su familia) como se usa la seccion.
///
/// Es el boton **?** que aparece en las pantallas donde puede haber dudas
/// ("¿esto que es?", "¿para que sirve?").
class HelpButton extends StatelessWidget {
  /// Crea el boton de ayuda.
  const HelpButton({
    super.key,
    required this.title,
    required this.tips,
    this.size = 48,
  });

  /// Titulo de la ventana de ayuda.
  final String title;

  /// Consejos (uno por linea).
  final List<String> tips;

  /// Tamano del boton.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Como se juega',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => showHelp(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppPalette.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppPalette.violet, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.help_outline_rounded,
            color: AppPalette.violet,
            size: size * 0.55,
          ),
        ),
      ),
    );
  }

  /// Muestra la ventana de ayuda.
  void showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppPalette.cream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.lightbulb_rounded,
                    color: AppPalette.orange,
                    size: 30,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: AppPalette.ink,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final tip in tips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppPalette.yellow,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tip,
                          style: const TextStyle(
                            color: AppPalette.ink,
                            fontSize: 16,
                            height: 1.3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    '¡Entendido!',
                    style: TextStyle(
                      color: AppPalette.violet,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
