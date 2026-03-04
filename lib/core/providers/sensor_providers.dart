import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/sensors/gyroscope_sensor.dart';
import 'package:sprint1_project/core/sensors/light_sensor_service.dart';
import 'package:sprint1_project/core/sensors/proximity_sensor_service.dart';
import 'package:sprint1_project/core/sensors/shake_sensor.dart';

/// Accelerometer shake detection — singleton started lazily.
final shakeSensorProvider = Provider<ShakeSensor>((ref) {
  final s = ShakeSensor()..start();
  ref.onDispose(s.dispose);
  return s;
});

/// Gyroscope tilt stream for parallax UI effects.
final gyroTiltProvider = StreamProvider<GyroTilt>((ref) {
  final s = GyroscopeSensor()..start();
  ref.onDispose(s.dispose);
  return s.tiltStream;
});

/// Ambient light level stream for smart theme switching.
final lightLevelProvider = StreamProvider<AmbientLight>((ref) async* {
  final s = LightSensorService();
  await s.start();
  ref.onDispose(s.dispose);
  yield* s.stream;
});

/// Proximity sensor — true when object is near (privacy mode trigger).
final privacyNearProvider = StreamProvider<bool>((ref) {
  final s = ProximitySensorService()..start();
  ref.onDispose(s.dispose);
  return s.isNearStream;
});
