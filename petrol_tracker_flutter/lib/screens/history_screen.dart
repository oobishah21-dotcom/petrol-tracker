import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../state/tracker_store.dart';
import '../models/petrol_entry.dart';

class HistoryScreen extends StatefulWidget {
  final TrackerStore store;

  const HistoryScreen({super.key, required this.store});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all'; // '5-fill' or 'all'

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final rollingAvg = store.calculateRollingAverage();
    final allTimeAvg = store.calculateAllTimeAverage();

    final query = _searchController.text.trim().toLowerCase();
    List<PetrolEntry> entries = store.petrolEntries;

    if (_filter == '5-fill') {
      entries = entries.take(5).toList();
    }

    if (query.isNotEmpty) {
      entries = entries.where((e) {
        return e.date.toLowerCase().contains(query);
      }).toList();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Fuel Fill History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppColors.onSurfaceVariant),
            tooltip: 'Export Backup JSON',
            onPressed: () async {
              final path = await store.exportDataBackup();
              if (path != null && context.mounted) {
                store.showToastMessage('✅ Backup exported successfully', false);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Search & Filter Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search by date (YYYY-MM-DD)...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: '5-fill', label: Text('5-Fill', style: TextStyle(fontSize: 11))),
                  ButtonSegment(value: 'all', label: Text('All', style: TextStyle(fontSize: 11))),
                ],
                selected: {_filter},
                onSelectionChanged: (val) {
                  setState(() => _filter = val.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return AppColors.primaryContainer.withOpacity(0.3);
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Summary Mini Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('5-Fill Average', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                        rollingAvg > 0 ? '${rollingAvg.toStringAsFixed(1)} km/L' : '--',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('All-Time Average', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Text(
                        allTimeAvg > 0 ? '${allTimeAvg.toStringAsFixed(1)} km/L' : '--',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Log Entries List
          if (entries.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  Icon(Icons.local_gas_station_rounded, size: 48, color: AppColors.outline),
                  SizedBox(height: 12),
                  Text('No fuel logs found', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('Tap the Fuel tab to record your first fill-up.', style: TextStyle(color: AppColors.outline, fontSize: 12)),
                ],
              ),
            )
          else
            ...entries.map((entry) {
              DateTime? dateObj;
              try {
                dateObj = DateTime.parse(entry.date);
              } catch (_) {}
              final formattedDate = dateObj != null ? DateFormat('dd MMM yyyy').format(dateObj) : entry.date;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.local_gas_station_rounded, color: AppColors.primary, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.onSurface),
                                ),
                                Text(
                                  '${entry.litres.toStringAsFixed(2)} L @ Rs. ${entry.pricePerLitre.toStringAsFixed(0)}/L',
                                  style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs. ${entry.totalCost.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.tertiary),
                            ),
                            if (entry.mileage > 0)
                              Text(
                                '${entry.mileage.toStringAsFixed(1)} km/L',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (entry.reserveDistance > 0 || entry.isEstimated) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (entry.reserveDistance > 0)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.dangerBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.errorContainer),
                              ),
                              child: Text(
                                'RESERVE: ${entry.reserveDistance.toStringAsFixed(1)} km',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.coralRed),
                              ),
                            ),
                          if (entry.isEstimated)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'ESTIMATED TANK',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.tertiary),
                              ),
                            ),
                        ],
                      ),
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
