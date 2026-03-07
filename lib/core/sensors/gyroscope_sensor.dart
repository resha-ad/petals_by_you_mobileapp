import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';

/// Smoothed gyroscope tilt — clamped to [-1, 1] for parallax effects.
class GyroTilt {
  final double x;
  final double y;
  const GyroTilt({required this.x, required this.y});
  static const zero = GyroTilt(x: 0, y: 0);
}

class GyroscopeSensor {
  static const double _kMax = 1.8;
  static const double _kSmooth = 0.18;

  double _sx = 0, _sy = 0;
  StreamSubscription<GyroscopeEvent>? _sub;
  final StreamController<GyroTilt> _ctrl = StreamController.broadcast();

  Stream<GyroTilt> get tiltStream => _ctrl.stream;

  void start() {
    _sub = gyroscopeEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((e) {
          _sx += (e.y - _sx) * _kSmooth;
          _sy += (e.x - _sy) * _kSmooth;
          if (!_ctrl.isClosed) {
            _ctrl.add(
              GyroTilt(
                x: (_sx / _kMax).clamp(-1.0, 1.0),
                y: (_sy / _kMax).clamp(-1.0, 1.0),
              ),
            );
          }
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
