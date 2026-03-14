import 'package:pedometer_2/pedometer_2.dart';
import 'package:flutter/foundation.dart';

class PedometerService {
  static StreamSubscription<StepCount>? _stepCountSubscription;
  static StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;
  
  static int _todaySteps = 0;
  static int _sessionSteps = 0;
  static String _status = 'unknown';

  static int get todaySteps => _todaySteps;
  static int get sessionSteps => _sessionSteps;
  static String get status => _status;

  static Future<void> initialize() async {
    // Get initial step count
    try {
      _todaySteps = await Pedometer.stepCountStream.first.then((event) => event.steps);
    } catch (e) {
      debugPrint('Could not get initial step count: $e');
    }
  }

  static void startTracking() {
    // Listen to step count stream
    _stepCountSubscription = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: _onStepCountError,
    );

    // Listen to pedestrian status
    _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
      _onPedestrianStatus,
      onError: _onPedestrianStatusError,
    );
  }

  static void stopTracking() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _stepCountSubscription = null;
    _pedestrianStatusSubscription = null;
  }

  static void _onStepCount(StepCount event) {
    _todaySteps = event.steps;
    _sessionSteps = event.steps;
    debugPrint('Steps: ${event.steps}');
  }

  static void _onStepCountError(error) {
    debugPrint('Step count error: $error');
  }

  static void _onPedestrianStatus(PedestrianStatus event) {
    _status = event.status;
    debugPrint('Pedestrian status: ${event.status}');
  }

  static void _onPedestrianStatusError(error) {
    debugPrint('Pedestrian status error: $error');
  }

  static void resetSession() {
    _sessionSteps = 0;
  }

  static bool get isAvailable {
    return Pedometer.isStepCountingAvailable();
  }
}
