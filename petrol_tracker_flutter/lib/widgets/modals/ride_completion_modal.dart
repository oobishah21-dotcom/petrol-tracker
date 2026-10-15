import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RideCompletionModal extends StatefulWidget {
  final double distanceKm;
  final Function(double earnings, double tip) onComplete;
  final VoidCallback onCancel;

  const RideCompletionModal({
    super.key,
    required this.distanceKm,
    required this.onComplete,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required double distanceKm,
    required Function(double earnings, double tip) onComplete,
    required VoidCallback onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => RideCompletionModal(
        distanceKm: distanceKm,
        onComplete: onComplete,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<RideCompletionModal> createState() => _RideCompletionModalState();
}

class _RideCompletionModalState extends State<RideCompletionModal> {
  final TextEditingController _earningsController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  String? _error;

  void _submit() {
    final earnings = double.tryParse(_earningsController.text.trim());
    final tip = double.tryParse(_tipController.text.trim()) ?? 0.0;

    if (earnings == null || earnings < 0) {
      setState(() => _error = 'Please enter valid fare earnings');
      return;
    }

    Navigator.pop(context);
    widget.onComplete(earnings, tip);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Ride Finished!', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x146DE9BE),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryContainer),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tracked Distance', style: TextStyle(color: AppColors.onSurfaceVariant)),
                  Text(
                    '${widget.distanceKm.toStringAsFixed(2)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
            const Text('Enter Total Fare Received (Rs.)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 6),
            TextField(
              controller: _earningsController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(hintText: 'e.g. 280', suffixText: 'Rs'),
            ),
            const SizedBox(height: 14),
            const Text('Customer Tip (Optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
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
          onPressed: () {
            Navigator.pop(context);
            widget.onCancel();
          },
          child: const Text('Discard', style: TextStyle(color: AppColors.outline)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _submit,
          child: const Text('Save & Calculate Profit', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
