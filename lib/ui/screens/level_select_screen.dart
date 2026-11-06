import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/level_catalog.dart';
import '../../data/models/level_spec.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../shared/context_extensions.dart';
import 'racing_screen.dart';
import '../widgets/big_button.dart';
import '../widgets/help_button.dart';
import '../widgets/star_counter.dart';
import '../widgets/thumbnails.dart';
import '../widgets/unlock_overlay.dart';
import 'garage_screen.dart';

/// Mapa de los diez niveles de carreras.
///
/// Cada tarjeta muestra el numero, la pista y el ambiente del nivel. El
/// siguiente nivel jugable lleva un boton de play para que el nino sepa
/// donde tocar sin leer.
class LevelSelectScreen extends StatelessWidget {
  /// Crea el mapa de niveles.
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final nextPlayable = _nextPlayable(progress);

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: Stack(
        children: [
          const _LevelBackground(),
          SafeArea(
            child: Column(
              children: [
                _Header(progress: progress, next: nextPlayable),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = _columns(constraints.maxWidth);
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.84,
                        ),
                        itemCount: LevelCatalog.levels.length,
                        itemBuilder: (context, index) {
                          final level = LevelCatalog.levels[index];
                          return _LevelCard(
                            key: ValueKey<String>('level_${level.id}'),
                            level: level,
                            unlocked: progress.isLevelUnlocked(level.id),
                            completed: progress.isLevelCompleted(level.id),
                            bestSeconds: progress.bestTimeFor(level.id),
                            medal: level.medalFor(
                              progress.bestTimeFor(level.id),
                            ),
                            highlighted: level.id == nextPlayable?.id,
                            onTap: () => _open(context, level),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(child: UnlockOverlay()),
        ],
      ),
    );
  }

  LevelSpec? _nextPlayable(ProgressProvider progress) {
    for (final level in LevelCatalog.levels) {
      if (progress.isLevelUnlocked(level.id) &&
          !progress.isLevelCompleted(level.id)) {
        return level;
      }
    }
    return null;
  }

  int _columns(double width) {
    if (width >= 900) {
      return 5;
    }
    if (width >= 640) {
      return 4;
    }
    if (width >= 420) {
      return 3;
    }
    return 2;
  }

  void _open(BuildContext context, LevelSpec level) {
    final progress = context.read<ProgressProvider>();
    final audio = audioServiceOf(context);
    audio?.playSfx(SfxKind.uiTap);
    if (!progress.isLevelUnlocked(level.id)) {
      return;
    }
    progress.selectLevel(level.id);
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RacingScreen(levelId: level.id),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.progress, required this.next});

  final ProgressProvider progress;
  final LevelSpec? next;

  @override
  Widget build(BuildContext context) {
    final vehicle =
        GameContent.vehicleById(progress.progress.selectedVehicle) ??
            GameContent.vehicles.first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          AppIconButton(
            assetPath: AssetPaths.iconBack,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          Semantics(
            button: true,
            label: 'Garaje',
            child: GestureDetector(
              key: const ValueKey<String>('garage_button'),
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const GarageScreen(),
                ),
              ),
              child: CarThumbnail(assetPath: vehicle.assetPath, size: 44),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Text(
                      'Niveles',
                      style: TextStyle(
                        color: AppPalette.ink,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppPalette.violet,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        '${progress.completedLevelCount}'
                        '/${progress.totalLevelCount}',
                        style: const TextStyle(
                          color: AppPalette.violet,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          StarCounter(stars: progress.totalStars, size: 52),
          const SizedBox(width: 8),
          HelpButton(
            size: 48,
            title: 'Cómo se juega a las carreras',
            tips: const [
              'Toca las flechas ⟵ ⟶ de la pantalla o arrastra el coche '
                  'para moverte por la carretera.',
              'Recoge las estrellas: dan puntos y desbloquean cosas.',
              'Cada mundo dura un minuto largo y termina en una meta: '
                  'al cruzarla lo superas.',
              'Los mundos se abren en orden: gana el siguiente con '
                  'tu récord.',
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    super.key,
    required this.level,
    required this.unlocked,
    required this.completed,
    required this.bestSeconds,
    required this.medal,
    required this.highlighted,
    required this.onTap,
  });

  final LevelSpec level;
  final bool unlocked;
  final bool completed;
  final int bestSeconds;
  final LevelMedal medal;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final track = GameContent.trackById(level.trackId) ??
        GameContent.tracks.first;
    final accent = _effectColor(level.effect);

    return Semantics(
      button: true,
      enabled: unlocked,
      label: 'Nivel ${level.number}: ${level.name}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            color: AppPalette.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: highlighted ? accent : const Color(0x22000000),
              width: highlighted ? 5 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: highlighted ? 0.35 : 0.16),
                offset: const Offset(0, 6),
                blurRadius: highlighted ? 14 : 8,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                track.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => ColoredBox(
                  color: accent.withValues(alpha: 0.25),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0xCC2B2D42),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.white, width: 3),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${level.number}',
                    style: const TextStyle(
                      color: AppPalette.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              if (completed)
                const Positioned(
                  top: 10,
                  right: 10,
                  child: _CompletedBadge(),
                ),              if (!unlocked)
                const ColoredBox(
                  color: Color(0x99000000),
                  child: Center(
                    child: Icon(
                      Icons.lock_rounded,
                      color: AppPalette.white,
                      size: 46,
                    ),
                  ),
                ),
              if (unlocked && !completed && highlighted)
                const Positioned(
                  top: 12,
                  right: 12,
                  child: _PlayBadge(),
                ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _effectIcon(level.effect),
                          color: accent,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            level.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppPalette.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      unlocked
                          ? (bestSeconds > 0
                              ? '★ ${level.starsPerLap} · ${_format(bestSeconds)}'
                              : '★ ${level.starsPerLap}')
                          : '—',
                      style: const TextStyle(
                        color: AppPalette.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (medal != LevelMedal.none)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _MedalBadge(medal: medal),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Medalla del mundo (bronce, plata u oro).
class _MedalBadge extends StatelessWidget {
  const _MedalBadge({required this.medal});

  final LevelMedal medal;

  @override
  Widget build(BuildContext context) {
    final color = switch (medal) {
      LevelMedal.gold => AppPalette.gold,
      LevelMedal.silver => AppPalette.silver,
      LevelMedal.bronze => AppPalette.bronze,
      LevelMedal.none => AppPalette.white,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.white, width: 2),
      ),
      child: Text(
        medal == LevelMedal.gold
            ? '★ Oro'
            : medal == LevelMedal.silver
                ? '★ Plata'
                : '★ Bronce',
        style: const TextStyle(
          color: AppPalette.ink,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {  const _CompletedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: const BoxDecoration(
        color: AppPalette.green,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_rounded,
        color: AppPalette.white,
        size: 24,
      ),
    );
  }
}

class _PlayBadge extends StatelessWidget {
  const _PlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: AppPalette.yellow,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.play_arrow_rounded,
        color: AppPalette.ink,
        size: 28,
      ),
    );
  }
}

class _LevelBackground extends StatelessWidget {
  const _LevelBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.cream, Color(0xFFE8F4FF)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -70,
          right: -50,
          child: _Blob(
            color: AppPalette.violet.withValues(alpha: 0.18),
            size: 240,
          ),
        ),
        Positioned(
          bottom: -90,
          left: -60,
          child: _Blob(
            color: AppPalette.cyan.withValues(alpha: 0.18),
            size: 260,
          ),
        ),
      ],
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

/// Formatea un record en segundos como `m:ss`.
String _format(int seconds) {
  final minutes = seconds ~/ 60;
  final rest = (seconds % 60).toString().padLeft(2, '0');
  return '$minutes:$rest';
}

IconData _effectIcon(LevelEffect effect) => switch (effect) {      LevelEffect.petals => Icons.local_florist_rounded,
      LevelEffect.butterflies => Icons.filter_vintage_rounded,
      LevelEffect.bubbles => Icons.bubble_chart_rounded,
      LevelEffect.balloons => Icons.celebration_rounded,
      LevelEffect.fireflies => Icons.flare_rounded,
      LevelEffect.shootingStars => Icons.auto_awesome_rounded,
      LevelEffect.confetti => Icons.emoji_events_rounded,
      LevelEffect.snow => Icons.ac_unit_rounded,
      LevelEffect.leaves => Icons.eco_rounded,
      LevelEffect.sparkles => Icons.blur_on_rounded,
      LevelEffect.sand => Icons.grain_rounded,
      LevelEffect.waves => Icons.waves_rounded,
      LevelEffect.embers => Icons.local_fire_department_rounded,
    };

Color _effectColor(LevelEffect effect) => switch (effect) {
      LevelEffect.petals => AppPalette.pink,
      LevelEffect.butterflies => AppPalette.violet,
      LevelEffect.bubbles => AppPalette.cyan,
      LevelEffect.balloons => AppPalette.red,
      LevelEffect.fireflies => AppPalette.yellow,
      LevelEffect.shootingStars => AppPalette.blue,
      LevelEffect.confetti => AppPalette.orange,
      LevelEffect.snow => const Color(0xFF7FC8FF),
      LevelEffect.leaves => AppPalette.brown,
      LevelEffect.sparkles => AppPalette.green,
      LevelEffect.sand => const Color(0xFFE0A458),
      LevelEffect.waves => AppPalette.cyan,
      LevelEffect.embers => const Color(0xFFFF7043),
    };
