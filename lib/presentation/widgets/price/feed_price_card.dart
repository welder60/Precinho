import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_cached_image.dart';
import '../avg_comparison_icon.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';

class FeedPriceCard extends StatelessWidget {
  final DocumentSnapshot doc;
  final String productLabel;
  final String? productImage;
  final String? storeImage;
  final DateTime? createdAt;
  final double? distance;
  final String? perUnit;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  const FeedPriceCard({
    super.key,
    required this.doc,
    required this.productLabel,
    this.productImage,
    this.storeImage,
    this.createdAt,
    this.distance,
    this.perUnit,
    this.onTap,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    child: AppCachedImage(
                      imageUrl: productImage,
                      width: 56,
                      height: 56,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(productLabel),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (storeImage != null && storeImage!.isNotEmpty)
                              ClipOval(
                                child: AppCachedImage(
                                  imageUrl: storeImage!,
                                  width: 20,
                                  height: 20,
                                ),
                              ),
                            if (storeImage != null && storeImage!.isNotEmpty)
                              const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                data['store_name'] ?? '',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatPrice((data['price'] as num).toDouble()),
                        style: AppTheme.priceTextStyle,
                      ),
                      if (perUnit != null)
                        Text(
                          perUnit!,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      if (data['variation'] != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (data['variation'] as num) > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: (data['variation'] as num) > 0
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              Formatters.formatPercentage(
                                  ((data['variation'] as num).abs()).toDouble()),
                              style: TextStyle(
                                color: (data['variation'] as num) > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      AvgComparisonIcon(
                          comparison: data['avg_comparison'] as String?),
                      if ((data['expires_at'] as Timestamp?) != null &&
                          DateTime.now()
                              .isAfter((data['expires_at'] as Timestamp).toDate()))
                        IconButton(
                          icon: const Icon(Icons.warning,
                              color: AppTheme.warningColor, size: 20),
                          tooltip: 'Preço pode estar desatualizado',
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Este preço pode estar desatualizado'),
                              ),
                            );
                          },
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              Row(
                children: [
                  if (createdAt != null)
                    Text(
                      Formatters.formatDate(createdAt!),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const Spacer(),
                  if (distance != null)
                    Text(
                      Formatters.formatDistance(distance!),
                      style: AppTheme.distanceTextStyle,
                    ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: onAdd,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
