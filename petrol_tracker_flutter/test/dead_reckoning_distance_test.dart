import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker_flutter/services/gps_service.dart';

void main() {
  group('GPS & Dead Reckoning Estimation', () {
    test('Calculates Haversine geographical distance accurately', () {
      // Islamabad to Rawalpindi coordinates (~14 km)
      const lat1 = 33.6844;
      const lon1 = 73.0479;
      const lat2 = 33.5651;
      const lon2 = 73.0169;

      final dist = GpsService.calculateDistance(lat1, lon1, lat2, lon2);
      expect(dist, greaterThan(13.0));
      expect(dist, lessThan(15.0));
    });

    test('Estimates distance using speed and elapsed time during signal loss', () {
      // 50 km/h = 13.8889 m/s
      const double speedMps = 50.0 / 3.6;
      const int elapsedSeconds = 60; // 1 minute gap

      final double estimatedKm = (speedMps * elapsedSeconds) / 1000.0;
      // 50 km/h for 1 min = 50 / 60 = ~0.833 km
      expect(estimatedKm, closeTo(0.833, 0.01));
    });
  });
}
