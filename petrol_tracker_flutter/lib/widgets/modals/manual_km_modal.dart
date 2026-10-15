import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ManualKmModal extends StatefulWidget {
  final Function(double km) onSave;

  const ManualKmModal({super.key, required this.onSave});

  static Future<void> show(BuildContext context, Function(double km) onSave) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ManualKmModal(onSave: onSave),
    );
  }

  @override
  State<ManualKmModal> createState() => _ManualKmModalState();
}

class _ManualKmModalState extends State<ManualKmModal> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _submit() {
    final val = double.tryParse(_controller.text.trim());
    if (val == null || val <= 0) {
      setState(() => _errorMessage = 'Please enter a valid kilometer number');
      return;
    }

    if (val > 1000) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('⚠️ High Mileage Warning'),
          content: Text('You entered $val km. This is very high. Do you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
                widget.onSave(val);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.pop(context);
    widget.onSave(val);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_road_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text('Add Kilometers', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter distance ridden manually if GPS was not tracking.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. 15.5',
              suffixText: 'km',
              errorText: _errorMessage,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _submit,
          child: const Text('Add KM', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
