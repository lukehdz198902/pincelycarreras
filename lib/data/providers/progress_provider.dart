import 'package:flutter/foundation.dart';

import '../models/game_content.dart';
import '../models/level_catalog.dart';
import '../models/level_spec.dart';
import '../models/progress.dart';
import '../services/progress_service.dart';

/// Tipo de recompensa desbloqueada.
enum UnlockKind {
  /// Pegatina del libro de recompensas.
  sticker,

  /// Color extra del pincel.
  color,

  /// Coche extra.
  car,

  /// Lamina extra para colorear.
  page,
}

/// Evento de desbloqueo pendiente de mostrar en la interfaz.
@immutable
class UnlockEvent {
  /// Crea un evento de desbloqueo.
  const UnlockEvent({
    required this.kind,
    required this.id,
    required this.name,
    required this.assetPath,
  });

  /// Tipo de recompensa.
  final UnlockKind kind;

  /// Identificador del recurso.
  final String id;

  /// Nombre legible del recurso.
  final String name;

  /// Ruta del sprite con el que se muestra la recompensa.
  final String assetPath;
}

/// Estado global del progreso del nino.
///
/// Notifica a la interfaz con `notifyListeners()`. El progreso es
/// **aditivo**: las estrellas solo suman y nunca se pierden.
class ProgressProvider extends ChangeNotifier {
  /// Crea el proveedor sobre un servicio de persistencia.
  ProgressProvider(this._service);

  final ProgressService _service;
  Progress _progress = const Progress();
  final List<UnlockEvent> _pendingUnlocks = [];

  /// Progreso actual.
  Progress get progress => _progress;

  /// Total de estrellas acumuladas.
  int get totalStars => _progress.totalStars;

  /// Estrellas de la sesion actual.
  int get sessionStars => _progress.sessionStars;

  /// Vueltas completadas.
  int get bestLaps => _progress.bestLaps;

  /// Niveles completados.
  int get completedLevelCount => _progress.completedLevels.length;

  /// Numero total de niveles.
  int get totalLevelCount => LevelCatalog.levels.length;

  /// Nivel seleccionado actualmente.
  LevelSpec get selectedLevel =>
      LevelCatalog.byId(_progress.selectedLevel) ?? LevelCatalog.first;

  /// `true` si el nivel ya se ha superado alguna vez.
  bool isLevelCompleted(String id) =>
      _progress.completedLevels.contains(id);

  /// `true` si el nivel se puede jugar.
  ///
  /// El primero siempre esta abierto y cada nivel se abre al completar el
  /// anterior. Un nivel completado sigue abierto para repetirlo.
  bool isLevelUnlocked(String id) {
    final index = LevelCatalog.indexOf(id);
    if (index < 0) {
      return false;
    }
    if (index == 0 || isLevelCompleted(id)) {
      return true;
    }
    final previous = LevelCatalog.levels[index - 1];
    return isLevelCompleted(previous.id);
  }

  /// Marca un nivel como superado y avanza la seleccion.
  ///
  /// Devuelve `true` solo la primera vez que se completa; asi la pantalla
  /// de carreras puede celebrar sin interrumpir las repeticiones.
  bool completeLevel(String id) {
    if (!isLevelUnlocked(id) || isLevelCompleted(id)) {
      return false;
    }
    final levels = Set<String>.from(_progress.completedLevels)..add(id);
    final next = LevelCatalog.nextAfter(id);
    _progress = _progress.copyWith(
      completedLevels: levels,
      selectedLevel: next?.id ?? id,
    );
    _service.save(_progress);
    notifyListeners();
    return true;
  }

  /// Selecciona un nivel desbloqueado en el mapa.
  void selectLevel(String id) {
    if (_progress.selectedLevel == id || !isLevelUnlocked(id)) {
      return;
    }
    _progress = _progress.copyWith(selectedLevel: id);
    _service.save(_progress);
    notifyListeners();
  }

  /// Carga el progreso guardado y notifica a la interfaz.
  void load() {
    _progress = _service.load();
    notifyListeners();
  }

  /// Anade estrellas y comprueba si desbloquea alguna recompensa.
  void addStars(int amount) {
    if (amount <= 0) {
      return;
    }
    var updated = _progress.copyWith(
      totalStars: _progress.totalStars + amount,
      sessionStars: _progress.sessionStars + amount,
    );
    updated = _applyUnlocks(updated);
    _progress = updated;
    _service.save(_progress);
    notifyListeners();
  }

  /// Registra una vuelta completada.
  void completeLap() {
    _progress = _progress.copyWith(bestLaps: _progress.bestLaps + 1);
    _service.save(_progress);
    notifyListeners();
  }

  /// Reinicia el contador de estrellas de la sesion.
  void resetSessionStars() {
    _progress = _progress.copyWith(sessionStars: 0);
    _service.save(_progress);
    notifyListeners();
  }

  /// Selecciona el vehiculo activo.
  void selectVehicle(String id) {
    if (_progress.selectedVehicle == id || !isVehicleUnlocked(id)) {
      return;
    }
    _progress = _progress.copyWith(selectedVehicle: id);
    _service.save(_progress);
    notifyListeners();
  }

  /// Selecciona la calca pintada en la carroceria.
  void selectDecal(String id) {
    if (_progress.selectedDecal == id) {
      return;
    }
    _progress = _progress.copyWith(selectedDecal: id);
    _service.save(_progress);
    notifyListeners();
  }

