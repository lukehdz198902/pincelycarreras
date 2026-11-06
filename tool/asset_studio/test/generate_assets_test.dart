// Genera todos los assets graficos del juego "Pincel & Carreras".
//
// Uso:
//   cd tool/asset_studio
//   flutter test
//
// La salida se escribe en <raiz del proyecto>/assets/images/.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_studio/backgrounds.dart';
import 'package:asset_studio/customization.dart';
import 'package:asset_studio/pages.dart';
import 'package:asset_studio/pages_market.dart';
import 'package:asset_studio/sprites.dart';
import 'package:asset_studio/studio.dart';
import 'package:asset_studio/vehicles.dart';

/// Asset a generar: ruta relativa + tamano + funcion de dibujo.
typedef AssetDef = ({
  String path,
  ui.Size size,
  void Function(Canvas canvas) draw,
});

void main() {
  final root = resolveProjectRoot();
  final imagesDir = Directory('${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}images');

  Future<void> generate(List<AssetDef> assets) async {
    for (final asset in assets) {
      final target = File('${imagesDir.path}${Platform.pathSeparator}${asset.path}');
      await writePng(target.path, asset.size, asset.draw);
    }
  }

  test('genera los 5 coches', () async {
    const cars = {
      'car_rojo.png': StudioPalette.red,
      'car_azul.png': StudioPalette.blue,
      'car_amarillo.png': StudioPalette.yellow,
      'car_verde.png': StudioPalette.green,
      'car_violeta.png': StudioPalette.violet,
    };
    await generate([
      for (final entry in cars.entries)
        (
          path: 'cars/${entry.key}',
          size: const ui.Size(160, 240),
          draw: (canvas) => drawCar(canvas, const ui.Size(160, 240), entry.value),
        ),
    ]);
  });

  test('genera los vehiculos: moto, camion, furgoneta, tractor y bus',
      () async {
    await generate([
      (
        path: 'cars/moto.png',
        size: const ui.Size(110, 220),
        draw: (canvas) =>
            drawMoto(canvas, const ui.Size(110, 220), StudioPalette.yellow),
      ),
      (
        path: 'cars/camion.png',
        size: const ui.Size(180, 320),
        draw: (canvas) =>
            drawTruck(canvas, const ui.Size(180, 320), StudioPalette.red),
      ),
      (
        path: 'cars/furgoneta.png',
        size: const ui.Size(175, 280),
        draw: (canvas) => drawVan(
          canvas,
          const ui.Size(175, 280),
          StudioPalette.violet,
        ),
      ),
      (
        path: 'cars/tractor.png',
        size: const ui.Size(170, 210),
        draw: (canvas) => drawTractor(
          canvas,
          const ui.Size(170, 210),
          StudioPalette.orange,
        ),
      ),
      (
        path: 'cars/bus.png',
        size: const ui.Size(190, 340),
        draw: (canvas) =>
            drawBus(canvas, const ui.Size(190, 340), StudioPalette.yellow),
      ),
      (
        path: 'cars/coche_lateral.png',
        size: const ui.Size(480, 280),
        draw: (canvas) => drawSideCarBody(
          canvas,
          const ui.Size(480, 280),
          StudioPalette.red,
        ),
      ),
      (
        path: 'cars/rueda.png',
        size: const ui.Size(144, 144),
        draw: (canvas) => drawSideWheel(canvas, const ui.Size(144, 144)),
      ),
    ]);
  });

  test('genera las pistas y el mobiliario', () async {
    await generate([
      (
        path: 'tracks/track_pradera.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawGrass(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_playa.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawSand(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_noche.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawNight(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_nieve.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawSnow(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_bosque.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawForest(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_ciudad.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawCity(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_desierto.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawDesert(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_selva.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawJungle(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_puerto.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawHarbor(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_volcan.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawVolcano(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_espacio.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawSpace(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/track_estadio.png',
        size: const ui.Size(256, 256),
        draw: (canvas) => drawStadium(canvas, const ui.Size(256, 256)),
      ),
      (
        path: 'tracks/asfalto.png',
        size: const ui.Size(384, 384),
        draw: (canvas) => drawAsphalt(canvas, const ui.Size(384, 384)),
      ),
      (
        path: 'tracks/asfalto_tierra.png',
        size: const ui.Size(384, 384),
        draw: (canvas) => drawDirtAsphalt(canvas, const ui.Size(384, 384)),
      ),
      (
        path: 'tracks/asfalto_piedra.png',
        size: const ui.Size(384, 384),
        draw: (canvas) => drawStoneAsphalt(canvas, const ui.Size(384, 384)),
      ),
      (
        path: 'tracks/asfalto_hielo.png',
        size: const ui.Size(384, 384),
        draw: (canvas) => drawIceAsphalt(canvas, const ui.Size(384, 384)),
      ),
      (
        path: 'tracks/bordillo.png',
        size: const ui.Size(40, 80),
        draw: (canvas) => drawCurb(canvas, const ui.Size(40, 80)),
      ),
      (
        path: 'tracks/bordillo_amarillo.png',
        size: const ui.Size(40, 80),
        draw: (canvas) => drawYellowCurb(canvas, const ui.Size(40, 80)),
      ),
      (
        path: 'tracks/bordillo_piedra.png',
        size: const ui.Size(40, 80),
        draw: (canvas) => drawStoneCurb(canvas, const ui.Size(40, 80)),
      ),
      (
        path: 'tracks/bordillo_hielo.png',
        size: const ui.Size(40, 80),
        draw: (canvas) => drawIceCurb(canvas, const ui.Size(40, 80)),
      ),
      (
        path: 'tracks/cono.png',
        size: const ui.Size(96, 96),
        draw: (canvas) => drawCone(canvas, const ui.Size(96, 96)),
      ),
      (
        path: 'tracks/charco.png',
        size: const ui.Size(112, 88),
        draw: (canvas) => drawPuddle(canvas, const ui.Size(112, 88)),
      ),
      (
        path: 'tracks/roca.png',
        size: const ui.Size(96, 96),
        draw: (canvas) => drawRock(canvas, const ui.Size(96, 96)),
      ),
      (
        path: 'tracks/meta.png',
        size: const ui.Size(192, 80),
        draw: (canvas) => drawFinishBanner(canvas, const ui.Size(192, 80)),
      ),
      (
        path: 'tracks/banderin.png',
        size: const ui.Size(96, 60),
        draw: (canvas) => drawLapBanner(canvas, const ui.Size(96, 60)),
      ),
    ]);
  });

  test('genera la estrella coleccionable', () async {
    await generate([
      (
        path: 'items/estrella.png',
        size: const ui.Size(96, 96),
        draw: (canvas) => drawStar(canvas, const ui.Size(96, 96)),
      ),
    ]);
  });

  test('genera las calcas y los personajes del vehiculo', () async {
    await generate([
      (
        path: 'decals/calca_rayas.png',
        size: const ui.Size(128, 128),
        draw: (canvas) =>
            drawDecalStripes(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'decals/calca_estrella.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawDecalStar(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'decals/calca_llama.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawDecalFlame(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'decals/calca_corazon.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawDecalHeart(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'decals/calca_numero.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawRacingNumber(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'characters/personaje_gato.png',
        size: const ui.Size(128, 128),
        draw: (canvas) =>
            drawCharacterCat(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'characters/personaje_perro.png',
        size: const ui.Size(128, 128),
        draw: (canvas) =>
            drawCharacterDog(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'characters/personaje_conejo.png',
        size: const ui.Size(128, 128),
        draw: (canvas) =>
            drawCharacterRabbit(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'characters/personaje_robot.png',
        size: const ui.Size(128, 128),
        draw: (canvas) =>
            drawCharacterRobot(canvas, const ui.Size(128, 128)),
      ),
    ]);
  });

  test('genera los iconos de interfaz', () async {
    await generate([
      (
        path: 'ui/icono_pincel.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawBrushIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_coche.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawCarIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_play.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawPlayIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_pausa.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawPauseIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_atras.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawBackIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_libro.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawBookIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_bote.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawBucketIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_borrador.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawEraserIcon(canvas, const ui.Size(128, 128)),
      ),
      (
        path: 'ui/icono_estrella.png',
        size: const ui.Size(128, 128),
        draw: (canvas) => drawStarIcon(canvas, const ui.Size(128, 128)),
      ),
    ]);
  });

  test('genera las pegatinas', () async {
    await generate([
      (
        path: 'stickers/pega_estrella.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerStar(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_corazon.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerHeart(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_arcoiris.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerRainbow(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_corona.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerCrown(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_flecha.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerArrow(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_globo.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerBalloon(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_trofeo.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerTrophy(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_medalla.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerMedal(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_cohete.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerRocket(canvas, const ui.Size(160, 160)),
      ),
      (
        path: 'stickers/pega_cometa.png',
        size: const ui.Size(160, 160),
        draw: (canvas) => drawStickerComet(canvas, const ui.Size(160, 160)),
      ),
    ]);
  });

  test('genera las laminas para colorear', () async {
    await generate([
      (
        path: 'canvas/pagina_coche.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageCar(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_paisaje.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageLandscape(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_animales.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageAnimals(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_casa.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageHouse(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_dinosaurio.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageDinosaur(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_ciudad.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageCity(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_frutas.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageFruits(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_verduras.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageVerduras(canvas, const ui.Size(1024, 768)),
      ),
      (
        path: 'canvas/pagina_garaje.png',
        size: const ui.Size(1024, 768),
        draw: (canvas) => drawPageGarage(canvas, const ui.Size(1024, 768)),
      ),
    ]);
  });

  test('genera la hoja de paleta', () async {
    await generate([
      (
        path: 'palette/paleta.png',
        size: const ui.Size(960, 320),
        draw: (canvas) => drawPaletteSheet(canvas, const ui.Size(960, 320)),
      ),
    ]);
  });
}
