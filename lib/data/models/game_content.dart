import 'color_spec.dart';
import 'page_spec.dart';
import 'sticker.dart';
import 'track_spec.dart';
import 'vehicle_spec.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/palette.dart';

/// Catalogo de todo el contenido desbloqueable del juego.
///
/// Los identificadores son **estables**: se guardan en
/// `shared_preferences`, por lo que no deben renombrarse nunca.
class GameContent {
  const GameContent._();

  /// Colores siempre disponibles (12 tonos vivos y contrastados).
  static const List<ColorSpec> baseColors = [
    ColorSpec(id: 'rojo', color: AppPalette.red),
    ColorSpec(id: 'naranja', color: AppPalette.orange),
    ColorSpec(id: 'amarillo', color: AppPalette.yellow),
    ColorSpec(id: 'verde', color: AppPalette.green),
    ColorSpec(id: 'lime', color: AppPalette.lime),
    ColorSpec(id: 'turquesa', color: AppPalette.cyan),
    ColorSpec(id: 'azul', color: AppPalette.blue),
    ColorSpec(id: 'violeta', color: AppPalette.violet),
    ColorSpec(id: 'rosa', color: AppPalette.pink),
    ColorSpec(id: 'marron', color: AppPalette.brown),
    ColorSpec(id: 'negro', color: AppPalette.ink),
    ColorSpec(id: 'blanco', color: AppPalette.white),
  ];

  /// Colores que se desbloquean con estrellas.
  static const List<ColorSpec> lockedColors = [
    ColorSpec(id: 'bronce', color: AppPalette.bronze, unlockStars: 10),
    ColorSpec(id: 'esmeralda', color: AppPalette.emerald, unlockStars: 15),
    ColorSpec(id: 'dorado', color: AppPalette.gold, unlockStars: 20),
    ColorSpec(id: 'plata', color: AppPalette.silver, unlockStars: 30),
  ];

  /// Todos los colores, base primero.
  static List<ColorSpec> get allColors => [...baseColors, ...lockedColors];

  /// Vehiculos disponibles: coches, moto, camion, bus, tractor y furgoneta.
  static const List<VehicleSpec> vehicles = [
    VehicleSpec(
      id: 'rojo',
      name: 'Furioso',
      type: VehicleType.car,
      assetPath: AssetPaths.carRojo,
      color: AppPalette.red,
    ),
    VehicleSpec(
      id: 'azul',
      name: 'Rayo',
      type: VehicleType.car,
      assetPath: AssetPaths.carAzul,
      color: AppPalette.blue,
    ),
    VehicleSpec(
      id: 'verde',
      name: 'Tortuga',
      type: VehicleType.car,
      assetPath: AssetPaths.carVerde,
      color: AppPalette.green,
      unlockStars: 5,
    ),
    VehicleSpec(
      id: 'amarillo',
      name: 'Sol',
      type: VehicleType.car,
      assetPath: AssetPaths.carAmarillo,
      color: AppPalette.yellow,
      unlockStars: 10,
    ),
    VehicleSpec(
      id: 'moto',
      name: 'Chispa',
      type: VehicleType.moto,
      assetPath: AssetPaths.moto,
      color: AppPalette.yellow,
      unlockStars: 14,
      widthFactor: 0.55,
      heightFactor: 0.72,
    ),
    VehicleSpec(
      id: 'camion',
      name: 'Camión',
      type: VehicleType.truck,
      assetPath: AssetPaths.camion,
      color: AppPalette.red,
      unlockStars: 18,
      widthFactor: 1.1,
      heightFactor: 1.29,
    ),
    VehicleSpec(
      id: 'policia',
      name: 'Policía',
      type: VehicleType.car,
      assetPath: AssetPaths.policia,
      color: AppPalette.blue,
      unlockStars: 22,
    ),
    VehicleSpec(
      id: 'furgoneta',
      name: 'Furgoneta',
      type: VehicleType.van,
      assetPath: AssetPaths.furgoneta,
      color: AppPalette.violet,
      unlockStars: 26,
      widthFactor: 1.1,
      heightFactor: 1.16,
    ),
    VehicleSpec(
      id: 'ambulancia',
      name: 'Ambulancia',
      type: VehicleType.van,
      assetPath: AssetPaths.ambulancia,
      color: AppPalette.white,
      unlockStars: 30,
      widthFactor: 1.15,
      heightFactor: 1.2,
    ),
    VehicleSpec(
      id: 'tractor',
      name: 'Tractor',
      type: VehicleType.tractor,
      assetPath: AssetPaths.tractor,
      color: AppPalette.orange,
      unlockStars: 34,
      widthFactor: 1.05,
      heightFactor: 0.85,
    ),
    VehicleSpec(
      id: 'bus',
      name: 'Bus escolar',
      type: VehicleType.bus,
      assetPath: AssetPaths.bus,
      color: AppPalette.yellow,
      unlockStars: 38,
      widthFactor: 1.2,
      heightFactor: 1.41,
    ),
    VehicleSpec(
      id: 'violeta',
      name: 'Cohete',
      type: VehicleType.car,
      assetPath: AssetPaths.carVioleta,
      color: AppPalette.violet,
      unlockStars: 42,
    ),
  ];

