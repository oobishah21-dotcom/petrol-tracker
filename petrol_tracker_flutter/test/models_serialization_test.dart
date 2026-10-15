import 'package:flutter_test/flutter_test.dart';
import 'package:petrol_tracker_flutter/models/petrol_entry.dart';
import 'package:petrol_tracker_flutter/models/trip.dart';
import 'package:petrol_tracker_flutter/models/ride_entry.dart';

void main() {
  group('Models JSON Serialization', () {
    test('PetrolEntry serializes and deserializes correctly', () {
      final entry = PetrolEntry(
        id: 12345,
        litres: 8.5,
        pricePerLitre: 272.0,
        totalCost: 2312.0,
        date: '2026-10-14',
        kmTraveled: 380.0,
        mainTankDistance: 360.0,
        reserveDistance: 20.0,
        mileage: 42.35,
        isEstimated: false,
        createdAt: '2026-10-14T08:00:00Z',
      );

      final json = entry.toJson();
      final fromJson = PetrolEntry.fromJson(json);

      expect(fromJson.id, 12345);
      expect(fromJson.litres, 8.5);
      expect(fromJson.mainTankDistance, 360.0);
      expect(fromJson.reserveDistance, 20.0);
      expect(fromJson.mileage, 42.35);
    });

    test('Trip serializes and deserializes correctly', () {
      final trip = Trip(
        id: 999,
        startTime: '2026-10-14T08:00:00Z',
        endTime: '2026-10-14T08:30:00Z',
        distance: 14.8,
        isActive: false,
        isRide: true,
        earnings: 450.0,
        isManual: false,
        hasEstimatedSegment: true,
        estimatedKm: 1.2,
      );

      final json = trip.toJson();
      final fromJson = Trip.fromJson(json);

      expect(fromJson.id, 999);
      expect(fromJson.distance, 14.8);
      expect(fromJson.isRide, true);
      expect(fromJson.hasEstimatedSegment, true);
      expect(fromJson.estimatedKm, 1.2);
    });

    test('RideEntry serializes and deserializes correctly', () {
      final ride = RideEntry(
        id: 555,
        date: '2026-10-14',
        km: 12.0,
        earnings: 300.0,
        tip: 50.0,
        totalEarnings: 350.0,
        fuelUsed: 0.3,
        fuelCost: 81.6,
        profit: 268.4,
        profitPerKm: 22.37,
        costPerKm: 6.8,
        mileageUsed: 40.0,
        mileageSource: 'last-tank',
      );

      final json = ride.toJson();
      final fromJson = RideEntry.fromJson(json);

      expect(fromJson.id, 555);
      expect(fromJson.totalEarnings, 350.0);
      expect(fromJson.profit, 268.4);
      expect(fromJson.tip, 50.0);
    });
  });
}
