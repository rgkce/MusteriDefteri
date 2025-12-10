import 'package:flutter/material.dart';
import 'package:musteridefterim/constants/app_colors.dart';

class NavBar extends StatelessWidget {
  final int currentIndex;

  const NavBar({super.key, required this.currentIndex});

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/appointment');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, 0, Icons.home_rounded, "Ana Sayfa", isDark),
          _navItem(
            context,
            1,
            Icons.calendar_month_rounded,
            "Randevular",
            isDark,
          ),
          _navItem(context, 2, Icons.person_rounded, "Profil", isDark),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int index,
    IconData icon,
    String label,
    bool isDark,
  ) {
    final bool isActive = index == currentIndex;

    // Active Color: Indigo (Accent)
    // Inactive Color: Grey (Secondary Text)
    final Color activeColor =
        isDark ? AppColors.darkAccent : AppColors.lightAccent;
    final Color inactiveColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final Color color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
