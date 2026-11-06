import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/paint_stroke.dart';
import '../models/progress.dart';
/// Persistencia local del progreso del nino.
///
/// Usa exclusivamente `shared_preferences`: sin cuentas, sin nube y sin red.
/// Los dibujos de cada lamina se guardan como trazos serializados.
class ProgressService {
  /// Crea el servicio sobre unas preferencias ya inicializadas.
  ProgressService(this._prefs);

  /// Prepara el servicio obtaining las preferencias del sistema.
  static Future<ProgressService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ProgressService(prefs);
  }

  /// Prefijo de todas las claves del progreso.
  static const String keyPrefix = 'progress_';

  /// Clave del total de estrellas.
  static const String keyTotalStars = '${keyPrefix}total_stars';

  /// Clave de las estrellas de la sesion actual.
  static const String keySessionStars = '${keyPrefix}session_stars';

  /// Clave de las pegatinas desbloqueadas.
  static const String keyStickers = '${keyPrefix}unlocked_stickers';

  /// Clave de los colores desbloqueados.
  static const String keyColors = '${keyPrefix}unlocked_colors';

  /// Clave de los vehiculos desbloqueados.
  static const String keyCars = '${keyPrefix}unlocked_cars';

  /// Clave de los vehiculos desbloqueados (nombre historico).
  static const String keyVehicles = keyCars;

  /// Clave de las laminas desbloqueadas.
  static const String keyPages = '${keyPrefix}unlocked_pages';

  /// Clave de los niveles completados.
  static const String keyCompletedLevels = '${keyPrefix}completed_levels';

  /// Clave del vehiculo seleccionado.
  static const String keySelectedVehicle = '${keyPrefix}selected_vehicle';

  /// Clave del coche seleccionado (nombre historico).
  static const String keySelectedCar = keySelectedVehicle;

  /// Clave de la calca del vehiculo.
  static const String keySelectedDecal = '${keyPrefix}selected_decal';

  /// Clave del color de la calca.
  static const String keySelectedDecalColor =
      '${keyPrefix}selected_decal_color';

  /// Clave del personaje del vehiculo.
  static const String keySelectedCharacter =
      '${keyPrefix}selected_character';

  /// Clave de los mejores tiempos por nivel.
  static const String keyBestTimes = '${keyPrefix}best_times';

  /// Clave de la pista seleccionada.
  static const String keySelectedTrack = '${keyPrefix}selected_track';

  /// Clave de la lamina seleccionada.
  static const String keySelectedPage = '${keyPrefix}selected_page';

  /// Clave del nivel de carreras seleccionado.
  static const String keySelectedLevel = '${keyPrefix}selected_level';

  /// Clave de las vueltas completadas.
  static const String keyBestLaps = '${keyPrefix}best_laps';

  /// Prefijo de las claves de dibujo.
  static const String drawingPrefix = 'drawing_page_';

  final SharedPreferences _prefs;
  Timer? _saveTimer;
  Progress? _pending;

  /// Lee el progreso guardado.
  Progress load() {
    return Progress(
      totalStars: _prefs.getInt(keyTotalStars) ?? 0,
      sessionStars: _prefs.getInt(keySessionStars) ?? 0,
      unlockedStickers: _prefs.getStringList(keyStickers)?.toSet() ?? {},
      unlockedColors: _prefs.getStringList(keyColors)?.toSet() ?? {},
      unlockedCars: _prefs.getStringList(keyCars)?.toSet() ?? {},
      unlockedPages: _prefs.getStringList(keyPages)?.toSet() ?? {},
      completedLevels:
          _prefs.getStringList(keyCompletedLevels)?.toSet() ?? {},
      bestTimes: _readBestTimes(),
      selectedVehicle: _prefs.getString(keySelectedVehicle) ?? 'rojo',
      selectedDecal: _prefs.getString(keySelectedDecal) ?? 'rayas',
      selectedDecalColor:
          _prefs.getInt(keySelectedDecalColor) ?? 0xFFFF4757,
      selectedCharacter: _prefs.getString(keySelectedCharacter) ?? 'gato',
      selectedTrack: _prefs.getString(keySelectedTrack) ?? 'pradera',
      selectedPage: _prefs.getString(keySelectedPage) ?? 'coche',
      selectedLevel: _prefs.getString(keySelectedLevel) ?? 'nivel_01',
      bestLaps: _prefs.getInt(keyBestLaps) ?? 0,
    );
  }

  Map<String, int> _readBestTimes() {
    final raw = _prefs.getString(keyBestTimes);
    if (raw == null || raw.isEmpty) {
      return const {};
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final times = <String, int>{};
      decoded.forEach((key, value) {
        if (value is num) {
          times[key] = value.toInt();
        }
      });
      return times;
    } catch (error) {
      debugPrint('[Pincel] No se pudieron leer los records: $error');
      return const {};
    }
  }

  /// Guarda el progreso de forma **debounced** (500 ms).
  ///
  /// Se agrupan varias llamadas seguidas en una sola escritura.
  void save(Progress progress) {
    _pending = progress;
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: 500),
      () => unawaited(_write(progress)),
    );
  }

  /// Fuerza la escritura inmediata del progreso pendiente.
  Future<void> flush() async {
    _saveTimer?.cancel();
    final pending = _pending;
    if (pending != null) {
      await _write(pending);
    }
  }

  Future<void> _write(Progress progress) async {
    await _prefs.setInt(keyTotalStars, progress.totalStars);
    await _prefs.setInt(keySessionStars, progress.sessionStars);
    await _prefs.setStringList(
      keyStickers,
      progress.unlockedStickers.toList()..sort(),
    );
    await _prefs.setStringList(
      keyColors,
      progress.unlockedColors.toList()..sort(),
    );
    await _prefs.setStringList(
      keyCars,
      progress.unlockedCars.toList()..sort(),
    );
    await _prefs.setStringList(
      keyPages,
      progress.unlockedPages.toList()..sort(),
    );
    await _prefs.setStringList(
      keyCompletedLevels,
      progress.completedLevels.toList()..sort(),
    );
    await _prefs.setString(
      keySelectedVehicle,
      progress.selectedVehicle,
    );
    await _prefs.setString(keySelectedDecal, progress.selectedDecal);
    await _prefs.setInt(
      keySelectedDecalColor,
      progress.selectedDecalColor,
    );
    await _prefs.setString(
      keySelectedCharacter,
      progress.selectedCharacter,
    );
    await _prefs.setString(keySelectedTrack, progress.selectedTrack);
    await _prefs.setString(keySelectedPage, progress.selectedPage);
    await _prefs.setString(keySelectedLevel, progress.selectedLevel);
    await _prefs.setInt(keyBestLaps, progress.bestLaps);
    await _prefs.setString(keyBestTimes, jsonEncode(progress.bestTimes));
  }

  /// Carga el dibujo guardado de una lamina.
  Painting loadDrawing(String pageId) {
    final raw = _prefs.getString('$drawingPrefix$pageId');
    if (raw == null || raw.isEmpty) {
      return const Painting();
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return Painting.fromJson(decoded);
    } catch (error) {
      debugPrint('[Pincel] No se pudo leer el dibujo: $error');
      return const Painting();
    }
  }

  /// Guarda el dibujo de una lamina.
  Future<void> saveDrawing(String pageId, Painting painting) async {
    final payload = jsonEncode(painting.toJson());
    await _prefs.setString('$drawingPrefix$pageId', payload);
  }

  /// Borra el dibujo guardado de una lamina.
  Future<void> clearDrawing(String pageId) async {
    await _prefs.remove('$drawingPrefix$pageId');
  }
}
