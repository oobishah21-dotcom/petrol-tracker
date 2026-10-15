import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final String activeScreen;
  final Function(String) onTabSelected;

  const BottomNavBar({
    super.key,
    required this.activeScreen,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1321),
        border: Border(
          top: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                id: 'dashboard',
                label: 'Home',
                icon: Icons.home_rounded,
              ),
              _buildNavItem(
                id: 'fuel',
                label: 'Fuel',
                icon: Icons.local_gas_station_rounded,
              ),
              _buildNavItem(
                id: 'personal',
                label: 'Personal',
                icon: Icons.person_rounded,
              ),
              _buildNavItem(
                id: 'ride',
                label: 'Ride',
                icon: Icons.directions_car_rounded,
              ),
              _buildNavItem(
                id: 'calculator',
                label: 'Calc',
                icon: Icons.calculate_rounded,
              ),
              _buildNavItem(
                id: 'history',
                label: 'Logs',
                icon: Icons.history_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required String id,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = activeScreen == id;
    final color = isSelected ? AppColors.primary : AppColors.outline;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 24,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
