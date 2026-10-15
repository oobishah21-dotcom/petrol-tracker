import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class GpsStatusBanner extends StatelessWidget {
  final String message;
  final bool isVisible;
  final VoidCallback onDismiss;

  const GpsStatusBanner({
    super.key,
    required this.message,
    required this.isVisible,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || message.isEmpty) return const SizedBox.shrink();

    final bool isError = message.contains('❌') || message.contains('⚠️') || message.contains('Lost');

    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDismiss,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError
                  ? const Color(0xE61A0B0B)
                  : const Color(0xE6151B2A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError ? AppColors.errorContainer : AppColors.primaryContainer,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: isError ? AppColors.error : AppColors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
