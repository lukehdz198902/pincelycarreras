// Genera los iconos de la app para Android, iOS y web.
//
// Todos los iconos salen del MISMO dibujo (tool/asset_studio/lib/app_logo.dart),
// asi que el logotipo es coherente en todas las plataformas.
//
// Uso:
//   cd tool/asset_studio
//   flutter test test/generate_app_icons_test.dart

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_studio/app_logo.dart';

/// Resuelve la raiz del proyecto "pincel_y_carreras".
Directory _projectRoot() {
  var dir = Directory.current;
  while (true) {
    final pubspec =
        File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
    if (pubspec.existsSync() &&
        pubspec.readAsStringSync().contains('name: pincel_y_carreras')) {
      return dir;
    }
    final parent = dir.parent;
    if (parent.path == dir.path) {
      throw StateError('No se encuentra el proyecto pincel_y_carreras.');
    }
    dir = parent;
  }
}

/// Escribe un PNG de [size] pixeles con el dibujo [draw].
Future<void> _writePng(
  String path,
  double size,
  void Function(Canvas canvas) draw,
) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  draw(canvas);
  final picture = recorder.endRecording();
  final image = await picture.toImage(
    size.round(),
    size.round(),
  );
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  if (data == null) {
    throw StateError('No se pudo codificar el PNG de $path');
  }
  await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
}

