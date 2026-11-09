import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simula los canales de los sensores para que los tests no dependan del
/// hardware.
///
/// Sin esto, `sensors_plus` intenta hablar con el canal de plataforma y en
/// el entorno de pruebas no hay plugin: el error se reporta y el test falla.
void mockSensorChannels() {
  const channels = [
    // Canal de metodos (periodo de muestreo).
    'dev.fluttercommunity.plus/sensors/method',
    // Canales de eventos.
    'dev.fluttercommunity.plus/sensors/gyroscope',
    'dev.fluttercommunity.plus/sensors/accelerometer',
    'dev.fluttercommunity.plus/sensors/user_accel',
  ];
  for (final name in channels) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          MethodChannel(name),
          (MethodCall call) async => null,
        );
  }
}
