import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';
import 'coloring_screen.dart';
import 'level_select_screen.dart';
import 'sticker_book_screen.dart';
import 'studio_screen.dart';
import '../widgets/help_button.dart';
import '../widgets/menu_tile.dart';
import '../widgets/star_counter.dart';
import '../widgets/unlock_overlay.dart';

/// Pantalla de inicio.
///
/// Tres tarjetas grandes con icono: pintar, carreras y pegatinas. Detras
/// hay un fondo animado suave y un boton de sonido siempre accesible.
class MenuScreen extends StatefulWidget {
  /// Crea el menu.
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Stack(
        children: [
          _MenuBackground(animation: _float),
          SafeArea(
            child: Column(
              children: [
                _Header(progress: progress),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide =
                          constraints.maxWidth > constraints.maxHeight;
                      final tiles = [
                        MenuTile(
                          compact: !isWide,
                          assetPath: AssetPaths.iconBrush,
                          label: 'Pintar',
                          colors: const [
                            AppPalette.yellow,
                            AppPalette.orange,
                          ],
                          badge: _pageBadge(progress),
                          badgeColor: AppPalette.orange,
                          onPressed: () => _open(
                            context,
                            const ColoringScreen(),
                          ),
                        ),
                        MenuTile(
                          compact: !isWide,
                          assetPath: AssetPaths.iconCar,
                          label: 'Carreras',
                          colors: const [
                            AppPalette.red,
                            AppPalette.pink,
                          ],
                          badge: '${progress.completedLevelCount}'
                              '/${progress.totalLevelCount}',
                          badgeColor: AppPalette.red,
                          onPressed: () => _open(
                            context,
                            const LevelSelectScreen(),
                          ),
                        ),
                        MenuTile(
                          compact: !isWide,
                          assetPath: AssetPaths.iconBucket,
                          label: 'Taller',
                          colors: const [
                            AppPalette.blue,
                            AppPalette.violet,
                          ],
                          badge: '★',
                          badgeColor: AppPalette.blue,
                          onPressed: () => _open(
                            context,
                            const StudioScreen(),
                          ),
                        ),
                        MenuTile(
                          compact: !isWide,
                          assetPath: AssetPaths.iconBook,
                          label: 'Pegatinas',
                          colors: const [
                            AppPalette.cyan,
                            AppPalette.blue,
                          ],
                          badge: _stickerBadge(progress),
                          badgeColor: AppPalette.cyan,
                          onPressed: () => _open(
                            context,
                            const StickerBookScreen(),
                          ),
                        ),
                      ];
                      return isWide
                          ? _WideMenu(tiles: tiles)
                          : _TallMenu(tiles: tiles);
                    },
                  ),
                ),
              ],
            ),
          ),
          // Posicionado: un hijo suelto cambiaria el tamaño del Stack y
          // provocaria un salto de layout al mostrarse un desbloqueo.
          const Positioned.fill(child: UnlockOverlay()),
        ],
      ),
    );
  }

  String _pageBadge(ProgressProvider progress) {
    final unlocked = GameContent.pages
        .where((page) => progress.isPageUnlocked(page.id))
        .length;
    return '$unlocked/${GameContent.pages.length}';
  }

  String _stickerBadge(ProgressProvider progress) {
    final unlocked = GameContent.stickers
        .where((sticker) => progress.isStickerUnlocked(sticker.id))
        .length;
    return '$unlocked/${GameContent.stickers.length}';
  }

  void _open(BuildContext context, Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress});

  final ProgressProvider progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppPalette.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppPalette.blue, width: 3),
                      ),
                      padding: const EdgeInsets.all(7),
                      child: Image.asset(
                        AssetPaths.iconBrush,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pincel',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.red,
                            height: 1.02,
                          ),
                        ),
                        Text(
                          '& Carreras',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.blue,
                            height: 1.02,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          StarCounter(stars: progress.totalStars, size: 54),
          const SizedBox(width: 8),
          const _SoundButton(),
          const SizedBox(width: 8),
          HelpButton(
            size: 48,
            title: 'Cómo se juega',
            tips: const [
              'Pintar: elige una lámina y dibuja con el dedo. El bote '
                  'rellena sola la zona que tocas.',
              'Carreras: toca las flechas ⟵ ⟶ o arrastra el coche. '
                  'Recoge las estrellas y llega a la meta.',
              'Subidas: mantén pulsado ACELERAR para subir las '
                  'montañas y FRENAR para bajar despacio.',
              'Taller: pinta la calca de tu coche y elige el pasajero '
                  'que viaja contigo.',
              'Las estrellas se ganan jugando: dan color para más '
                  'pegatinas, colores y vehículos.',
            ],
          ),
        ],
      ),
    );
  }
}

class _SoundButton extends StatefulWidget {
  const _SoundButton();

  @override
  State<_SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<_SoundButton> {
  @override
  Widget build(BuildContext context) {
    final audio = audioServiceOf(context);
    final muted = audio?.isMuted ?? false;
    return Semantics(
      button: true,
      label: muted ? 'Activar sonido' : 'Silenciar',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          audio?.setMuted(!muted);
          if (!muted) {
            audio?.playSfx(SfxKind.uiTap);
          }
          HapticFeedback.lightImpact();
          setState(() {});
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppPalette.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: muted ? AppPalette.ink : AppPalette.cyan,
              width: 3,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                offset: Offset(0, 4),
                blurRadius: 7,
              ),
            ],
          ),
          child: Icon(
            muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: muted ? AppPalette.ink : AppPalette.blue,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _TallMenu extends StatelessWidget {
  const _TallMenu({required this.tiles});

  final List<MenuTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 4, 22, 12),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Expanded(child: tiles[i]),
          ],
        ],
      ),
    );
  }
}

class _WideMenu extends StatelessWidget {
  const _WideMenu({required this.tiles});

  final List<MenuTile> tiles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(34, 10, 34, 18),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(width: 22),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 330,
                    maxHeight: 430,
                  ),
                  child: tiles[i],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuBackground extends StatelessWidget {
  const _MenuBackground({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value * math.pi * 2;
        return Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppPalette.cream, Color(0xFFF3F9FF)],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -70 + math.sin(t) * 14,
              right: -50 + math.cos(t) * 12,
              child: _Blob(
                color: AppPalette.yellow.withValues(alpha: 0.32),
                size: 230,
              ),
            ),
            Positioned(
              bottom: -90 + math.cos(t) * 12,
              left: -60 + math.sin(t) * 10,
              child: _Blob(
                color: AppPalette.cyan.withValues(alpha: 0.24),
                size: 270,
              ),
            ),
            Positioned(
              top: 190 + math.sin(t * 1.3) * 18,
              left: -36,
              child: _Blob(
                color: AppPalette.pink.withValues(alpha: 0.2),
                size: 140,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
