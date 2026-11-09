import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/data/services/tilt_service.dart';

import '../helpers/sensor_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(mockSensorChannels);

  group('TiltService', () {
    test('sin sensor el servicio queda neutro y disponible', () {
      final service = TiltService();
      expect(service.steering, 0);
      expect(service.isAvailable, isFalse);
    });

    test('centrar el volante pone la direccion a cero', () {
      final service = TiltService();
      service.reset();
      expect(service.steering, 0);
    });

    test('el servicio se puede parar sin errores', () async {
      final service = TiltService();
      await service.start();
      service.stop();
      expect(service.isAvailable, isFalse);
      expect(service.steering, 0);
    });

    test('avanzar el reloj no rompe la direccion', () {
      final service = TiltService();
      service.update(0.016);
      service.update(0.016);
      expect(service.steering, 0);
    });
  });
}
