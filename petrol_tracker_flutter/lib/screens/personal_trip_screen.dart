import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../state/tracker_store.dart';
import '../widgets/modals/manual_km_modal.dart';
import '../widgets/modals/add_reserve_modal.dart';

class PersonalTripScreen extends StatelessWidget {
  final TrackerStore store;

  const PersonalTripScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final bool isPersonalActive = store.isTracking && store.currentTrip != null && !store.currentTrip!.isRide;
    final bool isRideActive = store.isTracking && store.currentTrip != null && store.currentTrip!.isRide;

    final distanceVal = store.currentTrip != null ? store.currentTrip!.distance : 0.0;
    final effective = store.getEffectiveMileage();
    final latestPrice = store.petrolEntries.isNotEmpty ? store.petrolEntries[0].pricePerLitre : MileageConfig.defaultFuelPrice;
    final activeMileage = effective.mileage > 0 ? effective.mileage : MileageConfig.defaultMileage;
    final costPerKm = activeMileage > 0 ? latestPrice / activeMileage : 0.0;
    final tripCost = distanceVal * costPerKm;

    final lastLitres = store.petrolEntries.isNotEmpty ? store.petrolEntries[0].litres : 10.0;
    final totalRange = lastLitres * activeMileage;
    final double fuelLeftPct = totalRange > 0
        ? ((totalRange - store.totalKmSinceLastFill) / totalRange * 100).clamp(0.0, 100.0)
        : 100.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Personal Trip Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // GPS Signal Loss Warning Banner
          if (store.gpsSignalLost && isPersonalActive)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.coralRed, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.satellite_alt_rounded, color: AppColors.coralRed, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '📡 GPS Signal Lost — estimating distance using dead reckoning (${(store.smoothSpeed).toStringAsFixed(1)} km/h)',
                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Speedometer & Distance Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF19202E), Color(0xFF101726)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 16,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              children: [
                // Digital Speedometer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      isPersonalActive ? store.smoothSpeed.toStringAsFixed(0) : '0',
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        height: 0.9,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'km/h',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isPersonalActive
                      ? (store.gpsDebug.status)
                      : 'GPS Ready to Track',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPersonalActive ? AppColors.primary : AppColors.outline,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(color: Color(0x1AFFFFFF)),
                const SizedBox(height: 14),

                // Distance Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Trip Distance', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          '${distanceVal.toStringAsFixed(2)} km',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                    Container(height: 36, width: 1, color: const Color(0x1AFFFFFF)),
                    Column(
                      children: [
                        const Text('Estimated Cost', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(
                          'Rs. ${tripCost.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Start / Stop Trip Button
          if (isRideActive)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.errorContainer),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.coralRed),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'A Ride trip is currently in progress. Go to Ride tab to finish it.',
                      style: TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            )
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isPersonalActive ? AppColors.errorContainer : AppColors.primary,
                foregroundColor: isPersonalActive ? AppColors.onErrorContainer : AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              icon: Icon(isPersonalActive ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 28),
              label: Text(
                isPersonalActive ? 'STOP PERSONAL TRIP' : 'START PERSONAL TRIP',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
              ),
              onPressed: () {
                if (isPersonalActive) {
                  store.stopGpsTrip();
                } else {
                  store.startGpsTrip(isRide: false);
                }
              },
            ),

          const SizedBox(height: 24),

          // Reserve Controls Section
          const Text(
            'RESERVE FUEL CONTROL',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),

          // Switch to Reserve Toggle
          InkWell(
            onTap: () => store.toggleReserveMode(),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: store.reserveActive ? AppColors.errorContainer : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: store.reserveActive ? AppColors.coralRed : Colors.white.withOpacity(0.08),
                  width: store.reserveActive ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    store.reserveActive ? Icons.warning_rounded : Icons.local_gas_station_rounded,
                    color: store.reserveActive ? AppColors.onErrorContainer : AppColors.onSurfaceVariant,
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.reserveActive ? 'RESERVE ACTIVE' : 'Switch to Reserve',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: store.reserveActive ? AppColors.onErrorContainer : AppColors.onSurface,
                          ),
                        ),
                        Text(
                          store.reserveActive
                              ? 'Tracking reserve distance separately'
                              : 'Tap when your bike enters reserve',
                          style: TextStyle(
                            fontSize: 12,
                            color: store.reserveActive ? AppColors.onErrorContainer.withOpacity(0.8) : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: store.reserveActive,
                    activeColor: AppColors.coralRed,
                    onChanged: (_) => store.toggleReserveMode(),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Add Reserve Manually & Add Manual KM Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 18, color: AppColors.coralRed),
                  label: const Text('Add Reserve', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
                  onPressed: () {
                    AddReserveModal.show(context, (km) {
                      store.addManualReserve(km);
                      store.showToastMessage('✅ $km km added to reserve', false);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: Colors.white.withOpacity(0.12)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.edit_road_rounded, size: 18, color: AppColors.primary),
                  label: const Text('Manual KM', style: TextStyle(fontSize: 13, color: AppColors.onSurface)),
                  onPressed: () {
                    ManualKmModal.show(context, (km) {
                      store.addManualKm(km);
                      store.showToastMessage('✅ $km km added manually', false);
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