  /// Pistas (mundos) disponibles.
  ///
  /// Cada mundo tiene su propio asfalto y bordillo: las pistas **no** son
  /// todas iguales aunque el juego use el mismo motor.
  static const List<TrackSpec> tracks = [
    TrackSpec(
      id: 'pradera',
      name: 'Pradera',
      assetPath: AssetPaths.trackPradera,
    ),
    TrackSpec(
      id: 'playa',
      name: 'Playa',
      assetPath: AssetPaths.trackPlaya,
      asphaltAssetPath: AssetPaths.asphaltDirt,
      curbAssetPath: AssetPaths.curbYellow,
    ),
    TrackSpec(
      id: 'noche',
      name: 'Noche',
      assetPath: AssetPaths.trackNoche,
    ),
    TrackSpec(
      id: 'nieve',
      name: 'Nieve',
      assetPath: AssetPaths.trackNieve,
      asphaltAssetPath: AssetPaths.asphaltIce,
      curbAssetPath: AssetPaths.curbIce,
    ),
    TrackSpec(
      id: 'bosque',
      name: 'Bosque',
      assetPath: AssetPaths.trackBosque,
      asphaltAssetPath: AssetPaths.asphaltStone,
      curbAssetPath: AssetPaths.curbStone,
    ),
    TrackSpec(
      id: 'ciudad',
      name: 'Ciudad',
      assetPath: AssetPaths.trackCiudad,
    ),
    TrackSpec(
      id: 'desierto',
      name: 'Desierto',
      assetPath: AssetPaths.trackDesierto,
      asphaltAssetPath: AssetPaths.asphaltDirt,
      curbAssetPath: AssetPaths.curbYellow,
    ),
    TrackSpec(
      id: 'selva',
      name: 'Selva',
      assetPath: AssetPaths.trackSelva,
      asphaltAssetPath: AssetPaths.asphaltStone,
      curbAssetPath: AssetPaths.curbStone,
    ),
    TrackSpec(
      id: 'puerto',
      name: 'Puerto',
      assetPath: AssetPaths.trackPuerto,
      asphaltAssetPath: AssetPaths.asphaltDirt,
      curbAssetPath: AssetPaths.curb,
    ),
    TrackSpec(
      id: 'volcan',
      name: 'Volcán',
      assetPath: AssetPaths.trackVolcan,
      asphaltAssetPath: AssetPaths.asphaltStone,
      curbAssetPath: AssetPaths.curbStone,
    ),
    TrackSpec(
      id: 'espacio',
      name: 'Espacio',
      assetPath: AssetPaths.trackEspacio,
      asphaltAssetPath: AssetPaths.asphaltIce,
      curbAssetPath: AssetPaths.curbIce,
    ),
    TrackSpec(
      id: 'estadio',
      name: 'Estadio',
      assetPath: AssetPaths.trackEstadio,
    ),
  ];

