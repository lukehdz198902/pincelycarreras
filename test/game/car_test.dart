import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:pincel_y_carreras/game/racing/car.dart';
import 'package:pincel_y_carreras/game/racing/lane.dart';

/// Crea una imagen minima para poder montar el coche en las pruebas.
Future<ui.Image> _createImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder);
  canvas.drawRect(
    const ui.Rect.fromLTWH(0, 0, 10, 10),
    ui.Paint()..color = const ui.Color(0xFFFF4757),
  );
  final picture = recorder.endRecording();
  final image = await picture.toImage(10, 10);
  picture.dispose();
  return image;
}

void main() {
  group('Car', () {
    late ui.Image image;

    setUp(() async {
      image = await _createImage();
    });

    tearDown(() {
      image.dispose();
    });

    Car buildCar() {
      final car = Car(image: image, carWidth: 76, carHeight: 116);
      car.configure(roadCenterX: 200, laneWidth: 120);
      return car;
    }

    test('arranca en el carril central', () {
      final car = buildCar();
      expect(car.currentLane, Lane.center);
      expect(car.x, 200);
    });

    test('el toque a la izquierda mueve el coche de carril', () {
      final car = buildCar();
      car.steerLeft();
      car.update(0.3);
      expect(car.currentLane, Lane.left);
      expect(car.x, closeTo(80, 0.5));
    });

    test('el toque a la derecha mueve el coche de carril', () {
      final car = buildCar();
      car.steerRight();
      car.update(0.3);
      expect(car.currentLane, Lane.right);
      expect(car.x, closeTo(320, 0.5));
    });

    test('no se puede salir de la pista', () {
      final car = buildCar();
      car.steerLeft();
      car.update(0.3);
      car.steerLeft();
      car.update(0.3);
      expect(car.currentLane, Lane.left);
    });

    test('un cambio durante la transicion se guarda en el buffer', () {
      final car = buildCar();
      car.steerLeft();
      car.update(0.05);
      expect(car.currentLane, Lane.left, reason: 'ya se dirige a la izquierda');
      car.steerRight();
      expect(
        car.currentLane,
        Lane.left,
        reason: 'el giro queda en el buffer hasta terminar la transicion',
      );
      car.update(0.3);
      expect(car.currentLane, Lane.center, reason: 'el buffer aplico el giro');
    });

    test('tras un choque el coche queda inmovilizado un segundo', () {
      final car = buildCar();
      expect(car.isStunned, isFalse);
      car.stun();
      expect(car.isStunned, isTrue);
      car.update(0.5);
      expect(car.isStunned, isTrue);
      car.update(0.6);
      expect(car.isStunned, isFalse);
    });
  });
}