void main() {
  final root = _projectRoot();
  final sep = Platform.pathSeparator;

  test('genera el icono maestro y los de Android', () async {
    // Logo maestro (tambien se usa en la app).
    await _writePng(
      '${root.path}${sep}assets${sep}images${sep}ui${sep}app_logo.png',
      1024,
      (canvas) => drawAppIcon(canvas, const ui.Size(1024, 1024)),
    );

    // Iconos clasicos de Android (mipmap).
    const androidDensities = {
      'mdpi': 48.0,
      'hdpi': 72.0,
      'xhdpi': 96.0,
      'xxhdpi': 144.0,
      'xxxhdpi': 192.0,
    };
    for (final entry in androidDensities.entries) {
      final dir =
          '${root.path}${sep}android${sep}app${sep}src${sep}main${sep}res'
          '${sep}mipmap-${entry.key}';
      await _writePng(
        '$dir${sep}ic_launcher.png',
        entry.value,
        (canvas) => drawAppIcon(canvas, ui.Size(entry.value, entry.value)),
      );
      await _writePng(
        '$dir${sep}ic_launcher_round.png',
        entry.value,
        (canvas) =>
            drawAppIconRound(canvas, ui.Size(entry.value, entry.value)),
      );
    }

    // Icono adaptativo: la capa de contenido va en la zona segura (66 %).
    const adaptiveSizes = {
      'mdpi': 108.0,
      'hdpi': 162.0,
      'xhdpi': 216.0,
      'xxhdpi': 324.0,
      'xxxhdpi': 432.0,
    };
    for (final entry in adaptiveSizes.entries) {
      final dir =
          '${root.path}${sep}android${sep}app${sep}src${sep}main${sep}res'
          '${sep}mipmap-${entry.key}';
      await _writePng(
        '$dir${sep}ic_launcher_foreground.png',
        entry.value,
        (canvas) => drawAppIconForeground(
          canvas,
          ui.Size(entry.value, entry.value),
          scale: 0.62,
        ),
      );
      await _writePng(
        '$dir${sep}ic_launcher_monochrome.png',
        entry.value,
        (canvas) => drawAppIconMonochrome(
          canvas,
          ui.Size(entry.value, entry.value),
        ),
      );
    }
  });

  test('genera el juego de iconos de iOS', () async {
    final dir = '${root.path}${sep}ios${sep}Runner${sep}Assets.xcassets'
        '${sep}AppIcon.appiconset';

    // Nombre -> lado en pixeles.
    const iosIcons = <String, double>{
      'Icon-App-20x20@1x.png': 20,
      'Icon-App-20x20@2x.png': 40,
      'Icon-App-20x20@3x.png': 60,
      'Icon-App-29x29@1x.png': 29,
      'Icon-App-29x29@2x.png': 58,
      'Icon-App-29x29@3x.png': 87,
      'Icon-App-40x40@1x.png': 40,
      'Icon-App-40x40@2x.png': 80,
      'Icon-App-40x40@3x.png': 120,
      'Icon-App-60x60@2x.png': 120,
      'Icon-App-60x60@3x.png': 180,
      'Icon-App-76x76@1x.png': 76,
      'Icon-App-76x76@2x.png': 152,
      'Icon-App-83.5x83.5@2x.png': 167,
      'Icon-App-1024x1024@1x.png': 1024,
    };

    for (final entry in iosIcons.entries) {
      final size = entry.value;
      await _writePng(
        '$dir$sep${entry.key}',
        size,
        (canvas) => drawAppIcon(canvas, ui.Size(size, size)),
      );
    }

    // El icono de iOS no admite transparencia: se pone el fondo opaco.
    final contents = '''
{
  "images" : [
    {
      "filename" : "Icon-App-20x20@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-20x20@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20"
    },
    {
      "filename" : "Icon-App-29x29@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-29x29@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29"
    },
    {
      "filename" : "Icon-App-40x40@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-40x40@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40"
    },
    {
      "filename" : "Icon-App-60x60@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-60x60@3x.png",
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60"
    },
    {
      "filename" : "Icon-App-76x76@1x.png",
      "idiom" : "iphone",
      "scale" : "1x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-76x76@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "76x76"
    },
    {
      "filename" : "Icon-App-83.5x83.5@2x.png",
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "83.5x83.5"
    },
    {
      "filename" : "Icon-App-1024x1024@1x.png",
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024"
    }
  ],
  "info" : {
    "author" : "asset_studio",
    "version" : 1
  }
}
''';
    await File('$dir${sep}Contents.json').writeAsString(contents);
  });

  test('genera el favicon y los iconos de la web', () async {
    final webDir = '${root.path}${sep}web';
    await _writePng(
      '$webDir${sep}favicon.png',
      64,
      (canvas) => drawAppIcon(canvas, const ui.Size(64, 64)),
    );
    await _writePng(
      '$webDir${sep}icons${sep}icon-192.png',
      192,
      (canvas) => drawAppIcon(canvas, const ui.Size(192, 192)),
    );
    await _writePng(
      '$webDir${sep}icons${sep}icon-512.png',
      512,
      (canvas) => drawAppIcon(canvas, const ui.Size(512, 512)),
    );
  });

  test('genera el logo de la pantalla de inicio de Android', () async {
    final dir = '${root.path}${sep}android${sep}app${sep}src${sep}main${sep}res'
        '${sep}drawable';
    await _writePng(
      '$dir${sep}launch_logo.png',
      288,
      (canvas) => drawAppLogoMark(canvas, const ui.Size(288, 288)),
    );
    await _writePng(
      '$dir${sep}launch_logo_night.png',
      288,
      (canvas) => drawAppLogoMark(canvas, const ui.Size(288, 288)),
    );
  });

  test('genera la imagen de la pantalla de inicio de iOS', () async {
    final dir = '${root.path}${sep}ios${sep}Runner${sep}Assets.xcassets'
        '${sep}LaunchImage.imageset';
    const sizes = {
      'LaunchImage.png': 168.0,
      'LaunchImage@2x.png': 336.0,
      'LaunchImage@3x.png': 504.0,
    };
    for (final entry in sizes.entries) {
      await _writePng(
        '$dir$sep${entry.key}',
        entry.value,
        (canvas) =>
            drawAppLogoMark(canvas, ui.Size(entry.value, entry.value)),
      );
    }
  });

  test('genera los iconos maskable de la web', () async {
    final webDir = '${root.path}${sep}web${sep}icons';
    for (final size in [192.0, 512.0]) {
      await _writePng(
        '$webDir${sep}icon-maskable-${size.toInt()}.png',
        size,
        (canvas) {
          // Maskable: el fondo ocupa todo y el contenido va en la zona
          // segura (el sistema recorta los bordes).
          drawAppIconBackground(canvas, ui.Size(size, size));
          drawAppIconForeground(
            canvas,
            ui.Size(size, size),
            scale: 0.62,
          );
        },
      );
    }
  });
}
