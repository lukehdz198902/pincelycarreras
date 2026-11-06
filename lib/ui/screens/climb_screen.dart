import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';
import '../../data/models/climb_track.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../game/racing/climb_game.dart';
import '../../shared/context_extensions.dart';
import '../widgets/big_button.dart';
import '../widgets/star_counter.dart';

/// Modo "Subidas": el vehiculo recorre el terreno hacia la derecha.
///
/// Dos botones gigantes: **acelerar** y **frenar**. El terreno tiene colinas,
/// rampas y vueltas de 360 grados. No hay derrota: el vehiculo siempre llega
/// a la meta y la carrera se resume al terminar.
class ClimbScreen extends StatefulWidget {
  /// Crea la pantalla de subidas.
  const ClimbScreen({super.key, this.trackId});

  /// Subida inicial; si se omite, la primera.
  final String? trackId;

  @override
  State<ClimbScreen> createState() => _ClimbScreenState();
}

class _ClimbScreenState extends State<ClimbScreen>
    with WidgetsBindingObserver {
  final GlobalKey<GameWidgetState<ClimbGame>> _gameKey =
      GlobalKey<GameWidgetState<ClimbGame>>();
  ClimbGame? _game;
  AudioService? _audio;
  late ClimbTrackSpec _track;
  int _raceStars = 0;
  int _raceTime = 0;
  int _raceDistance = 0;
  int _liveDistance = 0;
  int _liveSpeed = 0;
  bool _finished = false;
  Timer? _hudTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audio = audioServiceOf(context);
    _track = ClimbCatalog.byId(widget.trackId ?? '') ?? ClimbCatalog.tracks.first;
    _game = _createGame();
    unawaited(_audio?.playBgm(BgmTrack.engine) ?? Future<void>.value());
    // El HUD se actualiza cuatro veces por segundo: suficiente para que
    // parezca vivo sin castigar el rendimiento.
    _hudTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      final game = _game;
      if (!mounted || game == null) {
        return;
      }
      final distance = game.distance.round();
      final speed = game.currentSpeed.round();
      if (distance == _liveDistance && speed == _liveSpeed) {
        return;
      }
      setState(() {
        _liveDistance = distance;
        _liveSpeed = speed;
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final game = _game;
    if (state == AppLifecycleState.resumed) {
      if (!_finished) {
        game?.resumeEngine();
        unawaited(_audio?.resumeBgm() ?? Future<void>.value());
      }
      return;
    }
    game?.pauseEngine();
    unawaited(_audio?.pauseBgm() ?? Future<void>.value());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hudTimer?.cancel();
    _game?.halt();
    _game = null;
    unawaited(_audio?.stopBgm() ?? Future<void>.value());
    super.dispose();
  }

  ClimbGame _createGame() {
    return ClimbGame(
      carAssetPath: AssetPaths.sideCar,
      wheelAssetPath: AssetPaths.sideWheel,
      seed: _track.seed,
      loopCount: _track.loopCount,
      skyColor: _track.skyColor,
      hillColor: _track.hillColor,
      groundColor: _track.groundColor,
      onStarCollected: (amount) {
        if (!mounted) {
          return;
        }
        setState(() => _raceStars += amount);
        context.read<ProgressProvider>().addStars(amount);
      },
      onFinished: (distance, seconds) {
        if (!mounted) {
          return;
        }
        setState(() {
          _finished = true;
          _raceDistance = distance;
          _raceTime = seconds;
        });
        _audio?.playSfx(SfxKind.unlock);
      },
    );
  }

  void _restart() {
    _game?.halt();
    setState(() {
      _game = _createGame();
      _raceStars = 0;
      _raceTime = 0;
      _raceDistance = 0;
      _finished = false;
    });
    unawaited(_audio?.resumeBgm() ?? Future<void>.value());
  }

  void _selectTrack(ClimbTrackSpec track) {
    if (track.id == _track.id) {
      return;
    }
    _audio?.playSfx(SfxKind.uiTap);
    _game?.halt();
    setState(() {
      _track = track;
      _game = _createGame();
      _raceStars = 0;
      _raceTime = 0;
      _raceDistance = 0;
      _finished = false;
    });
  }

  void _setAccelerating(bool value) {
    final game = _gameKey.currentState?.currentGame ?? _game;
    game?.accelerating = value;
    if (value) {
      _audio?.playSfx(SfxKind.uiTap);
    }
  }

  void _setBraking(bool value) {
    final game = _gameKey.currentState?.currentGame ?? _game;
    game?.braking = value;
    if (value) {
      _audio?.playSfx(SfxKind.uiTap);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();

    return Scaffold(
      backgroundColor: _track.skyColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: GameWidget<ClimbGame>(
              key: _gameKey,
              game: _game!,
              backgroundBuilder: (context) => ColoredBox(
                color: _track.skyColor,
                child: SizedBox.expand(),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    AppIconButton(
                      assetPath: AssetPaths.iconBack,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _WorldPicker(
                        selected: _track,
                        onSelected: _selectTrack,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StarCounter(
                      stars: progress.totalStars,
                      size: 46,
                      showNumber: false,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_finished) _buildControls(),
          if (!_finished) _buildHud(),
          if (_finished) _buildSummary(),
        ],
      ),
    );
  }

  /// Marcador en vivo: metros recorridos y velocidad.
  Widget _buildHud() {
    return Positioned(
      top: 66,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppPalette.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppPalette.violet, width: 3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.route_rounded,
                  color: AppPalette.violet,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_liveDistance ~/ 10} m',
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.speed_rounded,
                  color: AppPalette.red,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  '$_liveSpeed',
                  style: const TextStyle(
                    color: AppPalette.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _PedalButton(
                key: const ValueKey<String>('brake'),
                icon: Icons.pause_rounded,
                label: 'Frenar',
                color: AppPalette.red,
                onPressed: (value) => _setBraking(value),
              ),
              _PedalButton(
                key: const ValueKey<String>('accelerate'),
                icon: Icons.play_arrow_rounded,
                label: 'Acelerar',
                color: AppPalette.green,
                onPressed: (value) => _setAccelerating(value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xE62B2D42),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: AppPalette.gold,
                  size: 110,
                ),
                const SizedBox(height: 8),
                const Text(
                  '¡Meta!',
                  style: TextStyle(
                    color: AppPalette.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _track.name,
                  style: const TextStyle(
                    color: AppPalette.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 18),
                _SummaryPill(
                  icon: Icons.star_rounded,
                  label: 'Estrellas',
                  value: '$_raceStars',
                ),
                const SizedBox(height: 8),
                _SummaryPill(
                  icon: Icons.timer_rounded,
                  label: 'Tiempo',
                  value: '${_raceTime ~/ 60}:'
                      '${(_raceTime % 60).toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 8),
                _SummaryPill(
                  icon: Icons.route_rounded,
                  label: 'Recorrido',
                  value: '${_raceDistance ~/ 10} m',
                ),
                const SizedBox(height: 26),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RoundButton(
                      icon: Icons.replay_rounded,
                      color: AppPalette.cyan,
                      label: 'Repetir',
                      onTap: _restart,
                    ),
                    const SizedBox(width: 18),
                    _RoundButton(
                      icon: Icons.map_rounded,
                      color: AppPalette.orange,
                      label: 'Salir',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Boton de pedal (acelerar o frenar).
class _PedalButton extends StatefulWidget {
  const _PedalButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final ValueChanged<bool> onPressed;

  @override
  State<_PedalButton> createState() => _PedalButtonState();
}

class _PedalButtonState extends State<_PedalButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          setState(() => _pressed = true);
          widget.onPressed(true);
        },
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed(false);
        },
        onTapCancel: () {
          setState(() => _pressed = false);
          widget.onPressed(false);
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          scale: _pressed ? 0.92 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppPalette.white, width: 5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x44000000),
                      offset: Offset(0, 6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(widget.icon, color: AppPalette.white, size: 54),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: const TextStyle(
                  color: AppPalette.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Color(0x88000000),
                      offset: Offset(0, 2),
                      blurRadius: 4,
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

/// Selector de subida (botones redondos con el numero).
class _WorldPicker extends StatelessWidget {
  const _WorldPicker({required this.selected, required this.onSelected});

  final ClimbTrackSpec selected;
  final ValueChanged<ClimbTrackSpec> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ClimbCatalog.tracks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final track = ClimbCatalog.tracks[index];
          final isSelected = track.id == selected.id;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onSelected(track),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isSelected ? track.groundColor : AppPalette.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppPalette.ink : const Color(0x33000000),
                  width: 3,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: isSelected ? AppPalette.white : AppPalette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Dato del resumen de la subida.
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppPalette.violet, size: 26),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppPalette.violet,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Boton redondo del resumen.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.white, width: 4),
              ),
              child: Icon(icon, color: AppPalette.white, size: 44),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppPalette.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
