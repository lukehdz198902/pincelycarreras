import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
/// Direccion de la carrera mediante **inclinacion** del movil.
///
/// El nino sujeta el telefono en horizontal y lo **gira como si fuera un
/// volante**: el coche se va hacia el lado por el que gira.
///
/// Como el giroscopio mide la rotacion alrededor del eje normal a la
/// pantalla, el gesto funciona **igual** con el movil en horizontal
/// izquierdo o derecho (no hay que invertir nada segun como se sujete).
///
/// Si el dispositivo **no tiene giroscopio** (emuladores, web, movil muy
/// antiguo) se usa el acelerometro: en horizontal, su eje X es el eje
/// vertical de la pantalla, asi que inclinando el movil hacia delante o
/// atras el coche se desplaza por la carretera.
///
/// Si no hay ningun sensor, el servicio se queda **neutro** y el nino puede
/// seguir jugando arrastrando el coche con el dedo.
class TiltService {
  /// Radio maximo del volante virtual, en radianes (~31 grados).
  static const double maxWheelAngle = 0.55;

  /// Giro normalizado: `-1` = todo a la izquierda, `0` = centrado,
  /// `+1` = todo a la derecha.
  double get steering => (_wheel / maxWheelAngle).clamp(-1.0, 1.0);

  /// `true` si hay un sensor utilizable en este dispositivo.
  bool get isAvailable => _available;

  /// Velocidad a la que el volante vuelve solo al centro (por segundo).
  static const double returnRate = 1.8;

  /// Rango de inclinacion (m/s2) que corresponde al giro maximo, cuando
  /// solo hay acelerometro.
  static const double tiltRange = 5.5;

  /// Angulo del volante virtual, en radianes.
  double _wheel = 0;

  /// `true` si el servicio esta escuchando algun sensor.
  bool _available = false;

  /// `true` si se esta usando el giroscopio (preferido).
  bool _usingGyroscope = false;

  StreamSubscription<GyroscopeEvent>? _gyroscope;
  StreamSubscription<AccelerometerEvent>? _accelerometer;

  /// Ultima marca de tiempo del giroscopio (para integrar el giro).
  DateTime? _lastGyroTime;

  /// Lectura neutra del acelerometro (la postura de partida).
  double _neutralTilt = 0;
  int _neutralSamples = 0;

  /// Empieza a escuchar el sensor.
  ///
  /// Nunca lanza: si el sensor no existe, el servicio simply se queda
  /// neutro y el juego sigue siendo jugable con el dedo.
  Future<void> start() async {
    if (_gyroscope != null || _accelerometer != null) {
      return;
    }
    if (!_platformSupported) {
      // En escritorio no hay sensor: no se intenta (evita errores del
      // canal de plataforma).
      return;
    }
    try {
      _gyroscope = gyroscopeEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onGyroscope,
        onError: (Object error) {
          debugPrint('[Pincel] El giroscopio fallo: $error');
          _gyroscope?.cancel();
          _gyroscope = null;
          _startAccelerometer();
        },
      );
      _available = true;
      _usingGyroscope = true;
      return;
    } catch (error) {
      debugPrint('[Pincel] Sin giroscopio: $error');
    }
    _startAccelerometer();
  }

  /// `true` si la plataforma puede tener sensores.
  static bool get _platformSupported {
    if (kIsWeb) {
      return true;
    }
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  void _startAccelerometer() {
    if (_accelerometer != null) {
      return;
    }
    try {
      _accelerometer = accelerometerEventStream(
        samplingPeriod: SensorInterval.gameInterval,
      ).listen(
        _onAccelerometer,
        onError: (Object error) {
          debugPrint('[Pincel] El acelerometro fallo: $error');
          _accelerometer?.cancel();
          _accelerometer = null;
          _available = false;
        },
      );
      _available = true;
      _usingGyroscope = false;
    } catch (error) {
      debugPrint('[Pincel] Sin sensores: $error');
      _available = false;
    }
  }

  /// Deja de escuchar el sensor y centra el volante.
  void stop() {
    _gyroscope?.cancel();
    _gyroscope = null;
    _accelerometer?.cancel();
    _accelerometer = null;
    _available = false;
    _usingGyroscope = false;
    _wheel = 0;
    _lastGyroTime = null;
    _neutralSamples = 0;
  }

  /// Avanza el reloj del servicio: el volante vuelve solo al centro.
  ///
  /// Se llama desde el bucle del juego para que el retorno al centro sea
  /// igual en todos los dispositivos.
  void update(double dt) {
    if (!_usingGyroscope) {
      return;
    }
    _wheel *= math.exp(-returnRate * dt);
    if (_wheel.abs() < 0.001) {
      _wheel = 0;
    }
  }

  /// Centra el volante de golpe (por ejemplo al empezar la carrera).
  void reset() {
    _wheel = 0;
    _lastGyroTime = null;
  }

  void _onGyroscope(GyroscopeEvent event) {
    final last = _lastGyroTime;
    _lastGyroTime = event.timestamp;
    if (last == null) {
      return;
    }
    final dt = event.timestamp.difference(last).inMicroseconds / 1e6;
    if (dt <= 0 || dt > 0.5) {
      return;
    }
    // El eje Z es la rotacion alrededor de la normal de la pantalla: es
    // exactamente el giro del "volante".
    _wheel += event.z * dt;
    if (_wheel > maxWheelAngle) {
      _wheel = maxWheelAngle;
    } else if (_wheel < -maxWheelAngle) {
      _wheel = -maxWheelAngle;
    }
  }

  void _onAccelerometer(AccelerometerEvent event) {
    // En horizontal, el eje X del dispositivo es el eje vertical de la
    // pantalla (la carretera). Se toma como neutra la postura inicial.
    if (_neutralSamples < 12) {
      _neutralSamples++;
      _neutralTilt += (event.x - _neutralTilt) / _neutralSamples;
      return;
    }
    final delta = event.x - _neutralTilt;
    _wheel = (delta / tiltRange) * maxWheelAngle;
    if (_wheel > maxWheelAngle) {
      _wheel = maxWheelAngle;
    } else if (_wheel < -maxWheelAngle) {
      _wheel = -maxWheelAngle;
    }
  }
}
