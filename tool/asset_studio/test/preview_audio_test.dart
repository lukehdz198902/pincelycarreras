// Verificacion visual del audio generado.
//
// Lee los WAV de assets/audio y dibuja su forma de onda en PNG para
// comprobar de un vistazo que hay senal real (ni silencio ni saturacion).
//
// Uso:
//   cd tool/asset_studio
//   flutter test test/preview_audio_test.dart

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:asset_studio/studio.dart';

class WavData {
  const WavData(this.samples, this.sampleRate);

  final Int16List samples;
  final int sampleRate;

  double get seconds => samples.length / sampleRate;

  double peak() {
    var maxValue = 0.0;
    for (final sample in samples) {
      final value = sample.abs() / 32768;
      if (value > maxValue) {
        maxValue = value;
      }
    }
    return maxValue;
  }

  double rms() {
    if (samples.isEmpty) {
      return 0;
    }
    var sum = 0.0;
    for (final sample in samples) {
      final value = sample / 32768;
      sum += value * value;
    }
    return math.sqrt(sum / samples.length);
  }
}

WavData readWav(File file) {
  final bytes = file.readAsBytesSync();
  final data = ByteData.sublistView(bytes);
  var offset = 12;
  var sampleRate = 22050;
  Int16List? samples;

  while (offset + 8 <= bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkSize = data.getUint32(offset + 4, Endian.little);
    if (chunkId == 'fmt ') {
      sampleRate = data.getUint32(offset + 12, Endian.little);
    } else if (chunkId == 'data') {
      final count = chunkSize ~/ 2;
      samples = Int16List(count);
      for (var i = 0; i < count; i++) {
        samples[i] = data.getInt16(offset + 8 + i * 2, Endian.little);
      }
    }
    offset += 8 + chunkSize + (chunkSize.isOdd ? 1 : 0);
  }

  if (samples == null) {
    throw StateError('WAV sin chunk de datos: ${file.path}');
  }
  return WavData(samples, sampleRate);
}

void main() {
  final root = resolveProjectRoot();
  final audioDir = Directory(
    '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}audio',
  );
  final previewDir = Directory(
    '${root.path}${Platform.pathSeparator}build${Platform.pathSeparator}audio_preview',
  );

  test('los WAV contienen senal valida', () {
    final files = audioDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.wav'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(files, isNotEmpty, reason: 'No hay ficheros WAV generados');

    for (final file in files) {
      final wav = readWav(file);
      final name = file.path.split(Platform.pathSeparator).last;

      // ignore: avoid_print
      print(
        '$name  ${wav.seconds.toStringAsFixed(2)}s  '
        'pico=${wav.peak().toStringAsFixed(3)}  '
        'rms=${wav.rms().toStringAsFixed(3)}',
      );

      expect(wav.peak(), greaterThan(0.05), reason: '$name esta casi en silencio');
      expect(wav.peak(), lessThanOrEqualTo(1.0), reason: '$name satura');
      expect(wav.rms(), greaterThan(0.005), reason: '$name no tiene cuerpo');
      expect(wav.samples.length, greaterThan(1000), reason: '$name es demasiado corto');
    }
  });

  test('dibuja las formas de onda', () async {
    final files = audioDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.wav'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    for (final file in files) {
      final wav = readWav(file);
      final name = file.path.split(Platform.pathSeparator).last;
      const width = 900.0;
      const height = 200.0;

      await writePng(
        '${previewDir.path}${Platform.pathSeparator}$name.png',
        const ui.Size(width, height),
        (canvas) {
          canvas.drawRect(
            const Rect.fromLTWH(0, 0, width, height),
            fill(const Color(0xFFFFF6E9)),
          );
          canvas.drawLine(
            const Offset(0, height / 2),
            const Offset(width, height / 2),
            stroke(const Color(0xFFBBB0A0), 1),
          );

          final step = (wav.samples.length / width).ceil();
          final path = Path();
          for (var x = 0; x < width; x++) {
            final start = x * step;
            var minValue = 1.0;
            var maxValue = -1.0;
            for (var i = start; i < start + step && i < wav.samples.length; i++) {
              final value = wav.samples[i] / 32768;
              if (value < minValue) {
                minValue = value;
              }
              if (value > maxValue) {
                maxValue = value;
              }
            }
            if (minValue > maxValue) {
              continue;
            }
            path.moveTo(x.toDouble(), height / 2 - maxValue * (height / 2 - 6));
            path.lineTo(x.toDouble(), height / 2 - minValue * (height / 2 - 6));
          }
          canvas.drawPath(path, stroke(const Color(0xFF4D8DFF), 1));
        },
      );
    }
  });
}
