import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_sizes.dart';
import '../../core/constants/palette.dart';
import '../../data/models/game_content.dart';
import '../../data/models/level_catalog.dart';
import '../../data/models/level_spec.dart';
import '../../data/models/vehicle_customization.dart';
import '../../data/providers/progress_provider.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/tilt_service.dart';
import '../../game/racing/racing_game.dart';
import '../../shared/context_extensions.dart';
import '../widgets/big_button.dart';
import '../widgets/star_counter.dart';
import '../widgets/thumbnails.dart';
import '../widgets/unlock_overlay.dart';
import 'garage_screen.dart';

/// Pantalla de carreras.
///
/// El nino entra y ya esta jugando: no hay menus intermedios. Un toque a
/// la izquierda o a la derecha cambia de carril. El nivel define la pista,
/// la velocidad y el ambiente animado.
class RacingScreen extends StatefulWidget {
  /// Crea la pantalla de carreras.
  const RacingScreen({
    super.key,
    this.levelId,
    this.tiltService,
  });

  /// Nivel concreto; si se omite se usa el seleccionado en el mapa.
  final String? levelId;

  /// Servicio de direccion por inclinacion (inyectable para los tests).
  final TiltService? tiltService;

  @override
  State<RacingScreen> createState() => _RacingScreenState();
}

