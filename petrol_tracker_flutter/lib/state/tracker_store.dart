import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/petrol_entry.dart';
import '../models/trip.dart';
import '../models/ride_entry.dart';
import '../services/storage_service.dart';
import '../services/gps_service.dart';

class EffectiveMileage {
  final double mileage;
  final String source;
  final bool isEstimated;

  EffectiveMileage({
    required this.mileage,
    required this.source,
    required this.isEstimated,
  });
}

class MonthlySummary {
  final double totalLitres;
  final double totalSpent;
  final double totalKm;
  final double avgMileage;

  MonthlySummary({
    required this.totalLitres,
    required this.totalSpent,
    required this.totalKm,
    required this.avgMileage,
  });
}

class RideSummary {
  final int totalRides;
  final double totalRideKm;
  final double totalEarnings;
  final double totalTips;
  final double totalFuelCost;
  final double totalProfit;
  final double avgProfitPerRide;
  final double avgProfitPerKm;

  RideSummary({
    required this.totalRides,
    required this.totalRideKm,
    required this.totalEarnings,
    required this.totalTips,
    required this.totalFuelCost,
    required this.totalProfit,
    required this.avgProfitPerRide,
    required this.avgProfitPerKm,
  });
}

class FareCalculationResult {
  final double km;
  final double fuelUsed;
  final double fuelCost;
  final double costPerKm;
  final double offerPrice;
  final double offerProfit;
  final double offerProfitPerKm;
  final double myPrice;
  final double myProfit;
  final double myProfitPerKm;
  final double priceDifference;
  final double profitDifference;
  final String mileageSource;
  final double mileageValue;
  final bool isEstimated;

  FareCalculationResult({
    required this.km,
    required this.fuelUsed,
    required this.fuelCost,
    required this.costPerKm,
    required this.offerPrice,
    required this.offerProfit,
    required this.offerProfitPerKm,
    required this.myPrice,
    required this.myProfit,
    required this.myProfitPerKm,
    required this.priceDifference,
    required this.profitDifference,
    required this.mileageSource,
    required this.mileageValue,
    required this.isEstimated,
  });
}

class TrackerStore extends ChangeNotifier {
  static final TrackerStore instance = TrackerStore._internal();

  final StorageService _storageService = StorageService();
  final GpsService _gpsService = GpsService();

  TrackerStore._internal() {
    _initGpsCallbacks();
    loadPersistedData();
  }

  // Active Screen
  String activeScreen = 'dashboard';

  // Core Data
  List<PetrolEntry> petrolEntries = [];
  List<Trip> trips = [];
  Trip? currentTrip;
  double totalKmSinceLastFill = 0.0;
  List<RideEntry> rideEntries = [];

  // Reserve Tracking
  bool reserveActive = false;
  double reserveStartDistance = 0.0;
  double manualReserveDistance = 0.0;
  String fallbackReserveDistance = '';

  // GPS Tracking State
  bool isTracking = false;
  double smoothSpeed = 0.0;
  String gpsMessage = '';
  bool showGpsAlert = false;
  Timer? _alertTimer;
  GpsDebugInfo gpsDebug = GpsDebugInfo();

  // Signal-Loss Estimation
  bool gpsSignalLost = false;
  DateTime? signalLostAt;
  double estimatedDistance = 0.0;
  double totalEstimatedKm = 0.0;
  bool hasEstimatedSegment = false;

  // Post-trip ride dialog
  bool showRideCompletionDialog = false;
  double completedRideKm = 0.0;

  // Search & Filter
  String historySearchTerm = '';
  String historyFilter = '5-fill'; // '5-fill' or 'all'
  String earningsView = 'daily'; // 'daily' or 'all'
  String? expandedDay;

  // Fare Calculator
  String calcKm = '';
  String calcOffer = '';
  String calcMyPrice = '';
  FareCalculationResult? fareResult;

