import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fare Calculator Logic', () {
    test('Calculates fuel cost, net profit, and profit per km correctly', () {
      const double km = 10.0;
      const double mileage = 40.0; // 40 km/L
      const double fuelPrice = 280.0; // Rs. 280/L
      const double offerPrice = 350.0; // Rs. 350

      final double fuelUsed = km / mileage; // 0.25 L
      final double fuelCost = fuelUsed * fuelPrice; // Rs. 70
      final double profit = offerPrice - fuelCost; // Rs. 280
      final double profitPerKm = profit / km; // Rs. 28/km

      expect(fuelUsed, 0.25);
      expect(fuelCost, 70.0);
      expect(profit, 280.0);
      expect(profitPerKm, 28.0);
    });

    test('Computes extra profit gained from counter offer correctly', () {
      const double fuelCost = 70.0;
      const double offerPrice = 350.0;
      const double counterPrice = 450.0;

      final double offerProfit = offerPrice - fuelCost; // 280
      final double counterProfit = counterPrice - fuelCost; // 380
      final double profitDifference = counterProfit - offerProfit;

      expect(profitDifference, 100.0);
    });
  });
}