class _RacingScreenState extends State<RacingScreen>
    with WidgetsBindingObserver {
  final GlobalKey<GameWidgetState<RacingGame>> _gameKey =
      GlobalKey<GameWidgetState<RacingGame>>();
  RacingGame? _game;
  AudioService? _audio;

  /// Direccion por inclinacion: el nino gira el movil como un volante.
  late final TiltService _tilt;
  late LevelSpec _level;
  bool _paused = false;
  bool _completed = false;
  int _raceStars = 0;
  int _raceTime = 0;
  int _bestTime = 0;
  LevelMedal _medal = LevelMedal.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audio = audioServiceOf(context);
    _tilt = widget.tiltService ?? TiltService();
    final provider = context.read<ProgressProvider>();
    _level = LevelCatalog.byId(widget.levelId ?? '') ??
        provider.selectedLevel;
    _game = _createGame();
    unawaited(_audio?.playBgm(BgmTrack.racing) ?? Future<void>.value());
    // El volante: el nino inclina el movil para dirigir. Si el dispositivo no
    // tiene sensor, el servicio se queda neutro y el juego sigue igual.
    unawaited(_tilt.start());
    // Las carreras se juegan **acostadas**: el movil en horizontal, como un
    // volante. Al salir se recupera la orientacion del resto de la app.
    unawaited(_lockLandscape());
  }

  /// Pide la orientacion horizontal (solo en movil: en web la API no existe).
  Future<void> _lockLandscape() async {
    if (kIsWeb) {
      return;
    }
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (error) {
      debugPrint('[Pincel] No se pudo girar la pantalla: $error');
    }
  }

  /// Recupera la orientacion normal de la app.
  Future<void> _unlockOrientation() async {
    if (kIsWeb) {
      return;
    }
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (error) {
      debugPrint('[Pincel] No se pudo restaurar la orientacion: $error');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final game = _game;
    if (state == AppLifecycleState.resumed) {
      if (!_paused && !_completed) {
        game?.resumeEngine();
        unawaited(_audio?.resumeBgm() ?? Future<void>.value());
      }
      return;
    }
    // En segundo plano no debe quedar ni una colision viva ni musica
    // sonando: el juego se detiene hasta que el nino vuelve.
    game?.pauseEngine();
    unawaited(_audio?.pauseBgm() ?? Future<void>.value());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Sin esto, al volver al menu el Ticker de Flame seguia moviendo el
    // coche y la musica de carreras no se callaba nunca.
    _game?.halt();
    _tilt.stop();
    unawaited(_unlockOrientation());
    _game = null;
    unawaited(_audio?.stopBgm() ?? Future<void>.value());
    super.dispose();
  }

  RacingGame _createGame() {
    final provider = context.read<ProgressProvider>();
    final vehicle = GameContent.vehicleById(provider.progress.selectedVehicle) ??
        GameContent.vehicles.first;
    final track = GameContent.trackById(_level.trackId) ??
        GameContent.tracks.first;
    final decal = VehicleCustomization.decalById(
      provider.progress.selectedDecal,
    );
    final character = VehicleCustomization.characterById(
      provider.progress.selectedCharacter,
    );
    return RacingGame(
      carAssetPath: vehicle.assetPath,
      trackAssetPath: track.assetPath,
      asphaltAssetPath: track.asphaltAssetPath,
      curbAssetPath: track.curbAssetPath,
      decalAssetPath: decal?.assetPath,
      decalColor: provider.progress.selectedDecalColor,
      characterAssetPath: character?.assetPath,
      effect: _level.effect,
      speedScale: _level.speedScale,
      levelSeed: _level.number,
      starsPerLap: _level.starsPerLap,
      vehicleWidthFactor: vehicle.widthFactor,
      vehicleHeightFactor: vehicle.heightFactor,
      laps: _level.laps,
      targetSeconds: _level.targetSeconds,
      tiltService: _tilt,
      onStarCollected: (amount) {
        if (!mounted) {
          return;
        }
        _raceStars += amount;
        context.read<ProgressProvider>().addStars(amount);
      },
      onCrash: () {
        if (!mounted) {
          return;
        }
        _audio?.playSfx(SfxKind.crash);
      },
      onLapCompleted: _handleLapCompleted,
      onRaceFinished: _handleRaceFinished,
      onLaneChange: () {
        if (!mounted) {
          return;
        }
        _audio?.playSfx(SfxKind.swoosh);
      },
    );
  }

  void _handleLapCompleted() {
    if (!mounted) {
      return;
    }
    context.read<ProgressProvider>().completeLap();
  }

  /// La meta cierra la carrera: se celebra con el resumen del recorrido.
  void _handleRaceFinished() {
    if (!mounted) {
      return;
    }
    final provider = context.read<ProgressProvider>();
    final seconds = _game?.raceSeconds.round() ?? 0;
    provider.completeLap();
    final firstTime = provider.completeLevel(_level.id);
    provider.recordBestTime(_level.id, seconds);
    if (firstTime) {
      // Recompensa por superar el mundo: mas estrellas para el siguiente.
      provider.addStars(LevelSpec.completionBonus);
    }
    _game?.pauseEngine();
    unawaited(_audio?.pauseBgm() ?? Future<void>.value());
    _audio?.playSfx(SfxKind.unlock);
    setState(() {
      _completed = true;
      _paused = false;
      _raceTime = seconds;
      _bestTime = provider.bestTimeFor(_level.id);
      _medal = _level.medalFor(_bestTime);
    });
  }

  void _restart() {
    _game?.halt();
    setState(() {
      _game = _createGame();
      _paused = false;
      _completed = false;
      _raceStars = 0;
      _raceTime = 0;
      _bestTime = 0;
      _medal = LevelMedal.none;
    });
    unawaited(_audio?.resumeBgm() ?? Future<void>.value());
    _audio?.playSfx(SfxKind.uiTap);
  }

  /// Abre el garaje para cambiar de vehiculo.
  Future<void> _openGarage() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (context) => const GarageScreen()),
    );
    if (selected == null || !mounted) {
      return;
    }
    // El vehiculo cambia **al instante**: se recrea la carrera con el nuevo.
    _restart();
  }

  /// Acelera (o frena) segun el boton que el nino mantenga pulsado.
  void _setPedal({required bool accelerating, required bool braking}) {
    final game = _gameKey.currentState?.currentGame ?? _game;
    if (game == null) {
      return;
    }
    final wasStopped = game.currentSpeed < 20;
    game.accelerating = accelerating;
    game.braking = braking;
    if (accelerating && wasStopped) {
      // "Vroom": el motor arranca cuando el nino empuja.
      _audio?.playSfx(SfxKind.engine);
    }
  }

  void _goToLevel(LevelSpec level) {
    context.read<ProgressProvider>().selectLevel(level.id);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (context, animation, secondaryAnimation) =>
            RacingScreen(levelId: level.id),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goToMap() {
    Navigator.of(context).maybePop();
  }

  void _togglePause() {
    if (_completed) {
      return;
    }
    final game = _gameKey.currentState?.currentGame ?? _game;
    if (game == null) {
      return;
    }
    setState(() => _paused = !_paused);
    if (_paused) {
      game.pauseEngine();
      unawaited(_audio?.pauseBgm() ?? Future<void>.value());
    } else {
      game.resumeEngine();
      unawaited(_audio?.resumeBgm() ?? Future<void>.value());
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProgressProvider>();
    final vehicle =
        GameContent.vehicleById(provider.progress.selectedVehicle) ??
            GameContent.vehicles.first;

    return Scaffold(
      backgroundColor: AppPalette.ink,
      body: Stack(
        children: [
          // El mundo del juego esta en vertical (la pista baja) pero la
          // pantalla esta **acostada**: girando el juego 90 grados la pista
          // queda horizontal y el coche avanza hacia la derecha, como en un
          // juego de carreras de verdad. La interfaz (barras, pedales y HUD)
          // queda siempre derecha y legible.
          Positioned.fill(
            child: RotatedBox(
              quarterTurns: 1,
              child: GameWidget<RacingGame>(
                key: _gameKey,
                game: _game!,
                backgroundBuilder: (context) => const ColoredBox(
                  color: AppPalette.ink,
                  child: SizedBox.expand(),
                ),
              ),
            ),
          ),
          // OJO: todos los hijos del Stack deben ir posicionados. Un `Stack`
          // se dimensiona al hijo NO posicionado mas grande, asi que un
          // hijo suelto (la barra superior) dejaria el juego en 80 px de
          // alto en vez de ocupar la pantalla completa.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 380;
                    final thumbSize =
                        compact ? 46.0 : GameSizes.smallButtonSize;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppIconButton(
                          assetPath: AssetPaths.iconBack,
                          onPressed: _goToMap,
                        ),
                        const SizedBox(width: 6),
                        Semantics(
                          button: true,
                          label: 'Garaje',
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _openGarage,
                            child: CarThumbnail(
                              assetPath: vehicle.assetPath,
                              size: thumbSize,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _LevelBadge(level: _level, compact: compact),
                        const Spacer(),
                        StarCounter(
                          stars: provider.totalStars,
                          size: compact ? 44 : 52,
                          showNumber: !compact,
                        ),
                        const SizedBox(width: 6),
                        AppIconButton(
                          assetPath: AssetPaths.iconPause,
                          onPressed: _togglePause,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          if (_paused) _buildPauseOverlay(),
          if (_completed) _buildSummaryOverlay(),
          // Controles visibles: el nino ve donde tocar para ir a cada lado.
          if (!_paused && !_completed) _buildSteering(),
          if (!_paused && !_completed) _buildHud(),
          const Positioned.fill(child: UnlockOverlay()),
        ],
      ),
    );
  }

  Widget _buildSteering() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Pista de como dirigir: el nino inclina el movil.
              const _SteerHint(),
              // Frenar.
              _PedalButton(
                key: const ValueKey<String>('brake'),
                icon: Icons.pause_rounded,
                label: 'Frenar',
                color: AppPalette.red,
                size: 60,
                onPressed: (value) => _setPedal(
                  accelerating: false,
                  braking: value,
                ),
              ),
              // Acelerar: hay que mantenerlo pulsado.
              _PedalButton(
                key: const ValueKey<String>('accelerate'),
                icon: Icons.play_arrow_rounded,
                label: 'Acelerar',
                color: AppPalette.green,
                size: 76,
                onPressed: (value) => _setPedal(
                  accelerating: value,
                  braking: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Marcador: velocidad y progreso hacia la meta.
  ///
  /// Es un widget aparte con su propio ticker: solo se repinta la chapa del
  /// HUD en cada frame, no toda la pantalla.
  Widget _buildHud() {
    return Positioned(
      top: 62,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Center(
          child: _RaceHud(
            gameProvider: () => _gameKey.currentState?.currentGame ?? _game,
            active: !_paused && !_completed,
          ),
        ),
      ),
    );
  }

  Widget _buildPauseOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xCC2B2D42),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePause,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AssetPaths.iconPause,
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stack) =>
                      const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppPalette.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: AppPalette.green,
                        size: 34,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Seguir',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppPalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Formatea un tiempo en segundos como `m:ss`.
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$rest';
  }

  /// Nombre de la medalla conseguida.
  String _medalName(LevelMedal medal) => switch (medal) {
        LevelMedal.none => '—',
        LevelMedal.bronze => 'Bronce',
        LevelMedal.silver => 'Plata',
        LevelMedal.gold => 'Oro',
      };

  /// Resumen de la carrera: es el **final** del mundo.
  Widget _buildSummaryOverlay() {
    final next = LevelCatalog.nextAfter(_level.id);
    final isLast = next == null;
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xE62B2D42),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 620),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) =>
                        Transform.scale(scale: value, child: child),
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: AppPalette.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isLast ? AppPalette.gold : AppPalette.yellow,
                          width: 8,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isLast
                            ? Icons.emoji_events_rounded
                            : Icons.flag_rounded,
                        size: 80,
                        color: isLast ? AppPalette.gold : AppPalette.yellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isLast ? '¡Campeón!' : '¡Meta!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppPalette.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _level.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppPalette.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SummaryStat(
                    icon: Icons.star_rounded,
                    label: 'Estrellas',
                    value: '$_raceStars',
                  ),
                  const SizedBox(height: 8),
                  _SummaryStat(
                    icon: Icons.timer_rounded,
                    label: 'Tiempo',
                    value: _formatTime(_raceTime),
                  ),
                  const SizedBox(height: 8),
                  _SummaryStat(
                    icon: Icons.emoji_events_rounded,
                    label: 'Mejor',
                    value: _formatTime(_bestTime),
                  ),
                  const SizedBox(height: 8),
                  _SummaryStat(
                    icon: Icons.military_tech_rounded,
                    label: 'Medalla',
                    value: _medalName(_medal),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundAction(
                        icon: Icons.replay_rounded,
                        color: AppPalette.cyan,
                        label: 'Repetir',
                        onTap: _restart,
                      ),
                      if (next != null) ...[
                        const SizedBox(width: 16),
                        _RoundAction(
                          icon: Icons.play_arrow_rounded,
                          color: AppPalette.green,
                          label: 'Siguiente',
                          onTap: () => _goToLevel(next),
                        ),
                      ],
                      const SizedBox(width: 16),
                      _RoundAction(
                        icon: Icons.map_rounded,
                        color: AppPalette.orange,
                        label: 'Mapa',
                        onTap: _goToMap,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dato del resumen de carrera (estrellas, tiempo, record).
class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
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

/// Pista de como dirigir: el nino inclina el movil como un volante.
///
/// Sustituye a los botones de flechas: con el movil en horizontal no hace
/// falta tocar la pantalla para ir de un lado a otro.
class _SteerHint extends StatelessWidget {
  const _SteerHint();

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Semantics(
        label: 'Inclina el móvil para dirigir el coche',
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppPalette.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppPalette.ink, width: 2),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.swap_horiz_rounded, color: AppPalette.ink, size: 26),
                SizedBox(width: 6),
                Text(
                  'Inclina',
                  style: TextStyle(
                    color: AppPalette.ink,
                    fontSize: 15,
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
}

/// Chapa del marcador: velocidad actual y progreso hacia la meta.
///
/// Lleva **su propio ticker** paraActualizarse en cada frame sin repintar
/// toda la pantalla de carreras (que contiene el `GameWidget` de Flame).
class _RaceHud extends StatefulWidget {
  const _RaceHud({required this.gameProvider, required this.active});

  /// Devuelve el juego vivo (cambia al reiniciar la carrera).
  final RacingGame? Function() gameProvider;

  /// `false` cuando la carrera esta en pausa o terminada: el ticker se para.
  final bool active;

  @override
  State<_RaceHud> createState() => _RaceHudState();
}

class _RaceHudState extends State<_RaceHud>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) {
        setState(() {});
      }
    });
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant _RaceHud oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  /// Arranca o para el ticker segun el estado de la carrera.
  void _syncTicker() {
    if (widget.active) {
      if (!_ticker.isActive) {
        _ticker.start();
      }
    } else if (_ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.gameProvider();
    final speed = game?.currentSpeed ?? 0;
    final max = game?.maxSpeed ?? 1;
    final progress = game?.progress ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppPalette.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppPalette.violet, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.speed_rounded,
            color: AppPalette.red,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            '${speed.round()}',
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          // Las barras ceden espacio si la pantalla es estrecha: el HUD
          // nunca puede desbordar.
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 86),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (speed / max).clamp(0.0, 1.0),
                  minHeight: 9,
                  backgroundColor: const Color(0x22000000),
                  valueColor: const AlwaysStoppedAnimation(AppPalette.green),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 86),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 9,
                  backgroundColor: const Color(0x22000000),
                  valueColor: const AlwaysStoppedAnimation(AppPalette.violet),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pedal: hay que **mantenerlo pulsado** (acelerar o frenar).