  /// Laminas para colorear.
  static const List<ColoringPageSpec> pages = [
    ColoringPageSpec(
      id: 'coche',
      name: 'Mi coche',
      assetPath: AssetPaths.pageCoche,
    ),
    ColoringPageSpec(
      id: 'animales',
      name: 'Animales',
      assetPath: AssetPaths.pageAnimales,
    ),
    ColoringPageSpec(
      id: 'frutas',
      name: 'Frutas',
      assetPath: AssetPaths.pageFrutas,
    ),
    ColoringPageSpec(
      id: 'verduras',
      name: 'Verduras',
      assetPath: AssetPaths.pageVerduras,
    ),
    ColoringPageSpec(
      id: 'garaje',
      name: 'El garaje',
      assetPath: AssetPaths.pageGaraje,
    ),
    ColoringPageSpec(
      id: 'paisaje',
      name: 'El paisaje',
      assetPath: AssetPaths.pagePaisaje,
    ),
    ColoringPageSpec(
      id: 'casa',
      name: 'La casa',
      assetPath: AssetPaths.pageCasa,
      unlockStars: 10,
    ),
    ColoringPageSpec(
      id: 'dinosaurio',
      name: 'El dinosaurio',
      assetPath: AssetPaths.pageDinosaurio,
      unlockStars: 20,
    ),
    ColoringPageSpec(
      id: 'ciudad',
      name: 'La ciudad',
      assetPath: AssetPaths.pageCiudad,
      unlockStars: 30,
    ),
  ];

  /// Pegatinas coleccionables.
  static const List<StickerSpec> stickers = [
    StickerSpec(
      id: 'estrella',
      name: 'Estrella',
      assetPath: AssetPaths.stickerEstrella,
      unlockStars: 5,
    ),
    StickerSpec(
      id: 'corazon',
      name: 'Corazon',
      assetPath: AssetPaths.stickerCorazon,
      unlockStars: 10,
    ),
    StickerSpec(
      id: 'flecha',
      name: 'Flecha',
      assetPath: AssetPaths.stickerFlecha,
      unlockStars: 12,
    ),
    StickerSpec(
      id: 'arcoiris',
      name: 'Arcoiris',
      assetPath: AssetPaths.stickerArcoiris,
      unlockStars: 15,
    ),
    StickerSpec(
      id: 'globo',
      name: 'Globo',
      assetPath: AssetPaths.stickerGlobo,
      unlockStars: 18,
    ),
    StickerSpec(
      id: 'corona',
      name: 'Corona',
      assetPath: AssetPaths.stickerCorona,
      unlockStars: 25,
    ),
    StickerSpec(
      id: 'trofeo',
      name: 'Trofeo',
      assetPath: AssetPaths.stickerTrofeo,
      unlockStars: 30,
    ),
    StickerSpec(
      id: 'medalla',
      name: 'Medalla',
      assetPath: AssetPaths.stickerMedalla,
      unlockStars: 35,
    ),
    StickerSpec(
      id: 'cohete',
      name: 'Cohete',
      assetPath: AssetPaths.stickerCohete,
      unlockStars: 40,
    ),
    StickerSpec(
      id: 'cometa',
      name: 'Cometa',
      assetPath: AssetPaths.stickerCometa,
      unlockStars: 45,
    ),
  ];

  /// Busca un vehiculo por identificador.
  static VehicleSpec? vehicleById(String id) {
    for (final vehicle in vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }

  /// Busca una pista por identificador.
  static TrackSpec? trackById(String id) {
    for (final track in tracks) {
      if (track.id == id) {
        return track;
      }
    }
    return null;
  }

  /// Busca una lamina por identificador.
  static ColoringPageSpec? pageById(String id) {
    for (final page in pages) {
      if (page.id == id) {
        return page;
      }
    }
    return null;
  }

  /// Busca una pegatina por identificador.
  static StickerSpec? stickerById(String id) {
    for (final sticker in stickers) {
      if (sticker.id == id) {
        return sticker;
      }
    }
    return null;
  }

  /// Busca un color por identificador.
  static ColorSpec? colorById(String id) {
    for (final color in allColors) {
      if (color.id == id) {
        return color;
      }
    }
    return null;
  }
}
