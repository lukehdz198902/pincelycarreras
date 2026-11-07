// Sintetizador de audio de "Pincel & Carreras".
//
// Genera toda la banda sonora (2 musicas en bucle + 6 efectos) en WAV PCM
// 16-bit mono a 22050 Hz, formato soportado por audioplayers en Android/iOS.
//
// Uso:
//   dart run tool/generate_audio.dart
//
// La salida se escribe en <raiz del proyecto>/assets/audio/.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int kSampleRate = 22050;
const double kTwoPi = 2 * math.pi;

// ---------------------------------------------------------------------------
// Utilidades de sintesis
// ---------------------------------------------------------------------------

double sine(double phase) => math.sin(kTwoPi * phase);

double triangle(double phase) => 4 * (phase - phase.floor() - 0.5).abs() - 1;

double saw(double phase) => 2 * (phase - phase.floor()) - 1;

double square(double phase) => phase - phase.floor() < 0.5 ? 1 : -1;

/// Filtro paso bajo de un polo.
class LowPass {
  LowPass(double cutoff) {
    setCutoff(cutoff);
  }

  double _y = 0;
  double _a = 0.5;

  void setCutoff(double cutoff) {
    _a = 1 - math.exp(-kTwoPi * cutoff / kSampleRate);
  }

  double process(double x) {
    _y += _a * (x - _y);
    return _y;
  }
}

/// Envelope de ataque exponencial y caida exponencial.
double envelope(double t, double attack, double decay) {
  final attackGain = attack <= 0 ? 1.0 : math.min(1.0, t / attack);
  return attackGain * math.exp(-t * decay);
}

/// Anade una nota a [buffer] con barrido opcional de frecuencia.
void addNote(
  List<double> buffer, {
  required double start,
  required double duration,
  required double frequency,
  double? endFrequency,
  required double amplitude,
  double Function(double phase)? oscillator,
  double attack = 0.01,
  double decay = 6,
  double phaseOffset = 0,
}) {
  final osc = oscillator ?? sine;
  final startIndex = (start * kSampleRate).round();
  final length = (duration * kSampleRate).round();
  final target = endFrequency ?? frequency;
  var phase = phaseOffset;

  for (var i = 0; i < length; i++) {
    final index = startIndex + i;
    if (index < 0) {
      continue;
    }
    if (index >= buffer.length) {
      break;
    }
    final t = i / kSampleRate;
    final progress = duration <= 0 ? 0.0 : t / duration;
    final currentFrequency =
        frequency + (target - frequency) * progress;
    phase += currentFrequency / kSampleRate;
    buffer[index] += amplitude * envelope(t, attack, decay) * osc(phase);
  }
}

/// Anade ruido filtrado (percusion suave).
void addNoise(
  List<double> buffer, {
  required double start,
  required double duration,
  required double amplitude,
  required double cutoff,
  double decay = 20,
  double attack = 0.002,
  int seed = 1,
  double? sweepTo,
}) {
  final random = math.Random(seed);
  final filter = LowPass(cutoff);
  final startIndex = (start * kSampleRate).round();
  final length = (duration * kSampleRate).round();

  for (var i = 0; i < length; i++) {
    final index = startIndex + i;
    if (index < 0) {
      continue;
    }
    if (index >= buffer.length) {
      break;
    }
    final t = i / kSampleRate;
    if (sweepTo != null) {
      filter.setCutoff(
        cutoff + (sweepTo - cutoff) * (duration <= 0 ? 0 : t / duration),
      );
    }
    final noise = random.nextDouble() * 2 - 1;
    buffer[index] +=
        amplitude * envelope(t, attack, decay) * filter.process(noise);
  }
}

/// Normaliza el buffer al pico indicado.
void normalize(List<double> buffer, double peak) {
  var maxValue = 0.0;
  for (final sample in buffer) {
    final value = sample.abs();
    if (value > maxValue) {
      maxValue = value;
    }
  }
  if (maxValue == 0) {
    return;
  }
  final gain = peak / maxValue;
  for (var i = 0; i < buffer.length; i++) {
    buffer[i] *= gain;
  }
}

