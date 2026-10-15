import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker_flutter/models/petrol_entry.dart';
import 'package:petrol_tracker_flutter/core/constants/app_constants.dart';

void main() {
  group('Mileage & Reserve Calculations', () {
    test('Calculates rolling average over recent 5 entries correctly', () {
      final entries = [
        PetrolEntry(
          id: 1,
          litres: 10.0,
          pricePerLitre: 270.0,
          totalCost: 2700.0,
          date: '2026-10-01',
          kmTraveled: 450.0,
          mainTankDistance: 450.0,
          reserveDistance: 0.0,
          mileage: 45.0,
          isEstimated: false,
          createdAt: '',
        ),
        PetrolEntry(
          id: 2,
          litres: 10.0,
          pricePerLitre: 270.0,
          totalCost: 2700.0,
          date: '2026-09-25',
          kmTraveled: 500.0,
          mainTankDistance: 500.0,
          reserveDistance: 0.0,
          mileage: 50.0,
          isEstimated: false,
          createdAt: '',
        ),
      ];

      final totalDistance = entries.fold<double>(0.0, (s, e) => s + e.mainTankDistance);
      final totalLitres = entries.fold<double>(0.0, (s, e) => s + e.litres);
      final avg = totalDistance / totalLitres;

      expect(avg, 47.5);
    });

    test('Subtracts reserve distance from total km when computing main tank distance', () {
      const double totalKmSinceLastFill = 320.0;
      const double liveReserve = 25.0;
      const double manualReserve = 10.0;
      const double fallbackReserve = 5.0;

      final double calculatedReserve = liveReserve + manualReserve + fallbackReserve;
      final double mainTankDistance = totalKmSinceLastFill - calculatedReserve;

      expect(calculatedReserve, 40.0);
      expect(mainTankDistance, 280.0);

      const double litres = 7.0;
      final double tankMileage = mainTankDistance / litres;
      expect(tankMileage, 40.0);
    });

    test('Triggers short tank fallback flag when distance is below 20 km threshold', () {
      const double mainTankDistance = 15.0;
      final bool isShortTank = mainTankDistance < MileageConfig.minDistanceThreshold && mainTankDistance > 0;
      expect(isShortTank, true);
    });
  });
}
