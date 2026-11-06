import 'package:flutter/foundation.dart';

/// Progreso del nino: estrellas, desbloqueos y seleccion actual.
///
/// El modelo es **inmutable**: toda mutacion devuelve una copia nueva.
@immutable
class Progress {
  /// Crea un progreso vacio o con los valores indicados.
  const Progress({
    this.totalStars = 0,
    this.sessionStars = 0,
    this.unlockedStickers = const {},
    this.unlockedColors = const {},
    this.unlockedCars = const {},
    this.unlockedPages = const {},
    this.completedLevels = const {},
    this.bestTimes = const {},
    this.selectedVehicle = 'rojo',
    this.selectedDecal = 'rayas',
    this.selectedDecalColor = 0xFFFF4757,
    this.selectedCharacter = 'gato',
    this.selectedTrack = 'pradera',
    this.selectedPage = 'coche',
    this.selectedLevel = 'nivel_01',
    this.bestLaps = 0,
  });

  /// Estrellas acumuladas (nunca se pierden).
  final int totalStars;

  /// Estrellas ganadas en la sesion actual.
  final int sessionStars;

  /// Identificadores de las pegatinas desbloqueadas.
  final Set<String> unlockedStickers;

  /// Identificadores de los colores desbloqueados.
  final Set<String> unlockedColors;

  /// Identificadores de los coches desbloqueados.
  final Set<String> unlockedCars;

  /// Identificadores de las laminas desbloqueadas.
  final Set<String> unlockedPages;

  /// Identificadores de los niveles completados.
  final Set<String> completedLevels;

  /// Mejor tiempo (en segundos) de cada nivel completado.
  final Map<String, int> bestTimes;

  /// Vehiculo seleccionado.
  final String selectedVehicle;

  /// Calca pintada en la carrocería.
  final String selectedDecal;

  /// Color de la calca (ARGB).
  final int selectedDecalColor;

  /// Personaje que viaja con el nino.
  final String selectedCharacter;

  /// Pista seleccionada.
  final String selectedTrack;

  /// Lamina seleccionada en el estudio de pintura.
  final String selectedPage;

  /// Nivel de carreras seleccionado en el mapa.
  final String selectedLevel;

  /// Vueltas completadas (informativo, nunca punitivo).
  final int bestLaps;

  /// Devuelve una copia con los campos indicados modificados.
  Progress copyWith({
    int? totalStars,
    int? sessionStars,
    Set<String>? unlockedStickers,
    Set<String>? unlockedColors,
    Set<String>? unlockedCars,
    Set<String>? unlockedPages,
    Set<String>? completedLevels,
    Map<String, int>? bestTimes,
    String? selectedVehicle,
    String? selectedDecal,
    int? selectedDecalColor,
    String? selectedCharacter,
    String? selectedTrack,
    String? selectedPage,
    String? selectedLevel,
    int? bestLaps,
  }) {
    return Progress(
      totalStars: totalStars ?? this.totalStars,
      sessionStars: sessionStars ?? this.sessionStars,
      unlockedStickers: unlockedStickers ?? this.unlockedStickers,
      unlockedColors: unlockedColors ?? this.unlockedColors,
      unlockedCars: unlockedCars ?? this.unlockedCars,
      unlockedPages: unlockedPages ?? this.unlockedPages,
      completedLevels: completedLevels ?? this.completedLevels,
      bestTimes: bestTimes ?? this.bestTimes,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      selectedDecal: selectedDecal ?? this.selectedDecal,
      selectedDecalColor: selectedDecalColor ?? this.selectedDecalColor,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      selectedTrack: selectedTrack ?? this.selectedTrack,
      selectedPage: selectedPage ?? this.selectedPage,
      selectedLevel: selectedLevel ?? this.selectedLevel,
      bestLaps: bestLaps ?? this.bestLaps,
    );
  }

  /// Serializa a JSON para `shared_preferences`.
  Map<String, dynamic> toJson() => {
    'totalStars': totalStars,
    'sessionStars': sessionStars,
    'unlockedStickers': unlockedStickers.toList()..sort(),
    'unlockedColors': unlockedColors.toList()..sort(),
    'unlockedCars': unlockedCars.toList()..sort(),
    'unlockedPages': unlockedPages.toList()..sort(),
    'completedLevels': completedLevels.toList()..sort(),
    'bestTimes': bestTimes,
    'selectedVehicle': selectedVehicle,
    'selectedDecal': selectedDecal,
    'selectedDecalColor': selectedDecalColor,
    'selectedCharacter': selectedCharacter,
    'selectedTrack': selectedTrack,
    'selectedPage': selectedPage,
    'selectedLevel': selectedLevel,
    'bestLaps': bestLaps,
  };

  /// Reconstruye el progreso desde JSON.
  factory Progress.fromJson(Map<String, dynamic> json) {
    Set<String> readSet(String key) {
      final raw = json[key];
      if (raw is! List) {
        return <String>{};
      }
      return raw.whereType<String>().toSet();
    }

    Map<String, int> readTimes() {
      final raw = json['bestTimes'];
      if (raw is! Map) {
        return const {};
      }
      final times = <String, int>{};
      raw.forEach((key, value) {
        if (key is String && value is num) {
          times[key] = value.toInt();
        }
      });
      return times;
    }

    return Progress(
      totalStars: (json['totalStars'] as num?)?.toInt() ?? 0,
      sessionStars: (json['sessionStars'] as num?)?.toInt() ?? 0,
      unlockedStickers: readSet('unlockedStickers'),
      unlockedColors: readSet('unlockedColors'),
      unlockedCars: readSet('unlockedCars'),
      unlockedPages: readSet('unlockedPages'),
      completedLevels: readSet('completedLevels'),
      bestTimes: readTimes(),
      selectedVehicle: json['selectedVehicle'] as String? ?? 'rojo',
      selectedDecal: json['selectedDecal'] as String? ?? 'rayas',
      selectedDecalColor:
          (json['selectedDecalColor'] as num?)?.toInt() ?? 0xFFFF4757,
      selectedCharacter: json['selectedCharacter'] as String? ?? 'gato',
      selectedTrack: json['selectedTrack'] as String? ?? 'pradera',
      selectedPage: json['selectedPage'] as String? ?? 'coche',
      selectedLevel: json['selectedLevel'] as String? ?? 'nivel_01',
      bestLaps: (json['bestLaps'] as num?)?.toInt() ?? 0,
    );
  }
}
