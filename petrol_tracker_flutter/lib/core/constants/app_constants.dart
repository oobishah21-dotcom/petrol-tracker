class MileageConfig {
  static const double minDistanceThreshold = 20.0; // km - minimum distance to trust single-tank mileage
  static const int rollingWindow = 5; // number of recent fills to average
  static const bool enableAllTimeAvg = true; // show long-term average stat
  static const double defaultFuelPrice = 272.0; // PKR fallback price
  static const double defaultMileage = 45.0; // km/L fallback mileage
  static const double fallbackCostPerKm = 15.0; // PKR/km fallback for calculator
}
