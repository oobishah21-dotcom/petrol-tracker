import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../state/tracker_store.dart';
import '../models/ride_entry.dart';
import '../widgets/modals/add_ride_modal.dart';
import '../widgets/modals/ride_completion_modal.dart';

class RideTrackerScreen extends StatefulWidget {
  final TrackerStore store;

  const RideTrackerScreen({super.key, required this.store});

  @override
  State<RideTrackerScreen> createState() => _RideTrackerScreenState();
}

class _RideTrackerScreenState extends State<RideTrackerScreen> {
  String _earningsTab = 'daily'; // 'daily' or 'monthly'
  final Set<String> _expandedDays = {};

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final bool isRideActive = store.isTracking && store.currentTrip != null && store.currentTrip!.isRide;
    final bool isPersonalActive = store.isTracking && store.currentTrip != null && !store.currentTrip!.isRide;
    final double distanceVal = store.currentTrip != null ? store.currentTrip!.distance : 0.0;
    final rideSummary = store.getRideSummary();

    // Group rides by date string
    final Map<String, List<RideEntry>> groupedRides = {};
    for (final ride in store.rideEntries) {
      try {
        final d = DateTime.parse(ride.date);
        final key = DateFormat('yyyy-MM-dd').format(d);
        groupedRides.putIfAbsent(key, () => []).add(ride);
      } catch (_) {
        groupedRides.putIfAbsent('Unknown', () => []).add(ride);
      }
    }
    final sortedDays = groupedRides.keys.toList()..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ride Share Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.secondary),
            tooltip: 'Log Ride Manually',
            onPressed: () {
              AddRideModal.show(context, (km, earnings, tip) {
                store.addManualRide(km: km, earnings: earnings, tip: tip);
                store.showToastMessage('✅ Ride saved successfully!', false);
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Active Ride Card
          if (isRideActive) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F3BA6), Color(0xFF151B2A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 16, offset: Offset(0, 6))
                ],
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fiber_manual_record, color: AppColors.coralRed, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'RIDE IN PROGRESS',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.secondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        distanceVal.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: Colors.white, height: 1),
                      ),
                      const SizedBox(width: 8),
                      const Text('km', style: TextStyle(fontSize: 20, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Speed: ${store.smoothSpeed.toStringAsFixed(0)} km/h • ${store.gpsDebug.status}',
                    style: const TextStyle(fontSize: 13, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.coralRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.flag_rounded),
                    label: const Text('END RIDE & ENTER FARE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    onPressed: () => store.stopGpsTrip(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            // Start Ride Action Buttons
            if (isPersonalActive)
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
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
                        'A Personal trip is currently in progress. Stop it before starting a ride.',
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 26),
                      label: const Text('START RIDE (GPS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      onPressed: () => store.startGpsTrip(isRide: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.white.withOpacity(0.12)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, color: AppColors.onSurface, size: 20),
                      label: const Text('MANUAL', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurface, fontSize: 13)),
                      onPressed: () {
                        AddRideModal.show(context, (km, earnings, tip) {
                          store.addManualRide(km: km, earnings: earnings, tip: tip);
                          store.showToastMessage('✅ Ride saved!', false);
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24),
          ],

          // Monthly Overview Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('MONTHLY EARNINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant)),
                    Icon(Icons.monetization_on_rounded, size: 18, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rs. ${rideSummary.totalProfit.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                        const Text('Net Profit', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${rideSummary.totalEarnings.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        Text('Gross (Tips: Rs. ${rideSummary.totalTips.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0x1AFFFFFF)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rides: ${rideSummary.totalRides} • ${rideSummary.totalRideKm.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                    ),
                    Text(
                      rideSummary.avgProfitPerKm > 0 ? 'Rs. ${rideSummary.avgProfitPerKm.toStringAsFixed(1)} / km' : '--',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Daily Ride Log List
          const Text(
            'DAILY BREAKDOWN',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          if (sortedDays.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.two_wheeler_rounded, size: 48, color: AppColors.outline),
                  SizedBox(height: 12),
                  Text('No rides logged this month', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Start a GPS ride or tap + to log one manually.', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                ],
              ),
            )
          else
            ...sortedDays.map((dayKey) {
              final dayRides = groupedRides[dayKey]!;
              final double dayKm = dayRides.fold(0.0, (s, r) => s + r.km);
              final double dayGross = dayRides.fold(0.0, (s, r) => s + r.totalEarnings);
              final double dayFuel = dayRides.fold(0.0, (s, r) => s + r.fuelCost);
              final double dayProfit = dayRides.fold(0.0, (s, r) => s + r.profit);
              final bool isExpanded = _expandedDays.contains(dayKey);

              DateTime? dateObj;
              try {
                dateObj = DateTime.parse(dayKey);
              } catch (_) {}

              final dateTitle = dateObj != null ? DateFormat('EEE, dd MMM yyyy').format(dateObj) : dayKey;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedDays.remove(dayKey);
                          } else {
                            _expandedDays.add(dayKey);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${dayRides.length} ride${dayRides.length > 1 ? "s" : ""} • ${dayKm.toStringAsFixed(1)} km',
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Rs. ${dayProfit.toStringAsFixed(0)}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                    ),
                                    Text(
                                      'Fuel: -Rs. ${dayFuel.toStringAsFixed(0)}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.coralRed),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.outline,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded) ...[
                      const Divider(height: 1, color: Color(0x1AFFFFFF)),
                      ...dayRides.map((ride) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${ride.km.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.onSurface)),
                                  Text('Gross: Rs. ${ride.totalEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+Rs. ${ride.profit.toStringAsFixed(0)} net',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
                                  ),
                                  Text(
                                    'Rs. ${ride.profitPerKm.toStringAsFixed(1)}/km',
                                    style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
