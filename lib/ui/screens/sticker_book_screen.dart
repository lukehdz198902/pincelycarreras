import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/sticker.dart';
import '../../data/providers/progress_provider.dart';
import '../widgets/big_button.dart';
import '../widgets/help_button.dart';
import '../widgets/star_counter.dart';

/// Libro de pegatinas: las recompensas que el nino ha desbloqueado.
///
/// Las pegatinas bloqueadas se ven en gris con un candado: el nino ve
/// lo que le falta, sin frustracion.
class StickerBookScreen extends StatelessWidget {
  /// Crea el libro de pegatinas.
  const StickerBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  AppIconButton(
                    assetPath: AssetPaths.iconBack,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Mis trofeos',
                        style: TextStyle(
                          color: AppPalette.ink,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StarCounter(stars: provider.totalStars),
                  const SizedBox(width: 8),
                  HelpButton(
                    size: 48,
                    title: '¿Qué son las pegatinas?',
                    tips: const [
                      'Son tus trofeos: se desbloquean jugando y '
                          'recuerdan todo lo que has conseguido.',
                      'Cada pegatina dice cuántas estrellas necesitas.',
                      'Cuantas más estrellas recojas, más trofeos, '
                          'colores y vehículos tendrás.',
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.95,
                ),
                itemCount: GameContent.stickers.length,
                itemBuilder: (context, index) {
                  final sticker = GameContent.stickers[index];
                  final unlocked = provider.isStickerUnlocked(sticker.id);
                  return _StickerTile(
                    sticker: sticker,
                    unlocked: unlocked,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.sticker, required this.unlocked});

  final StickerSpec sticker;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: unlocked ? AppPalette.white : const Color(0xFFE4DCCB),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: unlocked ? AppPalette.yellow : const Color(0x22000000),
          width: unlocked ? 4 : 2,
        ),
        boxShadow: unlocked
            ? const [
                BoxShadow(
                  color: Color(0x22000000),
                  offset: Offset(0, 4),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    sticker.assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) =>
                        const SizedBox.shrink(),
                  ),
                ),
                if (!unlocked)
                  const Center(
                    child: Icon(
                      Icons.lock_rounded,
                      size: 46,
                      color: AppPalette.ink,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sticker.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            unlocked ? '¡Conseguida!' : 'Con ${sticker.unlockStars} ★',
            style: TextStyle(
              color: unlocked ? AppPalette.green : AppPalette.brown,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