  void _initGpsCallbacks() {
    _gpsService.onDistanceAdded = (dist) {
      if (currentTrip != null) {
        currentTrip = currentTrip!.copyWith(
          distance: currentTrip!.distance + dist,
        );
      }
      totalKmSinceLastFill += dist;
      notifyListeners();
      _debouncedSave();
    };

    _gpsService.onSpeedChanged = (speed) {
      smoothSpeed = speed;
      notifyListeners();
    };

    _gpsService.onStatusMessage = (msg, isError) {
      showToastMessage(msg, isError: isError);
    };

    _gpsService.onDebugInfoChanged = (info) {
      gpsDebug = info;
      notifyListeners();
    };

    _gpsService.onSignalLossUpdated = (lost, estDist) {
      gpsSignalLost = lost;
      estimatedDistance = estDist;
      if (lost) {
        hasEstimatedSegment = true;
      }
      notifyListeners();
    };
  }

  Future<void> loadPersistedData() async {
    final data = await _storageService.loadData();
    petrolEntries = data.petrolEntries;
    trips = data.trips;
    currentTrip = data.currentTrip;
    totalKmSinceLastFill = data.totalKmSinceLastFill;
    rideEntries = data.rideEntries;
    reserveActive = data.reserveActive;
    reserveStartDistance = data.reserveStartDistance;
    manualReserveDistance = data.manualReserveDistance;
    fallbackReserveDistance = data.fallbackReserveDistance;
    notifyListeners();
  }

  Timer? _saveDebounceTimer;
  void _debouncedSave() {
    _saveDebounceTimer?.cancel();
    _saveDebounceTimer = Timer(const Duration(seconds: 1), () {
      _saveCurrentState();
    });
  }

  Future<void> _saveCurrentState() async {
    final data = StorageData(
      petrolEntries: petrolEntries,
      trips: trips,
      currentTrip: currentTrip,
      totalKmSinceLastFill: totalKmSinceLastFill,
      rideEntries: rideEntries,
      reserveActive: reserveActive,
      reserveStartDistance: reserveStartDistance,
      manualReserveDistance: manualReserveDistance,
      fallbackReserveDistance: fallbackReserveDistance,
    );
    await _storageService.saveData(data);
  }

  void setActiveScreen(String screen) {
    activeScreen = screen;
    notifyListeners();
  }

  void showToastMessage(String message, {bool isError = false}) {
    gpsMessage = message;
    showGpsAlert = true;
    notifyListeners();

    _alertTimer?.cancel();
    if (!isError) {
      _alertTimer = Timer(const Duration(seconds: 3), () {
        showGpsAlert = false;
        notifyListeners();
      });
    }
  }

  void dismissAlert() {
    showGpsAlert = false;
    notifyListeners();
  }

  // ==========================================
  // MILEAGE & CALCULATIONS
  // ==========================================

  double calculateRollingAverage([List<PetrolEntry>? list, int windowSize = MileageConfig.rollingWindow]) {
    final entries = list ?? petrolEntries;
    if (entries.isEmpty) return 0.0;
    final recent = entries.sublist(0, math.min(windowSize, entries.length));
    final totalDistance = recent.fold<double>(0.0, (sum, entry) => sum + (entry.mainTankDistance > 0 ? entry.mainTankDistance : entry.kmTraveled));
    final totalLitres = recent.fold<double>(0.0, (sum, entry) => sum + entry.litres);
    return totalLitres > 0 ? totalDistance / totalLitres : 0.0;
  }

  double calculateAllTimeAverage([List<PetrolEntry>? list]) {
    final entries = list ?? petrolEntries;
    if (entries.isEmpty) return 0.0;
    final totalDistance = entries.fold<double>(0.0, (sum, entry) => sum + (entry.mainTankDistance > 0 ? entry.mainTankDistance : entry.kmTraveled));
    final totalLitres = entries.fold<double>(0.0, (sum, entry) => sum + entry.litres);
    return totalLitres > 0 ? totalDistance / totalLitres : 0.0;
  }

