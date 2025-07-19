import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../pages/price/price_detail_page.dart';
import '../price/feed_price_card.dart';

class FeedPriceList extends StatelessWidget {
  final ScrollController controller;
  final List<DocumentSnapshot> docs;
  final bool hasMore;
  final bool isLoading;
  final Position? position;
  final Map<String, Map<String, dynamic>> productInfo;
  final Map<String, Map<String, dynamic>> userInfo;
  final Map<String, Map<String, dynamic>> storeInfo;
  final void Function(DocumentSnapshot doc) onAdd;

  const FeedPriceList({
    super.key,
    required this.controller,
    required this.docs,
    required this.hasMore,
    required this.isLoading,
    required this.position,
    required this.productInfo,
    required this.userInfo,
    required this.storeInfo,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    if (docs.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: controller,
      itemCount: docs.length + (hasMore ? 1 : 0),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemBuilder: (context, index) {
        if (index >= docs.length) {
          return const Padding(
            padding: EdgeInsets.all(AppTheme.paddingMedium),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;
        final productId = data['product_id'] as String?;
        final userId = data['user_id'] as String?;
        final product = productId != null ? productInfo[productId] : null;
        final user = userId != null ? userInfo[userId] : null;
        final productImage = product?['image_url'] as String?;
        final volume = product?['volume'] as num?;
        final unit = product?['unit'] as String?;
        var productLabel = data['product_name'] ?? 'Produto';
        if (volume != null && unit != null && unit != 'un') {
          productLabel = '$productLabel (${volume.toString()} $unit)';
        }
        final perUnit = volume != null && unit != null
            ? Formatters.formatPricePerQuantity(
                price: (data['price'] as num).toDouble(),
                volume: volume.toDouble(),
                unit: unit,
              )
            : null;

        final storeId = data['store_id'] as String?;
        final store = storeId != null ? storeInfo[storeId] : null;
        final storeImage = store?['image_url'] as String?;
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        double? distance;
        if (position != null && lat != null && lng != null) {
          distance = Geolocator.distanceBetween(
                position!.latitude,
                position!.longitude,
                lat,
                lng,
              ) /
              1000.0;
        }
        final createdAt = (data['created_at'] as Timestamp?)?.toDate();

        return FeedPriceCard(
          doc: doc,
          productLabel: productLabel,
          productImage: productImage,
          storeImage: storeImage,
          createdAt: createdAt,
          distance: distance,
          perUnit: perUnit,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PriceDetailPage(price: doc),
              ),
            );
          },
          onAdd: () => onAdd(doc),
        );
      },
    );
  }
}
