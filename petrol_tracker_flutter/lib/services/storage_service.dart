import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/petrol_entry.dart';
import '../models/trip.dart';
import '../models/ride_entry.dart';

class StorageData {
  final List<PetrolEntry> petrolEntries;
  final List<Trip> trips;
  final Trip? currentTrip;
  final double totalKmSinceLastFill;
  final List<RideEntry> rideEntries;
  final bool reserveActive;
  final double reserveStartDistance;
  final double manualReserveDistance;
  final String fallbackReserveDistance;

  StorageData({
    required this.petrolEntries,
    required this.trips,
    this.currentTrip,
    required this.totalKmSinceLastFill,
    required this.rideEntries,
    required this.reserveActive,
    required this.reserveStartDistance,
    required this.manualReserveDistance,
    required this.fallbackReserveDistance,
  });
}

class StorageService {
  static const String _key = 'petrolTrackerData';

  Future<StorageData> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return StorageData(
        petrolEntries: [],
        trips: [],
        currentTrip: null,
        totalKmSinceLastFill: 0.0,
        rideEntries: [],
        reserveActive: false,
        reserveStartDistance: 0.0,
        manualReserveDistance: 0.0,
        fallbackReserveDistance: '',
      );
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      final petrolEntries = (data['petrolEntries'] as List? ?? [])
          .map((item) => PetrolEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      final trips = (data['trips'] as List? ?? [])
          .map((item) => Trip.fromJson(item as Map<String, dynamic>))
          .toList();

      Trip? currentTrip;
      if (data['currentTrip'] != null) {
        currentTrip = Trip.fromJson(data['currentTrip'] as Map<String, dynamic>);
      }

      final totalKm = (data['totalKmSinceLastFill'] as num?)?.toDouble() ?? 0.0;

      // Filter rides to current month matching React logic
      final now = DateTime.now();
      final rideEntries = (data['rideEntries'] as List? ?? [])
          .map((item) => RideEntry.fromJson(item as Map<String, dynamic>))
          .where((ride) {
            try {
              final d = DateTime.parse(ride.date);
              return d.month == now.month && d.year == now.year;
            } catch (_) {
              return true;
            }
          })
          .toList();

      return StorageData(
        petrolEntries: petrolEntries,
        trips: trips,
        currentTrip: currentTrip,
        totalKmSinceLastFill: totalKm,
        rideEntries: rideEntries,
        reserveActive: data['reserveActive'] as bool? ?? false,
        reserveStartDistance: (data['reserveStartDistance'] as num?)?.toDouble() ?? 0.0,
        manualReserveDistance: (data['manualReserveDistance'] as num?)?.toDouble() ?? 0.0,
        fallbackReserveDistance: data['fallbackReserveDistance'] as String? ?? '',
      );
    } catch (e) {
      return StorageData(
        petrolEntries: [],
        trips: [],
        currentTrip: null,
        totalKmSinceLastFill: 0.0,
        rideEntries: [],
        reserveActive: false,
        reserveStartDistance: 0.0,
        manualReserveDistance: 0.0,
        fallbackReserveDistance: '',
      );
    }
  }

  Future<void> saveData(StorageData data) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, dynamic> payload = {
      'petrolEntries': data.petrolEntries.map((e) => e.toJson()).toList(),
      'trips': data.trips.map((e) => e.toJson()).toList(),
      'currentTrip': data.currentTrip?.toJson(),
      'totalKmSinceLastFill': data.totalKmSinceLastFill,
      'rideEntries': data.rideEntries.map((e) => e.toJson()).toList(),
      'reserveActive': data.reserveActive,
      'reserveStartDistance': data.reserveStartDistance,
      'manualReserveDistance': data.manualReserveDistance,
      'fallbackReserveDistance': data.fallbackReserveDistance,
      'lastSaved': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  Future<String?> exportToJsonFile(StorageData data) async {
    try {
      final Map<String, dynamic> payload = {
        'petrolEntries': data.petrolEntries.map((e) => e.toJson()).toList(),
        'trips': data.trips.map((e) => e.toJson()).toList(),
        'rideEntries': data.rideEntries.map((e) => e.toJson()).toList(),
        'totalKmSinceLastFill': data.totalKmSinceLastFill,
        'reserveActive': data.reserveActive,
        'reserveStartDistance': data.reserveStartDistance,
        'manualReserveDistance': data.manualReserveDistance,
        'fallbackReserveDistance': data.fallbackReserveDistance,
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '2.0-mobile',
      };

      final jsonStr = const JsonEncoder.withIndent('  ').convert(payload);
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/petrol-tracker-$dateStr.json');
      await file.writeAsString(jsonStr);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'DriveSense Petrol Tracker Backup ($dateStr)',
      );
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
