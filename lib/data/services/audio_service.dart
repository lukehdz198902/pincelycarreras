import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/asset_paths.dart';

/// Efectos de sonido del juego.
enum SfxKind {
  /// Burbuja al pintar.
  pop,

  /// Deslizamiento al cambiar de carril.
  swoosh,

  /// Campana al recoger una estrella.
  ding,

  /// Golpe suave al chocar (nunca punitivo).
  crash,

  /// Arpegio al desbloquear una recompensa.
  unlock,

  /// Toque de interfaz.
  uiTap,

  /// Campanilla de bienvenida de la pantalla de inicio.
  welcome,
}

/// Pistas de musica de fondo.
enum BgmTrack {
  /// Musica tranquila del estudio de pintura.
  painting,

  /// Musica rítmica de las carreras.
  racing,

  /// Motor del modo "Subidas" (zumbido en bucle).
  engine,
}

/// Capa de audio del juego.
///
/// Envuelve `flame_audio` y garantiza tres cosas:
/// - la musica se reproduce en bucle y se pausa sola en segundo plano;
/// - ningun efecto suena mas de 4 veces por segundo (evita saturacion);
/// - si el audio falla, el juego **sigue funcionando en silencio**.
class AudioService {
  /// Crea el servicio de audio.
  AudioService();

  /// Maximo de reproducciones del mismo efecto por segundo.
  static const int maxPlaysPerSecond = 4;

  /// Volumen de la musica de pintura.
  static const double paintingVolume = 0.35;

  /// Volumen de la musica de carreras.
  static const double racingVolume = 0.30;

  /// Volumen del motor del modo subidas.
  static const double engineVolume = 0.22;

  final Map<SfxKind, List<DateTime>> _recentPlays = {};
  bool _initialized = false;
  bool _muted = false;
  BgmTrack? _currentTrack;
  bool _bgmPaused = false;

  /// `true` si el audio esta silenciado.
  bool get isMuted => _muted;

  /// Prepara el reproductor global de musica.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    try {
      await FlameAudio.bgm.initialize();
    } catch (error) {
      debugPrint('[Pincel] Audio no disponible: $error');
    }
  }

  /// Activa o desactiva el sonido.
  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      unawaited(stopBgm());
    }
  }

  /// Reproduce la musica de fondo indicada en bucle.
  ///
  /// Repetir la misma pista no la reinicia: evita un corte audible al
  /// reconstruir una pantalla.
  Future<void> playBgm(BgmTrack track) async {
    if (_muted) {
      return;
    }
    if (_currentTrack == track && !_bgmPaused) {
      return;
    }
    final path = switch (track) {
      BgmTrack.painting => AssetPaths.music('painting_loop'),
      BgmTrack.racing => AssetPaths.music('racing_loop'),
      BgmTrack.engine => AssetPaths.music('motor_loop'),
    };
    final volume = switch (track) {
      BgmTrack.painting => paintingVolume,
      BgmTrack.racing => racingVolume,
      BgmTrack.engine => engineVolume,
    };
    _currentTrack = track;
    _bgmPaused = false;
    try {
      await FlameAudio.bgm.play(path, volume: volume);
    } catch (error) {
      debugPrint('[Pincel] No se pudo iniciar la musica: $error');
    }
  }

  /// Pausa la musica sin perder la pista actual.
  Future<void> pauseBgm() async {
    if (_currentTrack == null || _bgmPaused) {
      return;
    }
    _bgmPaused = true;
    try {
      await FlameAudio.bgm.pause();
    } catch (error) {
      debugPrint('[Pincel] No se pudo pausar la musica: $error');
    }
  }

  /// Reanuda la musica pausada.
  Future<void> resumeBgm() async {
    if (_currentTrack == null || !_bgmPaused) {
      return;
    }
    _bgmPaused = false;
    try {
      await FlameAudio.bgm.resume();
    } catch (error) {
      debugPrint('[Pincel] No se pudo reanudar la musica: $error');
    }
  }

  /// Detiene la musica de fondo.
  Future<void> stopBgm() async {
    _currentTrack = null;
    _bgmPaused = false;
    try {
      await FlameAudio.bgm.stop();
    } catch (error) {
      debugPrint('[Pincel] No se pudo detener la musica: $error');
    }
  }

  /// Reproduce un efecto de sonido.
  ///
  /// No bloquea: el sonido se solapa con la accion del nino.
  void playSfx(SfxKind kind) {
    if (_muted || _isCoolingDown(kind)) {
      return;
    }
    final path = switch (kind) {
      SfxKind.pop => AssetPaths.sfx('pop'),
      SfxKind.swoosh => AssetPaths.sfx('swoosh'),
      SfxKind.ding => AssetPaths.sfx('ding'),
      SfxKind.crash => AssetPaths.sfx('crash'),
      SfxKind.unlock => AssetPaths.sfx('unlock'),
      SfxKind.uiTap => AssetPaths.sfx('ui_tap'),
      SfxKind.welcome => AssetPaths.sfx('welcome'),
    };
    unawaited(_playSfx(path));
  }

  Future<void> _playSfx(String path) async {
    try {
      await FlameAudio.play(path, volume: 0.7);
    } catch (error) {
      debugPrint('[Pincel] Error de sonido: $error');
    }
  }

  bool _isCoolingDown(SfxKind kind) {
    final now = DateTime.now();
    final plays = _recentPlays.putIfAbsent(kind, () => <DateTime>[]);
    plays.removeWhere(
      (time) => now.difference(time) > const Duration(seconds: 1),
    );
    if (plays.length >= maxPlaysPerSecond) {
      return true;
    }
    plays.add(now);
    return false;
  }
}
