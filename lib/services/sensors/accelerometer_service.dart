import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter/foundation.dart';

class AccelerometerService {
  static StreamSubscription<AccelerometerEvent>? _subscription;
  static AccelerometerEvent? _lastEvent;
  static List<AccelerometerEvent> _eventHistory = [];
  
  static const int _historySize = 100;

  static AccelerometerEvent? get lastEvent => _lastEvent;
  static List<AccelerometerEvent> get eventHistory => _eventHistory;

  static double get x => _lastEvent?.x ?? 0;
  static double get y => _lastEvent?.y ?? 0;
  static double get z => _lastEvent?.z ?? 0;

  static void startListening() {
    if (_subscription != null) return;

    _subscription = accelerometerEventStream().listen(
      (AccelerometerEvent event) {
        _lastEvent = event;
        _eventHistory.add(event);
        
        if (_eventHistory.length > _historySize) {
          _eventHistory.removeAt(0);
        }
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );
  }

  static void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  static double getMagnitude() {
    if (_lastEvent == null) return 0;
    return _lastEvent!.x.abs() + _lastEvent!.y.abs() + _lastEvent!.z.abs();
  }

  static bool isShaking({double threshold = 15.0}) {
    return getMagnitude() > threshold;
  }

  static String getMovementPattern() {
    if (_eventHistory.length < 10) return 'unknown';

    // Calculate average movement
    double totalMagnitude = 0;
    for (final event in _eventHistory.reversed.take(10)) {
      totalMagnitude += event.x.abs() + event.y.abs() + event.z.abs();
    }
    final avgMagnitude = totalMagnitude / 10;

    if (avgMagnitude < 1) return 'stationary';
    if (avgMagnitude < 5) return 'slow_movement';
    if (avgMagnitude < 15) return 'walking';
    if (avgMagnitude < 30) return 'running';
    return 'vigorous';
  }

  static void clearHistory() {
    _eventHistory.clear();
  }
}
