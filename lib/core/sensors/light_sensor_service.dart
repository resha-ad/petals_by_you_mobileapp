import 'dart:async';
import 'package:light_sensor/light_sensor.dart';

enum AmbientLight { dark, dim, bright }

/// Streams ambient light level from device light sensor.
/// Gracefully unavailable on unsupported devices.
class LightSensorService {
  static const int _kDim = 50;
  static const int _kBright = 200;

  final StreamController<AmbientLight> _ctrl = StreamController.broadcast();
  StreamSubscription<int>? _sub;
  bool _available = false;

  Stream<AmbientLight> get stream => _ctrl.stream;
  bool get isAvailable => _available;

  Future<void> start() async {
    _available = await LightSensor.hasSensor();
    if (!_available) return;
    _sub = LightSensor.luxStream().listen((lux) {
      final level = lux < _kDim
          ? AmbientLight.dark
          : lux < _kBright
          ? AmbientLight.dim
          : AmbientLight.bright;
      if (!_ctrl.isClosed) _ctrl.add(level);
    });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    stop();
    _ctrl.close();
  }
}
