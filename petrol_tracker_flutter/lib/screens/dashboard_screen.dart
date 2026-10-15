import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../state/tracker_store.dart';
import '../widgets/modals/reset_confirm_modal.dart';

class DashboardScreen extends StatelessWidget {
  final TrackerStore store;

  const DashboardScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final monthly = store.getMonthlySummary();
    final effective = store.getEffectiveMileage();
    final rollingAvg = store.calculateRollingAverage();
    final allTimeAvg = store.calculateAllTimeAverage();

    // Mileage trend
    String trendText = 'Stable';
    IconData trendIcon = Icons.trending_flat_rounded;
    Color trendColor = AppColors.outline;
    if (store.petrolEntries.length >= 2) {
      final curr = store.petrolEntries[0].mileage;
      final prev = store.petrolEntries[1].mileage;
      if (curr > prev) {
        trendText = '+${(curr - prev).toStringAsFixed(1)} vs last';
        trendIcon = Icons.trending_up_rounded;
        trendColor = AppColors.primary;
      } else if (curr < prev) {
        trendText = '-${(prev - curr).toStringAsFixed(1)} vs last';
        trendIcon = Icons.trending_down_rounded;
        trendColor = AppColors.coralRed;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DriveSense',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.onSurface),
                ),
                Text(
                  'PETROL & EARNINGS TRACKER',
                  style: TextStyle(fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.onSurfaceVariant, size: 20),
            tooltip: 'Export Backup JSON',
            onPressed: () async {
              final path = await store.exportDataBackup();
              if (path != null && context.mounted) {
                store.showToastMessage('✅ Backup created and ready to share', false);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.coralRed, size: 20),
            tooltip: 'Reset Data',
            onPressed: () {
              ResetConfirmModal.show(context, () {
                store.confirmResetAllData();
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Reserve Warning Banner if active
          if (store.reserveActive)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.dangerBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.errorContainer, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.coralRed, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RESERVE FUEL ACTIVE',
                          style: TextStyle(color: AppColors.coralRed, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          'Riding on reserve (${(store.totalKmSinceLastFill - store.reserveStartDistance).toStringAsFixed(1)} km). Refuel soon!',
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Hero Mileage Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF19202E), Color(0xFF151B2A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'CURRENT MILEAGE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: trendColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(trendIcon, size: 14, color: trendColor),
                          const SizedBox(width: 4),
                          Text(
                            trendText,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: trendColor),
                          ),
                        ],
                      ),
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
                      effective.mileage > 0 ? effective.mileage.toStringAsFixed(1) : '--',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'km/L',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  effective.isEstimated
                      ? '⚡ 5-Fill Rolling Average (Recent tank under 20 km)'
                      : effective.source == 'last-tank'
                          ? 'Based on your most recent fuel fill-up'
                          : 'No fuel entries yet. Tap "Log Fuel" to start.',
                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Divider(color: Color(0x1AFFFFFF)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('5-Fill Average', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(
                            rollingAvg > 0 ? '${rollingAvg.toStringAsFixed(1)} km/L' : '--',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    Container(height: 28, width: 1, color: const Color(0x1AFFFFFF)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('All-Time Average', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: 2),
                          Text(
                            allTimeAvg > 0 ? '${allTimeAvg.toStringAsFixed(1)} km/L' : '--',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.tertiary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Current Tank Status Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CURRENT TANK RUNNING',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: AppColors.onSurfaceVariant),
                    ),
                    Icon(Icons.local_gas_station_rounded, size: 16, color: AppColors.primary),
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
                          '${store.totalKmSinceLastFill.toStringAsFixed(1)} km',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                        const Text('Total Ridden Since Fill', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                    if (store.reserveActive || store.manualReserveDistance > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.dangerBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.errorContainer),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(store.manualReserveDistance + (store.reserveActive ? store.totalKmSinceLastFill - store.reserveStartDistance : 0)).toStringAsFixed(1)} km',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.coralRed),
                            ),
                            const Text('On Reserve', style: TextStyle(fontSize: 10, color: AppColors.error)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Monthly Overview Grid
          const Text(
            'THIS MONTH',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  title: 'Distance',
                  value: '${monthly.totalKm.toStringAsFixed(0)} km',
                  icon: Icons.alt_route_rounded,
                  iconColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  title: 'Fuel Bought',
                  value: '${monthly.totalLitres.toStringAsFixed(1)} L',
                  icon: Icons.water_drop_rounded,
                  iconColor: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  title: 'Fuel Expense',
                  value: 'Rs. ${monthly.totalSpent.toStringAsFixed(0)}',
                  icon: Icons.payments_rounded,
                  iconColor: AppColors.tertiary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox(
                  title: 'Month Avg',
                  value: monthly.avgMileage > 0 ? '${monthly.avgMileage.toStringAsFixed(1)} km/L' : '--',
                  icon: Icons.speed_rounded,
                  iconColor: AppColors.primaryContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Quick Action Shortcuts
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.local_gas_station_rounded, size: 20),
                  label: const Text('Log Petrol', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => store.setActiveScreen('fuel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    foregroundColor: AppColors.onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 20, color: AppColors.secondary),
                  label: const Text('Track Trip', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => store.setActiveScreen('personal'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
        ],
      ),
    );
  }
}
