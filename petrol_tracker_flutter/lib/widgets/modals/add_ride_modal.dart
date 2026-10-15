import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AddRideModal extends StatefulWidget {
  final Function(double km, double earnings, double tip) onSave;

  const AddRideModal({super.key, required this.onSave});

  static Future<void> show(
    BuildContext context,
    Function(double km, double earnings, double tip) onSave,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddRideModal(onSave: onSave),
    );
  }

  @override
  State<AddRideModal> createState() => _AddRideModalState();
}

class _AddRideModalState extends State<AddRideModal> {
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _earningsController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  String? _error;

  void _submit() {
    final km = double.tryParse(_kmController.text.trim());
    final earnings = double.tryParse(_earningsController.text.trim());
    final tip = double.tryParse(_tipController.text.trim()) ?? 0.0;

    if (km == null || km <= 0) {
      setState(() => _error = 'Please enter valid kilometers');
      return;
    }
    if (earnings == null || earnings < 0) {
      setState(() => _error = 'Please enter valid earnings amount');
      return;
    }

    if (km > 500) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ Long Distance Warning'),
          content: Text('You entered $km km. This seems very high. Proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                widget.onSave(km, earnings, tip);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onSave(km, earnings, tip);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.directions_car_rounded, color: AppColors.secondary),
          SizedBox(width: 8),
          Text('Add Ride Manually', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.dangerBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.errorContainer),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12)),
              ),
            const Text('Distance (km)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _kmController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 12.4', suffixText: 'km'),
            ),
            const SizedBox(height: 14),
            const Text('Base Fare Earnings (Rs.)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _earningsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 350', suffixText: 'Rs'),
            ),
            const SizedBox(height: 14),
            const Text('Tip (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _tipController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'e.g. 50', suffixText: 'Rs'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onSecondary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _submit,
          child: const Text('Save Ride', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