///
/// Es el control principal: el nino marca el ritmo de la carrera.
class _PedalButton extends StatefulWidget {
  const _PedalButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.size,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double size;
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
          scale: _pressed ? 0.9 : 1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: widget.size,
                height: widget.size,
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
                child: Icon(
                  widget.icon,
                  color: AppPalette.white,
                  size: widget.size * 0.56,
                ),
              ),
              const SizedBox(height: 4),
              // La etiqueta nunca puede ser mas ancha que el pedal: en
              // pantallas estrechas se encoge.
              SizedBox(
                width: widget.size,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    style: const TextStyle(
                      color: AppPalette.white,
                      fontSize: 14,
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.compact});

  final LevelSpec level;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    // En movil estrecho la insignia es un circulo con el numero: cabe
    // siempre en la barra superior sin desbordarse.
    if (compact) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppPalette.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppPalette.violet, width: 3),
        ),
        alignment: Alignment.center,
        child: Text(
          '${level.number}',
          style: const TextStyle(
            color: AppPalette.violet,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppPalette.violet, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.flag_rounded,
            color: AppPalette.violet,
            size: 24,
          ),
          const SizedBox(width: 6),
          Text(
            '${level.number}',
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
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
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    offset: Offset(0, 6),
                    blurRadius: 12,
                  ),
                ],
              ),
              alignment: Alignment.center,
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
