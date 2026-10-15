import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../state/tracker_store.dart';

class FuelEntryScreen extends StatefulWidget {
  final TrackerStore store;

  const FuelEntryScreen({super.key, required this.store});

  @override
  State<FuelEntryScreen> createState() => _FuelEntryScreenState();
}

class _FuelEntryScreenState extends State<FuelEntryScreen> {
  final TextEditingController _litresController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _reserveFallbackController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.store.petrolEntries.isNotEmpty) {
      _priceController.text = widget.store.petrolEntries[0].pricePerLitre.toStringAsFixed(0);
    } else {
      _priceController.text = MileageConfig.defaultFuelPrice.toStringAsFixed(0);
    }
  }

  void _save() {
    final litres = double.tryParse(_litresController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final fallbackReserve = double.tryParse(_reserveFallbackController.text.trim()) ?? 0.0;

    if (litres == null || litres <= 0) {
      widget.store.showToastMessage('❌ Please enter a valid number of litres', isError: true);
      return;
    }
    if (price == null || price <= 0) {
      widget.store.showToastMessage('❌ Please enter a valid price per litre', isError: true);
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final distanceRidden = widget.store.totalKmSinceLastFill;

    widget.store.savePetrolEntry(
      litres: litres,
      pricePerLitre: price,
      date: dateStr,
      fallbackReserve: fallbackReserve,
    );

    widget.store.showToastMessage('✅ Fuel refuel saved successfully!', false);
    widget.store.setActiveScreen('dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final double litresVal = double.tryParse(_litresController.text.trim()) ?? 0.0;
    final double priceVal = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final double estTotalCost = litresVal * priceVal;

    final double fallbackRes = double.tryParse(_reserveFallbackController.text.trim()) ?? 0.0;
    final double currentReserve = (widget.store.reserveActive
            ? (widget.store.totalKmSinceLastFill - widget.store.reserveStartDistance)
            : 0.0) +
        widget.store.manualReserveDistance +
        fallbackRes;

    final double mainTankDistance = widget.store.totalKmSinceLastFill > currentReserve
        ? (widget.store.totalKmSinceLastFill - currentReserve)
        : 0.0;

    final double calculatedTankMileage = litresVal > 0 && mainTankDistance > 0 ? (mainTankDistance / litresVal) : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Log Petrol Fill-up', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // Current Tank Distance Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Distance on Previous Tank', style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.store.totalKmSinceLastFill.toStringAsFixed(1)} km',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
                if (currentReserve > 0)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Reserve Subtracted', style: TextStyle(fontSize: 11, color: AppColors.error)),
                      const SizedBox(height: 4),
                      Text(
                        '-${currentReserve.toStringAsFixed(1)} km',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.coralRed),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Litres Input
          const Text('Litres Filled', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _litresController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. 8.5',
              suffixText: 'Litres',
              prefixIcon: Icon(Icons.water_drop_rounded, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),

          // Quick preset buttons
          Row(
            children: [2, 4, 6, 8, 10].map((lit) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      side: BorderSide(color: Colors.white.withOpacity(0.12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _litresController.text = lit.toString();
                      setState(() {});
                    },
                    child: Text('${lit}L', style: const TextStyle(fontSize: 12, color: AppColors.onSurface)),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Price per Litre Input
          const Text('Price per Litre (PKR)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. 272',
              suffixText: 'Rs/L',
              prefixIcon: Icon(Icons.currency_exchange_rounded, color: AppColors.secondary),
            ),
          ),

          const SizedBox(height: 18),

          // Date Picker
          const Text('Fill Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0x14FFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x26FFFFFF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 15, color: AppColors.onSurface),
                  ),
                  const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.outline),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Optional Reserve Fallback
          const Text('Rode on reserve before this fill? (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          TextField(
            controller: _reserveFallbackController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. 5.0 (subtracts from tank calculation)',
              suffixText: 'km',
              prefixIcon: Icon(Icons.warning_amber_rounded, color: AppColors.coralRed),
            ),
          ),

          const SizedBox(height: 24),

          // Live Calculation Summary Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Cost', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    Text(
                      'Rs. ${estTotalCost.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.tertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Calculated Mileage', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
                    Text(
                      calculatedTankMileage > 0 ? '${calculatedTankMileage.toStringAsFixed(2)} km/L' : '--',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _save,
            child: const Text(
              'Save Refuel & Start Fresh Tank',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
