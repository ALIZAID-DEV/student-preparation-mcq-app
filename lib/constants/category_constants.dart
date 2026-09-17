import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryConstants {
  static IconData getIconData(String iconName) {
    switch (iconName.trim()) {
      case 'school':
        return Icons.school_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'gavel':
        return Icons.gavel_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  static Color getLightTint(int index) {
    final colors = [
      AppColors.ink,
      AppColors.accent,
      AppColors.success,
      AppColors.danger,
    ];
    return colors[index % colors.length];
  }
}