/// Aplica fundidos para evitar chasquidos en los extremos.
void applyEdgeFade(List<double> buffer, double seconds) {
  final fadeLength = (seconds * kSampleRate).round();
  for (var i = 0; i < fadeLength && i < buffer.length; i++) {
    final gain = i / fadeLength;
    buffer[i] *= gain;
    buffer[buffer.length - 1 - i] *= gain;
  }
}

/// Codifica el buffer como WAV PCM 16-bit mono.
Uint8List encodeWav(List<double> buffer) {
  final dataLength = buffer.length * 2;
  final bytes = ByteData(44 + dataLength);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  bytes.setUint32(4, 36 + dataLength, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little);
  bytes.setUint16(22, 1, Endian.little);
  bytes.setUint32(24, kSampleRate, Endian.little);
  bytes.setUint32(28, kSampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  writeAscii(36, 'data');
  bytes.setUint32(40, dataLength, Endian.little);

  for (var i = 0; i < buffer.length; i++) {
    final value = (buffer[i].clamp(-1.0, 1.0) * 32767).round();
    bytes.setInt16(44 + i * 2, value, Endian.little);
  }

  return bytes.buffer.asUint8List();
}

// ---------------------------------------------------------------------------
// Teoria musical
// ---------------------------------------------------------------------------

/// Frecuencia en Hz de una nota (A4 = 440 Hz).
double note(int semitonesFromA4) =>
    (440 * math.pow(2, semitonesFromA4 / 12)).toDouble();

/// Escala pentatonica mayor (do, re, mi, sol, la).
const List<int> kPentatonic = [0, 2, 4, 7, 9, 12, 14, 16, 19, 21];

/// Triadas en Do mayor: C, G, Am, F.
const List<List<int>> kChords = [
  [0, 4, 7],
  [7, 11, 14],
  [9, 12, 16],
  [5, 9, 12],
];

/// Escala mayor de Do para melodias.
const List<int> kScale = [0, 2, 4, 5, 7, 9, 11];

// ---------------------------------------------------------------------------
// Musica: modo pintura
// ---------------------------------------------------------------------------

/// Musica alegre y relajada para el estudio de pintura.
///
/// 12 compases a 100 BPM (28,8 s) en Do mayor, con pad suave, bajo,
/// campana de aceite y un pandillo suave. Sin letra ni percusion agresiva.
List<double> buildPaintingLoop() {
  const bpm = 100.0;
  const beat = 60 / bpm;
  const bar = beat * 4;
  const bars = 12;
  final totalSeconds = bar * bars;
  final buffer = List<double>.filled((totalSeconds * kSampleRate).round(), 0);

  // Progresion: 2 compases por acorde (C, G, Am, F) repetida con cola.
  final progression = <int>[0, 0, 1, 1, 2, 2, 3, 3, 0, 0, 3, 3];

  for (var barIndex = 0; barIndex < bars; barIndex++) {
    final barStart = barIndex * bar;
    final chord = kChords[progression[barIndex]];
    final root = note(chord[0] - 9);

    // Pad sostenido (2 compases por acorde).
    if (barIndex % 2 == 0) {
      for (final semitone in chord) {
        addNote(
          buffer,
          start: barStart,
          duration: bar * 2.2,
          frequency: note(semitone - 9),
          amplitude: 0.055,
          oscillator: triangle,
          attack: 0.55,
          decay: 0.32,
        );
        addNote(
          buffer,
          start: barStart,
          duration: bar * 2.2,
          frequency: note(semitone - 9) * 2,
          amplitude: 0.018,
          oscillator: sine,
          attack: 0.7,
          decay: 0.4,
        );
      }
    }

    // Bajo en los tiempos 1 y 3.
    for (final beatIndex in [0, 2]) {
      addNote(
        buffer,
        start: barStart + beatIndex * beat,
        duration: beat * 1.6,
        frequency: root,
        amplitude: 0.13,
        oscillator: triangle,
        attack: 0.02,
        decay: 2.6,
      );
    }

    // Campana de aceite: melodia en corcheas conasonancias del acorde.
    final melodyPattern = <int>[0, 2, 1, 3, 2, 4, 3, 1];
    for (var eighth = 0; eighth < 8; eighth++) {
      final step = melodyPattern[(barIndex * 3 + eighth) % melodyPattern.length];
      final semitone = chord[step % chord.length] +
          (step >= chord.length ? 12 : 0) +
          (eighth.isEven ? 12 : 0);
      final start = barStart + eighth * (beat / 2);
      addNote(
        buffer,
        start: start,
        duration: beat * 1.4,
        frequency: note(semitone - 9),
        amplitude: 0.075,
        oscillator: sine,
        attack: 0.005,
        decay: 4.2,
      );
      addNote(
        buffer,
        start: start,
        duration: beat * 0.8,
        frequency: note(semitone - 9) * 3.01,
        amplitude: 0.018,
        oscillator: sine,
        attack: 0.004,
        decay: 7,
      );
    }

    // Pandillo muy suave en los contratiempos.
    for (var eighth = 0; eighth < 8; eighth++) {
      if (eighth.isEven) {
        continue;
      }
      addNoise(
        buffer,
        start: barStart + eighth * (beat / 2),
        duration: 0.09,
        amplitude: 0.016,
        cutoff: 6000,
        decay: 55,
        seed: 1000 + barIndex * 8 + eighth,
      );
    }
  }

  applyEdgeFade(buffer, 0.05);
  normalize(buffer, 0.62);
  return buffer;
}

// ---------------------------------------------------------------------------
// Musica: modo carreras
// ---------------------------------------------------------------------------

/// Musica rítmica pero suave para las carreras.
///
/// 10 compases a 120 BPM (20 s) con bombo suave, charles, bajo y xilofono.
List<double> buildRacingLoop() {
  const bpm = 120.0;
  const beat = 60 / bpm;
  const bar = beat * 4;
  const bars = 10;
  final totalSeconds = bar * bars;
  final buffer = List<double>.filled((totalSeconds * kSampleRate).round(), 0);

  // Progresion que resuelve en Do mayor para cerrar el bucle.
  final progression = <int>[0, 1, 2, 3, 0, 1, 2, 3, 0, 0];

  for (var barIndex = 0; barIndex < bars; barIndex++) {
    final barStart = barIndex * bar;
    final chord = kChords[progression[barIndex]];

    // Bombo suave en los tiempos 1 y 3.
    for (final beatIndex in [0, 2]) {
      addNote(
        buffer,
        start: barStart + beatIndex * beat,
        duration: beat * 0.9,
        frequency: 120,
        endFrequency: 52,
        amplitude: 0.22,
        oscillator: sine,
        attack: 0.004,
        decay: 9,
      );
    }

    // Charles (ruido corto y filtrado) en corcheas.
    for (var eighth = 0; eighth < 8; eighth++) {
      addNoise(
        buffer,
        start: barStart + eighth * (beat / 2),
        duration: 0.06,
        amplitude: eighth.isEven ? 0.028 : 0.016,
        cutoff: 7500,
        decay: 60,
        seed: 5000 + barIndex * 8 + eighth,
      );
    }

    // Bajo en corcheas (tonica, quinta, octava).
    const bassPattern = [0, 0, 2, 0, 1, 0, 2, 1];
    for (var eighth = 0; eighth < 8; eighth++) {
      final semitone = chord[bassPattern[eighth] % chord.length];
      addNote(
        buffer,
        start: barStart + eighth * (beat / 2),
        duration: beat * 0.45,
        frequency: note(semitone - 21),
        amplitude: 0.16,
        oscillator: triangle,
        attack: 0.008,
        decay: 6,
      );
    }

    // Xilofono: melodia sobre la escala.
    final melody = <int>[4, 5, 6, 5, 4, 2, 4, 5];
    for (var eighth = 0; eighth < 8; eighth++) {
      final scaleStep = melody[(barIndex * 2 + eighth) % melody.length];
      final semitone = kScale[scaleStep % kScale.length] + 12;
      addNote(
        buffer,
        start: barStart + eighth * (beat / 2),
        duration: beat * 0.7,
        frequency: note(semitone - 9),
        amplitude: 0.07,
        oscillator: sine,
        attack: 0.004,
        decay: 7.5,
      );
      addNote(
        buffer,
        start: barStart + eighth * (beat / 2),
        duration: beat * 0.35,
        frequency: note(semitone - 9) * 3.02,
        amplitude: 0.016,
        oscillator: sine,
        attack: 0.003,
        decay: 12,
      );
    }
  }

  applyEdgeFade(buffer, 0.04);
  normalize(buffer, 0.66);
  return buffer;
}

// ---------------------------------------------------------------------------
// Efectos de sonido
// ---------------------------------------------------------------------------

/// "Pop" de burbuja al pintar.
List<double> buildPop() {
  final buffer = List<double>.filled((0.11 * kSampleRate).round(), 0);
  addNote(
    buffer,
    start: 0,
    duration: 0.11,
    frequency: 380,
    endFrequency: 900,
    amplitude: 0.7,
    oscillator: sine,
    attack: 0.002,
    decay: 26,
  );
  addNote(
    buffer,
    start: 0,
    duration: 0.07,
    frequency: 780,
    endFrequency: 1700,
    amplitude: 0.18,
    oscillator: sine,
    attack: 0.002,
    decay: 34,
  );
  normalize(buffer, 0.8);
  return buffer;
}

/// "Swoosh" al cambiar de carril.
List<double> buildSwoosh() {
  final buffer = List<double>.filled((0.22 * kSampleRate).round(), 0);
  addNoise(
    buffer,
    start: 0,
    duration: 0.22,
    amplitude: 0.55,
    cutoff: 400,
    sweepTo: 4200,
    decay: 7,
    attack: 0.05,
    seed: 77,
  );
  addNoise(
    buffer,
    start: 0.1,
    duration: 0.12,
    amplitude: 0.25,
    cutoff: 3200,
    sweepTo: 500,
    decay: 12,
    attack: 0.02,
    seed: 78,
  );
  applyEdgeFade(buffer, 0.02);
  normalize(buffer, 0.62);
  return buffer;
}

/// "Ding" al recoger una estrella.
List<double> buildDing() {
  final buffer = List<double>.filled((0.45 * kSampleRate).round(), 0);
  const partials = [
    [1318.51, 0.55, 6.0],
    [1975.53, 0.26, 9.0],
    [2637.02, 0.14, 13.0],
  ];
  for (final partial in partials) {
    addNote(
      buffer,
      start: 0,
      duration: 0.45,
      frequency: partial[0],
      amplitude: partial[1],
      oscillator: sine,
      attack: 0.003,
      decay: partial[2],
    );
  }
  normalize(buffer, 0.8);
  return buffer;
}

/// Golpe suave y no punitivo al chocar.
List<double> buildCrash() {
  final buffer = List<double>.filled((0.3 * kSampleRate).round(), 0);
  addNote(
    buffer,
    start: 0,
    duration: 0.3,
    frequency: 165,
    endFrequency: 58,
    amplitude: 0.5,
    oscillator: sine,
    attack: 0.004,
    decay: 9,
  );
  addNoise(
    buffer,
    start: 0,
    duration: 0.18,
    amplitude: 0.18,
    cutoff: 1100,
    decay: 14,
    attack: 0.003,
    seed: 909,
  );
  applyEdgeFade(buffer, 0.015);
  normalize(buffer, 0.55);
  return buffer;
}

/// Arpegio ascendente al desbloquear una recompensa.
List<double> buildUnlock() {
  final buffer = List<double>.filled((0.85 * kSampleRate).round(), 0);
  const arpeggio = [1046.5, 1318.5, 1567.98, 2093.0];
  for (var i = 0; i < arpeggio.length; i++) {
    addNote(
      buffer,
      start: i * 0.11,
      duration: 0.5,
      frequency: arpeggio[i],
      amplitude: 0.45,
      oscillator: sine,
      attack: 0.004,
      decay: 5.5,
    );
    addNote(
      buffer,
      start: i * 0.11,
      duration: 0.25,
      frequency: arpeggio[i] * 2,
      amplitude: 0.12,
      oscillator: sine,
      attack: 0.003,
      decay: 9,
    );
  }
  normalize(buffer, 0.8);
  return buffer;
}

/// Toque suave de interfaz.
List<double> buildUiTap() {
  final buffer = List<double>.filled((0.09 * kSampleRate).round(), 0);
  addNote(
    buffer,
    start: 0,
    duration: 0.09,
    frequency: 660,
    endFrequency: 880,
    amplitude: 0.5,
    oscillator: sine,
    attack: 0.002,
    decay: 30,
  );
  normalize(buffer, 0.6);
  return buffer;
}

/// Motor: el "vroom" que suena al arrancar a acelerar.
///
/// Un zumbido que **sube de tono** en 1,2 s (como un motor acelerando) con
/// un pequeno ruido de admision.
List<double> buildMotor() {
  const seconds = 1.2;
  final buffer = List<double>.filled((seconds * kSampleRate).round(), 0);

  for (var i = 0; i < buffer.length; i++) {
    final t = i / kSampleRate;
    final progress = t / seconds;
    // El tono sube con la aceleracion.
    final frequency = 55 + progress * 85;
    final base = math.sin(kTwoPi * frequency * t) * 0.6 +
        math.sin(kTwoPi * frequency * 2 * t) * 0.22 +
        math.sin(kTwoPi * frequency * 3 * t) * 0.08;
    buffer[i] = base * (0.35 + progress * 0.65);
  }

  // Admision: un poco de ruido filtrado.
  final filter = LowPass(1400);
  final random = math.Random(4242);
  for (var i = 0; i < buffer.length; i++) {
    final t = i / kSampleRate;
    final noise = filter.process(random.nextDouble() * 2 - 1);
    buffer[i] += noise * 0.08 * (t / seconds);
  }

  applyEdgeFade(buffer, 0.05);
  normalize(buffer, 0.6);
  return buffer;
}

/// Campanilla de bienvenida de la pantalla de inicio.
///
/// Un arpegio suave y brillante (Do mayor) que dura menos de 1,5 s: da la
/// bienvenida sin cansar y sin sobresaltar al nino.
List<double> buildWelcome() {
  final buffer = List<double>.filled((1.3 * kSampleRate).round(), 0);
  const arpeggio = [523.25, 659.25, 783.99, 1046.5];
  for (var i = 0; i < arpeggio.length; i++) {
    addNote(
      buffer,
      start: i * 0.13,
      duration: 0.7,
      frequency: arpeggio[i],
      amplitude: 0.4,
      oscillator: sine,
      attack: 0.006,
      decay: 4.2,
    );
    addNote(
      buffer,
      start: i * 0.13,
      duration: 0.35,
      frequency: arpeggio[i] * 2.01,
      amplitude: 0.12,
      oscillator: sine,
      attack: 0.004,
      decay: 7.5,
    );
  }
  // Brillo final en la octava alta.
  addNote(
    buffer,
    start: 0.52,
    duration: 0.75,
    frequency: 1567.98,
    amplitude: 0.16,
    oscillator: sine,
    attack: 0.004,
    decay: 4,
  );
  normalize(buffer, 0.72);
  return buffer;
}

// ---------------------------------------------------------------------------
// Escritura en disco
// ---------------------------------------------------------------------------

Directory resolveProjectRoot() {
  var dir = Directory.current;
  while (true) {
    final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
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

void writeAudio(String path, List<double> buffer) {
  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(encodeWav(buffer), flush: true);
  final seconds = buffer.length / kSampleRate;
  stdout.writeln(
    '  ${path.split(Platform.pathSeparator).last.padRight(22)} '
    '${seconds.toStringAsFixed(2)} s  '
    '${(file.lengthSync() / 1024).toStringAsFixed(0)} KB',
  );
}

void main() {
  final root = resolveProjectRoot();
  final audioDir = '${root.path}${Platform.pathSeparator}assets${Platform.pathSeparator}audio';

  stdout.writeln('Generando audio de Pincel & Carreras...');

  stdout.writeln(' Musica:');
  writeAudio(
    '$audioDir${Platform.pathSeparator}music${Platform.pathSeparator}painting_loop.wav',
    buildPaintingLoop(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}music${Platform.pathSeparator}racing_loop.wav',
    buildRacingLoop(),
  );

  stdout.writeln(' Efectos:');
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}pop.wav',
    buildPop(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}swoosh.wav',
    buildSwoosh(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}ding.wav',
    buildDing(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}crash.wav',
    buildCrash(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}unlock.wav',
    buildUnlock(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}ui_tap.wav',
    buildUiTap(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}motor.wav',
    buildMotor(),
  );
  writeAudio(
    '$audioDir${Platform.pathSeparator}sfx${Platform.pathSeparator}welcome.wav',
    buildWelcome(),
  );

  stdout.writeln('Listo.');
}
