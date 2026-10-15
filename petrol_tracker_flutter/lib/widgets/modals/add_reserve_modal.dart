import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AddReserveModal extends StatefulWidget {
  final Function(double km) onSave;

  const AddReserveModal({super.key, required this.onSave});

  static Future<void> show(BuildContext context, Function(double km) onSave) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AddReserveModal(onSave: onSave),
    );
  }

  @override
  State<AddReserveModal> createState() => _AddReserveModalState();
}

class _AddReserveModalState extends State<AddReserveModal> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;

  void _submit() {
    final val = double.tryParse(_controller.text.trim());
    if (val == null || val <= 0) {
      setState(() => _errorMessage = 'Please enter valid kilometers');
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
          Icon(Icons.warning_amber_rounded, color: AppColors.coralRed),
          SizedBox(width: 8),
          Text('Add Reserve', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter distance ridden on reserve to deduct from next mileage calculation.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g. 8.0',
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
            backgroundColor: AppColors.coralRed,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _submit,
          child: const Text('Save Reserve', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
