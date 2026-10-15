import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';

class GpsDebugInfo {
  final int updates;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed; // km/h
  final String status;
  final double lastDistanceMeters;

  GpsDebugInfo({
    this.updates = 0,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.accuracy = 0.0,
    this.speed = 0.0,
    this.status = 'Not started',
    this.lastDistanceMeters = 0.0,
  });

  GpsDebugInfo copyWith({
    int? updates,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? speed,
    String? status,
    double? lastDistanceMeters,
  }) {
    return GpsDebugInfo(
      updates: updates ?? this.updates,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      lastDistanceMeters: lastDistanceMeters ?? this.lastDistanceMeters,
    );
  }
}

class GpsService {
  StreamSubscription<Position>? _positionStream;
  Position? _lastPosition;
  final List<Position> _recentPositions = [];
  int _updateCount = 0;
  bool _isFirstPosition = true;

  // Signal-loss estimation state
  bool isSignalLost = false;
  DateTime? signalLostAt;
  double lastKnownSpeedMps = 0.0;
  double estimatedDistanceKm = 0.0;
  Timer? _estimationTimer;
  int _consecutiveTimeouts = 0;

  GpsDebugInfo debugInfo = GpsDebugInfo();

  // Callbacks
  Function(double distanceKm)? onDistanceAdded;
  Function(double speedKmh)? onSpeedChanged;
  Function(String message, bool isError)? onStatusMessage;
  Function(GpsDebugInfo info)? onDebugInfoChanged;
  Function(bool signalLost, double estimatedKm)? onSignalLossUpdated;

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0; // km
    final dLat = (lat2 - lat1) * (math.pi / 180.0);
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * (math.pi / 180.0)) *
            math.cos(lat2 * (math.pi / 180.0)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  Future<bool> requestAndCheckPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      onStatusMessage?.call('❌ Location services are turned off. Please turn on Location in Settings.', true);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        onStatusMessage?.call('❌ Location permission denied. Please grant location access.', true);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      onStatusMessage?.call('❌ Location permission permanently denied. Open App Settings to enable.', true);
      return false;
    }

    return true;
  }

  Future<void> startTracking({required bool isRide}) async {
    final hasPerm = await requestAndCheckPermissions();
    if (!hasPerm) return;

    await stopTracking();

    _updateCount = 0;
    _isFirstPosition = true;
    _lastPosition = null;
    _recentPositions.clear();
    isSignalLost = false;
    signalLostAt = null;
    lastKnownSpeedMps = 0.0;
    estimatedDistanceKm = 0.0;
    _consecutiveTimeouts = 0;

    debugInfo = GpsDebugInfo(
      status: 'Searching GPS...',
      updates: 0,
    );
    onDebugInfoChanged?.call(debugInfo);
    onStatusMessage?.call('📡 Initializing GPS (${isRide ? "Ride" : "Personal"} - High Accuracy)...', false);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 3,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) => _handlePosition(position, isRide),
      onError: (error) => _handleError(error),
    );
  }

  void _handlePosition(Position position, bool isRide) {
    _updateCount++;
    final accuracy = position.accuracy;

    // Accuracy guard: wait until 5 meters or better to prevent phantom drift
    if (accuracy > 5.0) {
      debugInfo = debugInfo.copyWith(
        updates: _updateCount,
        accuracy: accuracy,
        status: 'Waiting for GPS lock... (${accuracy.toStringAsFixed(0)}m)',
      );
      onDebugInfoChanged?.call(debugInfo);
      return;
    }

    _recentPositions.add(position);
    if (_recentPositions.length > 3) {
      _recentPositions.removeAt(0);
    }

    // Determine speed
    double speedMps = position.speed;
    if (speedMps <= 0.0 && _recentPositions.length >= 2) {
      final prev = _recentPositions[_recentPositions.length - 2];
      final distKm = calculateDistance(prev.latitude, prev.longitude, position.latitude, position.longitude);
      final timeDiffSec = position.timestamp.difference(prev.timestamp).inMilliseconds / 1000.0;
      if (timeDiffSec > 0) {
        speedMps = (distKm * 1000.0) / timeDiffSec;
      }
    }

    if (speedMps >= 0) {
      lastKnownSpeedMps = speedMps;
    }

    final speedKmh = speedMps * 3.6;
    onSpeedChanged?.call(speedKmh);

    // Reconnection from signal loss
    if (isSignalLost) {
      _estimationTimer?.cancel();
      _estimationTimer = null;
      isSignalLost = false;

      final addedDist = estimatedDistanceKm;
      if (addedDist > 0) {
        onDistanceAdded?.call(addedDist);
        onStatusMessage?.call('✅ GPS reconnected — added ~${addedDist.toStringAsFixed(2)} km estimated during signal loss', false);
      }

      estimatedDistanceKm = 0.0;
      signalLostAt = null;
      _consecutiveTimeouts = 0;
      onSignalLossUpdated?.call(false, 0.0);

      _lastPosition = position;
      return;
    }

    if (_isFirstPosition) {
      _lastPosition = position;
      _isFirstPosition = false;
      final tripType = isRide ? '🚖 Ride' : '🏍️ Personal';
      onStatusMessage?.call('🟢 GPS Active ($tripType - High Accuracy)', false);
      debugInfo = debugInfo.copyWith(
        updates: _updateCount,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: accuracy,
        speed: speedKmh,
        status: 'Active ✔',
      );
      onDebugInfoChanged?.call(debugInfo);
      return;
    }

    if (_lastPosition != null) {
      final distanceKm = calculateDistance(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      final distanceMeters = distanceKm * 1000.0;

      // Filter stationary jitter
      bool shouldUpdate = false;
      if (distanceMeters < 3.0) {
        shouldUpdate = false;
      } else if (speedMps < 0.5) {
        shouldUpdate = distanceMeters >= 2.0;
      } else {
        shouldUpdate = true;
      }

      if (shouldUpdate) {
        onDistanceAdded?.call(distanceKm);
        _lastPosition = position;
        debugInfo = debugInfo.copyWith(
          updates: _updateCount,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: accuracy,
          speed: speedKmh,
          status: 'Active ✔',
          lastDistanceMeters: distanceMeters,
        );
      } else {
        debugInfo = debugInfo.copyWith(
          updates: _updateCount,
          accuracy: accuracy,
          speed: speedKmh,
          lastDistanceMeters: 0.0,
        );
      }
      onDebugInfoChanged?.call(debugInfo);
    } else {
      _lastPosition = position;
    }
  }

  void _handleError(dynamic error) {
    final errStr = error.toString().toLowerCase();
    bool isUnavailable = errStr.contains('unavailable');
    bool isTimeout = errStr.contains('timeout');

    if (isTimeout) {
      _consecutiveTimeouts++;
    } else if (isUnavailable) {
      _consecutiveTimeouts = 2;
    }

    if (isUnavailable || _consecutiveTimeouts >= 2) {
      if (lastKnownSpeedMps > 0.0) {
        if (!isSignalLost) {
          isSignalLost = true;
          signalLostAt = DateTime.now();
          _startEstimationTimer(signalLostAt!);
        }
        debugInfo = debugInfo.copyWith(status: 'Signal Lost');
        onStatusMessage?.call('📡 GPS Signal Lost — estimating distance using last known speed ${(lastKnownSpeedMps * 3.6).toStringAsFixed(1)} km/h', true);
      } else {
        debugInfo = debugInfo.copyWith(status: 'No Signal');
        onStatusMessage?.call('⚠️ GPS lost — speed unknown, cannot estimate distance.', true);
      }
    } else {
      debugInfo = debugInfo.copyWith(status: 'Searching...');
    }
    onDebugInfoChanged?.call(debugInfo);
  }

  void _startEstimationTimer(DateTime lossTime) {
    _estimationTimer?.cancel();
    _estimationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      final elapsedSec = DateTime.now().difference(lossTime).inSeconds;
      if (elapsedSec > 300) {
        timer.cancel();
        _estimationTimer = null;
        return;
      }
      estimatedDistanceKm = (lastKnownSpeedMps * elapsedSec) / 1000.0;
      onSignalLossUpdated?.call(true, estimatedDistanceKm);
    });
  }

  Future<void> stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _estimationTimer?.cancel();
    _estimationTimer = null;
    _lastPosition = null;
    _isFirstPosition = true;
    _recentPositions.clear();
    isSignalLost = false;
    signalLostAt = null;
    estimatedDistanceKm = 0.0;
    debugInfo = debugInfo.copyWith(status: 'Stopped', speed: 0.0);
    onDebugInfoChanged?.call(debugInfo);
  }
}
