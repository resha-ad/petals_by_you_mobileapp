import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

/// Emits void events on shake gesture via accelerometer.
class ShakeSensor {
  static const double _kThreshold = 13.5;
  static const Duration _kCooldown = Duration(milliseconds: 900);

  final StreamController<void> _controller = StreamController.broadcast();
  StreamSubscription<AccelerometerEvent>? _sub;
  DateTime? _lastShake;

  Stream<void> get onShake => _controller.stream;

  void start() {
    _sub = accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((e) {
          final mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
          if (mag < _kThreshold) return;
          final now = DateTime.now();
          if (_lastShake != null && now.difference(_lastShake!) < _kCooldown)
            return;
          _lastShake = now;
          if (!_controller.isClosed) _controller.add(null);
        });
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }
}