  EffectiveMileage getEffectiveMileage() {
    if (petrolEntries.isEmpty) {
      return EffectiveMileage(mileage: 0.0, source: 'none', isEstimated: false);
    }
    final lastEntry = petrolEntries[0];
    final rollingAvg = calculateRollingAverage();
    final lastTankDistance = lastEntry.mainTankDistance > 0 ? lastEntry.mainTankDistance : lastEntry.kmTraveled;
    final shouldUseFallback = lastTankDistance < MileageConfig.minDistanceThreshold;

    if (shouldUseFallback && rollingAvg > 0 && petrolEntries.length >= 2) {
      return EffectiveMileage(
        mileage: rollingAvg,
        source: 'rolling-average',
        isEstimated: true,
      );
    }

    final lastTankMileage = lastEntry.mileage > 0
        ? lastEntry.mileage
        : (lastEntry.litres > 0 && lastTankDistance > 0 ? lastTankDistance / lastEntry.litres : 0.0);

    return EffectiveMileage(
      mileage: lastTankMileage,
      source: 'last-tank',
      isEstimated: false,
    );
  }

  MonthlySummary getMonthlySummary() {
    final now = DateTime.now();
    double totalLitres = 0.0;
    double totalSpent = 0.0;
    double totalKm = 0.0;

    for (final entry in petrolEntries) {
      try {
        final d = DateTime.parse(entry.date);
        if (d.month == now.month && d.year == now.year) {
          totalLitres += entry.litres;
          totalSpent += entry.totalCost;
          if (entry.kmTraveled > 0) {
            totalKm += entry.kmTraveled;
          }
        }
      } catch (_) {}
    }

    if (totalKmSinceLastFill > 0) {
      totalKm += totalKmSinceLastFill;
    }

    final avg = totalLitres > 0 ? totalKm / totalLitres : 0.0;
    return MonthlySummary(
      totalLitres: totalLitres,
      totalSpent: totalSpent,
      totalKm: totalKm,
      avgMileage: avg,
    );
  }

  RideSummary getRideSummary() {
    final now = DateTime.now();
    int totalRides = 0;
    double totalRideKm = 0.0;
    double totalEarnings = 0.0;
    double totalTips = 0.0;
    double totalFuelCost = 0.0;
    double totalProfit = 0.0;

    for (final ride in rideEntries) {
      try {
        final d = DateTime.parse(ride.date);
        if (d.month == now.month && d.year == now.year) {
          totalRides++;
          totalRideKm += ride.km;
          totalEarnings += ride.totalEarnings;
          totalTips += ride.tip;
          totalFuelCost += ride.fuelCost;
          totalProfit += ride.profit;
        }
      } catch (_) {}
    }

    final avgProfitPerRide = totalRides > 0 ? totalProfit / totalRides : 0.0;
    final avgProfitPerKm = totalRideKm > 0 ? totalProfit / totalRideKm : 0.0;

    return RideSummary(
      totalRides: totalRides,
      totalRideKm: totalRideKm,
      totalEarnings: totalEarnings,
      totalTips: totalTips,
      totalFuelCost: totalFuelCost,
      totalProfit: totalProfit,
      avgProfitPerRide: avgProfitPerRide,
      avgProfitPerKm: avgProfitPerKm,
    );
  }

  // ==========================================
  // ACTIONS: PETROL REFUEL
  // ==========================================

  void savePetrolEntry({
    required double litres,
    required double pricePerLitre,
    required String date,
    double fallbackReserve = 0.0,
  }) {
    final roundedLitres = (litres * 100).round() / 100.0;
    final roundedPrice = (pricePerLitre * 100).round() / 100.0;

    double liveReserve = reserveActive ? (totalKmSinceLastFill - reserveStartDistance) : 0.0;
    if (liveReserve < 0) liveReserve = 0.0;

    double calculatedReserve = liveReserve + manualReserveDistance + fallbackReserve;
    if (calculatedReserve > totalKmSinceLastFill) {
      calculatedReserve = totalKmSinceLastFill;
    }

    final mainTankDistance = totalKmSinceLastFill - calculatedReserve;
    final tankMileage = mainTankDistance > 0 && roundedLitres > 0 ? mainTankDistance / roundedLitres : 0.0;
    final isShortTank = mainTankDistance < MileageConfig.minDistanceThreshold && mainTankDistance > 0;

    final entry = PetrolEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      litres: roundedLitres,
      pricePerLitre: roundedPrice,
      totalCost: roundedLitres * roundedPrice,
      date: date,
      kmTraveled: totalKmSinceLastFill,
      mainTankDistance: mainTankDistance,
      reserveDistance: calculatedReserve,
      mileage: double.parse(tankMileage.toStringAsFixed(2)),
      isEstimated: isShortTank,
      createdAt: DateTime.now().toIso8601String(),
    );

