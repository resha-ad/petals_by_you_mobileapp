import 'dart:async';
import 'package:proximity_sensor/proximity_sensor.dart';

/// Streams true when proximity sensor detects nearby object.
/// Used for Privacy Mode — masks sensitive data when phone is near face/pocket.
class ProximitySensorService {
  final StreamController<bool> _ctrl = StreamController.broadcast();
  StreamSubscription<dynamic>? _sub;

  Stream<bool> get isNearStream => _ctrl.stream;

  void start() {
    _sub = ProximitySensor.events.listen((event) {
      // 0 = near on most platforms
      if (!_ctrl.isClosed) _ctrl.add(event == 0);
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
