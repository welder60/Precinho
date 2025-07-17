import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class AvgComparisonIcon extends StatelessWidget {
  final String? comparison;
  const AvgComparisonIcon({Key? key, required this.comparison}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (comparison == 'above_10') {
      icon = Icons.trending_up;
      color = AppTheme.errorColor;
    } else if (comparison == 'below_10') {
      icon = Icons.trending_down;
      color = AppTheme.successColor;
    } else {
      icon = Icons.trending_flat;
      color = AppTheme.infoColor;
    }
    return Icon(icon, color: color, size: 16);
  }
}
