import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ResetConfirmModal extends StatelessWidget {
  final VoidCallback onConfirm;

  const ResetConfirmModal({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ResetConfirmModal(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.delete_forever_rounded, color: AppColors.coralRed),
          SizedBox(width: 8),
          Text('Reset All Data?', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: const Text(
        'This will permanently delete all your petrol fill-ups, GPS trip logs, and ride earnings history.\n\nThis action cannot be undone.',
        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13, height: 1.5),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.outline)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.errorContainer,
            foregroundColor: AppColors.onErrorContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text('Reset Everything', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