    petrolEntries.insert(0, entry);
    totalKmSinceLastFill = 0.0;
    trips.clear();
    reserveActive = false;
    reserveStartDistance = 0.0;
    manualReserveDistance = 0.0;
    fallbackReserveDistance = '';

    _saveCurrentState();
    notifyListeners();
  }

  // ==========================================
  // ACTIONS: RESERVE TRACKING
  // ==========================================

  void toggleReserveMode() {
    if (!reserveActive) {
      reserveActive = true;
      reserveStartDistance = totalKmSinceLastFill;
      showToastMessage('⚠️ Switched to Reserve Fuel Mode');
    } else {
      reserveActive = false;
      reserveStartDistance = 0.0;
      showToastMessage('✅ Switched to Main Tank');
    }
    _debouncedSave();
    notifyListeners();
  }

  void addManualReserve(double km) {
    final rounded = (km * 100).round() / 100.0;
    manualReserveDistance += rounded;
    _debouncedSave();
    notifyListeners();
  }

  // ==========================================
  // ACTIONS: MANUAL KM
  // ==========================================

  void addManualKm(double km) {
    final rounded = (km * 100).round() / 100.0;
    totalKmSinceLastFill += rounded;

    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      distance: rounded,
      isActive: false,
      isRide: false,
      earnings: 0.0,
      isManual: true,
    );

    trips.add(trip);
    _debouncedSave();
    notifyListeners();
  }

  // ==========================================
  // ACTIONS: MANUAL RIDE ENTRY
  // ==========================================

  void addManualRide({
    required double km,
    required double earnings,
    required double tip,
  }) {
    final roundedKm = (km * 100).round() / 100.0;
    final roundedEarnings = (earnings * 100).round() / 100.0;
    final roundedTip = (tip * 100).round() / 100.0;

    final effMileage = getEffectiveMileage();
    double costPerKm = 0.0;
    double fuelUsed = 0.0;
    double fuelCost = 0.0;

    if (petrolEntries.isNotEmpty && effMileage.mileage > 0) {
      final lastEntry = petrolEntries[0];
      fuelUsed = roundedKm / effMileage.mileage;
      fuelCost = fuelUsed * lastEntry.pricePerLitre;
      costPerKm = lastEntry.pricePerLitre / effMileage.mileage;
    }

    final totalEarnings = roundedEarnings + roundedTip;
    final profit = totalEarnings - fuelCost;
    final profitPerKm = roundedKm > 0 ? profit / roundedKm : 0.0;

    final ride = RideEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now().toIso8601String(),
      km: roundedKm,
      earnings: roundedEarnings,
      tip: roundedTip,
      totalEarnings: totalEarnings,
      fuelUsed: fuelUsed,
      fuelCost: fuelCost,
      profit: profit,
      profitPerKm: profitPerKm,
      costPerKm: costPerKm,
      mileageUsed: effMileage.mileage,
      mileageSource: effMileage.source,
    );

    rideEntries.insert(0, ride);
    totalKmSinceLastFill += roundedKm;

    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch,
      startTime: DateTime.now().toIso8601String(),
      endTime: DateTime.now().toIso8601String(),
      distance: roundedKm,
      isActive: false,
      isRide: true,
      earnings: totalEarnings,
      isManual: true,
    );

    trips.add(trip);
    _debouncedSave();
    notifyListeners();
  }

  // ==========================================
  // ACTIONS: GPS TRIPS
  // ==========================================

  Future<void> startGpsTrip({required bool isRide}) async {
    isTracking = true;
    gpsSignalLost = false;
    signalLostAt = null;
    estimatedDistance = 0.0;
    totalEstimatedKm = 0.0;
    hasEstimatedSegment = false;

    currentTrip = Trip(
      id: DateTime.now().millisecondsSinceEpoch,
      startTime: DateTime.now().toIso8601String(),
      endTime: '',
      distance: 0.0,
      isActive: true,
      isRide: isRide,
      earnings: 0.0,
      isManual: false,
    );

    notifyListeners();
    await _gpsService.startTracking(isRide: isRide);
  }

  Future<void> stopGpsTrip() async {
    await _gpsService.stopTracking();

    if (currentTrip != null) {
      double actualKm = currentTrip!.distance;
      bool finalHasEst = hasEstimatedSegment;
      double finalEstKm = totalEstimatedKm;

      if (gpsSignalLost && estimatedDistance > 0) {
        actualKm += estimatedDistance;
        finalHasEst = true;
        finalEstKm += estimatedDistance;
        totalKmSinceLastFill += estimatedDistance;
      }

      gpsSignalLost = false;
      estimatedDistance = 0.0;

      if (currentTrip!.isRide) {
        completedRideKm = actualKm;
        showRideCompletionDialog = true;
        isTracking = false;
        notifyListeners();
      } else {
        final completedTrip = currentTrip!.copyWith(
          distance: actualKm,
          endTime: DateTime.now().toIso8601String(),
          isActive: false,
          hasEstimatedSegment: finalHasEst,
          estimatedKm: finalEstKm,
        );
        trips.add(completedTrip);
        currentTrip = null;
        isTracking = false;
        showToastMessage('⏸️ Personal Trip Stopped');
        notifyListeners();
        _saveCurrentState();
      }
    } else {
      isTracking = false;
      notifyListeners();
    }
  }

  void completeRideWithEarnings({
    required double earnings,
    required double tip,
  }) {
    final roundedEarnings = (earnings * 100).round() / 100.0;
    final roundedTip = (tip * 100).round() / 100.0;
    final actualKm = completedRideKm;

    final effMileage = getEffectiveMileage();
    double costPerKm = 0.0;
    double fuelUsed = 0.0;
    double fuelCost = 0.0;

    if (petrolEntries.isNotEmpty && effMileage.mileage > 0) {
      final lastEntry = petrolEntries[0];
      fuelUsed = actualKm / effMileage.mileage;
      fuelCost = fuelUsed * lastEntry.pricePerLitre;
      costPerKm = lastEntry.pricePerLitre / effMileage.mileage;
    }

    final totalEarnings = roundedEarnings + roundedTip;
    final profit = totalEarnings - fuelCost;
    final profitPerKm = actualKm > 0 ? profit / actualKm : 0.0;

    final ride = RideEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      date: DateTime.now().toIso8601String(),
      km: actualKm,
      earnings: roundedEarnings,
      tip: roundedTip,
      totalEarnings: totalEarnings,
      fuelUsed: fuelUsed,
      fuelCost: fuelCost,
      profit: profit,
      profitPerKm: profitPerKm,
      costPerKm: costPerKm,
      mileageUsed: effMileage.mileage,
      mileageSource: effMileage.source,
      hasEstimatedSegment: hasEstimatedSegment,
      estimatedKm: totalEstimatedKm,
    );

    rideEntries.insert(0, ride);

    if (currentTrip != null) {
      final completedTrip = currentTrip!.copyWith(
        distance: actualKm,
        endTime: DateTime.now().toIso8601String(),
        isActive: false,
        earnings: totalEarnings,
        hasEstimatedSegment: hasEstimatedSegment,
        estimatedKm: totalEstimatedKm,
      );
      trips.add(completedTrip);
    }

    currentTrip = null;
    showRideCompletionDialog = false;
    completedRideKm = 0.0;

    _saveCurrentState();
    notifyListeners();
  }

  void cancelRideCompletion() {
    if (currentTrip != null) {
      final completedTrip = currentTrip!.copyWith(
        endTime: DateTime.now().toIso8601String(),
        isActive: false,
      );
      trips.add(completedTrip);
    }
    currentTrip = null;
    showRideCompletionDialog = false;
    completedRideKm = 0.0;
    _saveCurrentState();
    notifyListeners();
  }

  // ==========================================
  // FARE CALCULATOR
  // ==========================================

  void runFareCalculation({
    required double km,
    required double offerPrice,
    double? myPrice,
  }) {
    final effMileage = getEffectiveMileage();
    double costPerKm = 0.0;
    double fuelUsed = 0.0;
    double fuelCost = 0.0;

    if (petrolEntries.isNotEmpty && effMileage.mileage > 0) {
      final lastEntry = petrolEntries[0];
      fuelUsed = km / effMileage.mileage;
      fuelCost = fuelUsed * lastEntry.pricePerLitre;
      costPerKm = lastEntry.pricePerLitre / effMileage.mileage;
    } else {
      costPerKm = MileageConfig.fallbackCostPerKm;
      fuelCost = km * costPerKm;
    }

    final offerProfit = offerPrice - fuelCost;
    final offerProfitPerKm = km > 0 ? offerProfit / km : 0.0;

    double myProfit = 0.0;
    double myProfitPerKm = 0.0;
    double priceDiff = 0.0;
    double profitDiff = 0.0;

    if (myPrice != null && myPrice > 0) {
      myProfit = myPrice - fuelCost;
      myProfitPerKm = km > 0 ? myProfit / km : 0.0;
      priceDiff = myPrice - offerPrice;
      profitDiff = myProfit - offerProfit;
    }

    fareResult = FareCalculationResult(
      km: km,
      fuelUsed: fuelUsed,
      fuelCost: fuelCost,
      costPerKm: costPerKm,
      offerPrice: offerPrice,
      offerProfit: offerProfit,
      offerProfitPerKm: offerProfitPerKm,
      myPrice: myPrice ?? 0.0,
      myProfit: myProfit,
      myProfitPerKm: myProfitPerKm,
      priceDifference: priceDiff,
      profitDifference: profitDiff,
      mileageSource: effMileage.source,
      mileageValue: effMileage.mileage,
      isEstimated: effMileage.isEstimated,
    );

    notifyListeners();
  }

  void clearFareCalculator() {
    calcKm = '';
    calcOffer = '';
    calcMyPrice = '';
    fareResult = null;
    notifyListeners();
  }

  // ==========================================
  // DATA RESET & EXPORT
  // ==========================================

  Future<void> confirmResetAllData() async {
    await _gpsService.stopTracking();
    petrolEntries.clear();
    trips.clear();
    currentTrip = null;
    totalKmSinceLastFill = 0.0;
    rideEntries.clear();
    reserveActive = false;
    reserveStartDistance = 0.0;
    manualReserveDistance = 0.0;
    fallbackReserveDistance = '';
    isTracking = false;
    smoothSpeed = 0.0;
    gpsSignalLost = false;
    estimatedDistance = 0.0;
    totalEstimatedKm = 0.0;
    hasEstimatedSegment = false;
    fareResult = null;

    await _storageService.clearAll();
    showToastMessage('✅ All data reset successfully!');
    activeScreen = 'dashboard';
    notifyListeners();
  }

  Future<String?> exportDataBackup() async {
    final data = StorageData(
      petrolEntries: petrolEntries,
      trips: trips,
      currentTrip: currentTrip,
      totalKmSinceLastFill: totalKmSinceLastFill,
      rideEntries: rideEntries,
      reserveActive: reserveActive,
      reserveStartDistance: reserveStartDistance,
      manualReserveDistance: manualReserveDistance,
      fallbackReserveDistance: fallbackReserveDistance,
    );
    return await _storageService.exportToJsonFile(data);
  }
}
