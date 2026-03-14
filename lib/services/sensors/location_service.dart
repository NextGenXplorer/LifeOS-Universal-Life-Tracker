import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static Position? _lastPosition;
  static bool _isTracking = false;
  static List<Position> _positionHistory = [];

  static Position? get lastPosition => _lastPosition;
  static bool get isTracking => _isTracking;
  static List<Position> get positionHistory => _positionHistory;

  static Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkPermission();
      if (!hasPermission) return null;

      _lastPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      
      if (_lastPosition != null) {
        _positionHistory.add(_lastPosition!);
      }
      
      return _lastPosition;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  static Future<void> startTracking({
    Function(Position)? onPositionUpdate,
    int distanceFilter = 10,
  }) async {
    if (_isTracking) return;

    final hasPermission = await checkPermission();
    if (!hasPermission) return;

    _isTracking = true;

    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: distanceFilter,
      ),
    ).listen((Position position) {
      _lastPosition = position;
      _positionHistory.add(position);
      onPositionUpdate?.call(position);
    });
  }

  static void stopTracking() {
    _isTracking = false;
  }

  static double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  static double calculateBearing(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  static Future<bool> isInGeofence(double centerLat, double centerLng, double radiusMeters) async {
    final position = await getCurrentPosition();
    if (position == null) return false;

    final distance = calculateDistance(
      centerLat,
      centerLng,
      position.latitude,
      position.longitude,
    );

    return distance <= radiusMeters;
  }

  static void clearHistory() {
    _positionHistory.clear();
  }
}
