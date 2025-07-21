import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

class AvgComparisonIcon extends StatelessWidget {
  final String? comparison;
  const AvgComparisonIcon({Key? key, required this.comparison}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (comparison == 'above_10') {
      return const Icon(
        Icons.trending_up,
        color: AppTheme.errorColor,
        size: 16,
      );
    } else if (comparison == 'below_10') {
      return const Icon(
        Icons.trending_down,
        color: AppTheme.successColor,
        size: 16,
      );
    }
    return const SizedBox.shrink();
  }
}