  /// Selecciona el color de la calca.
  void selectDecalColor(int colorValue) {
    if (_progress.selectedDecalColor == colorValue) {
      return;
    }
    _progress = _progress.copyWith(selectedDecalColor: colorValue);
    _service.save(_progress);
    notifyListeners();
  }

  /// Selecciona el personaje que viaja con el nino.
  void selectCharacter(String id) {
    if (_progress.selectedCharacter == id) {
      return;
    }
    _progress = _progress.copyWith(selectedCharacter: id);
    _service.save(_progress);
    notifyListeners();
  }

  /// Selecciona la lamina activa del estudio de pintura.
  void selectPage(String id) {
    if (_progress.selectedPage == id || !isPageUnlocked(id)) {
      return;
    }
    _progress = _progress.copyWith(selectedPage: id);
    _service.save(_progress);
    notifyListeners();
  }

  /// `true` si el vehiculo esta disponible.
  bool isVehicleUnlocked(String id) {
    final vehicle = GameContent.vehicleById(id);
    if (vehicle == null) {
      return false;
    }
    return vehicle.isFree ||
        _progress.totalStars >= vehicle.unlockStars ||
        _progress.unlockedCars.contains(id);
  }

  /// Mejor tiempo del nivel en segundos (0 si nunca se ha superado).
  int bestTimeFor(String levelId) => _progress.bestTimes[levelId] ?? 0;

  /// Guarda el mejor tiempo de un nivel.
  ///
  /// Solo se guarda si es mejor que el anterior: el record del nino nunca
  /// empeora.
  void recordBestTime(String levelId, int seconds) {
    if (seconds <= 0) {
      return;
    }
    final current = _progress.bestTimes[levelId] ?? 0;
    if (current != 0 && current <= seconds) {
      return;
    }
    final times = Map<String, int>.from(_progress.bestTimes)
      ..[levelId] = seconds;
    _progress = _progress.copyWith(bestTimes: times);
    _service.save(_progress);
    notifyListeners();
  }

  /// `true` si la lamina esta disponible.
  bool isPageUnlocked(String id) {
    final page = GameContent.pageById(id);
    if (page == null) {
      return false;
    }
    return page.isFree ||
        _progress.totalStars >= page.unlockStars ||
        _progress.unlockedPages.contains(id);
  }

  /// `true` si el color esta disponible.
  bool isColorUnlocked(String id) {
    final color = GameContent.colorById(id);
    if (color == null) {
      return false;
    }
    return color.unlockStars == 0 ||
        _progress.totalStars >= color.unlockStars ||
        _progress.unlockedColors.contains(id);
  }

  /// `true` si la pegatina esta desbloqueada.
  bool isStickerUnlocked(String id) {
    final sticker = GameContent.stickerById(id);
    if (sticker == null) {
      return false;
    }
    return sticker.unlockStars == 0 ||
        _progress.totalStars >= sticker.unlockStars ||
        _progress.unlockedStickers.contains(id);
  }

  /// Devuelve y limpia los desbloqueos pendientes de mostrar.
  List<UnlockEvent> takePendingUnlocks() {
    if (_pendingUnlocks.isEmpty) {
      return const [];
    }
    final events = List<UnlockEvent>.from(_pendingUnlocks);
    _pendingUnlocks.clear();
    return events;
  }

  Progress _applyUnlocks(Progress updated) {
    var result = updated;
    final stickers = Set<String>.from(result.unlockedStickers);
    final colors = Set<String>.from(result.unlockedColors);
    final cars = Set<String>.from(result.unlockedCars);
    final pages = Set<String>.from(result.unlockedPages);

    for (final sticker in GameContent.stickers) {
      if (sticker.unlockStars == 0 ||
          sticker.unlockStars > result.totalStars ||
          stickers.contains(sticker.id)) {
        continue;
      }
      stickers.add(sticker.id);
      _pendingUnlocks.add(
        UnlockEvent(
          kind: UnlockKind.sticker,
          id: sticker.id,
          name: sticker.name,
          assetPath: sticker.assetPath,
        ),
      );
    }

    for (final color in GameContent.lockedColors) {
      if (color.unlockStars > result.totalStars || colors.contains(color.id)) {
        continue;
      }
      colors.add(color.id);
      _pendingUnlocks.add(
        UnlockEvent(
          kind: UnlockKind.color,
          id: color.id,
          name: color.id,
          assetPath: '',
        ),
      );
    }

    for (final vehicle in GameContent.vehicles) {
      if (vehicle.unlockStars == 0 ||
          vehicle.unlockStars > result.totalStars ||
          cars.contains(vehicle.id)) {
        continue;
      }
      cars.add(vehicle.id);
      _pendingUnlocks.add(
        UnlockEvent(
          kind: UnlockKind.car,
          id: vehicle.id,
          name: vehicle.name,
          assetPath: vehicle.assetPath,
        ),
      );
    }

    for (final page in GameContent.pages) {
      if (page.unlockStars == 0 ||
          page.unlockStars > result.totalStars ||
          pages.contains(page.id)) {
        continue;
      }
      pages.add(page.id);
      _pendingUnlocks.add(
        UnlockEvent(
          kind: UnlockKind.page,
          id: page.id,
          name: page.name,
          assetPath: page.assetPath,
        ),
      );
    }

    return result.copyWith(
      unlockedStickers: stickers,
      unlockedColors: colors,
      unlockedCars: cars,
      unlockedPages: pages,
    );
  }
}
