import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'add_price_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:precinho_app/presentation/widgets/app_cached_image.dart';
import 'package:precinho_app/presentation/widgets/avg_comparison_icon.dart';
import 'package:geolocator/geolocator.dart';

class PriceDetailPage extends StatelessWidget {
  final DocumentSnapshot price;

  const PriceDetailPage({required this.price, super.key});

  Future<void> _updatePrice(BuildContext context) async {
    final data = price.data() as Map<String, dynamic>;
    final productId = data['product_id'] as String?;
    final storeId = data['store_id'] as String?;
    if (productId == null || storeId == null) return;

    final productDoc = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();
    final storeDoc = await FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .get();

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPricePage(product: productDoc, store: storeDoc),
      ),
    );
  }

  Future<void> _sharePrice() async {
    final data = price.data() as Map<String, dynamic>;
    final imageUrl = data['image_url'] as String?;
    final productName = data['product_name'] as String? ?? 'Produto';
    final storeName = data['store_name'] as String? ?? 'Comércio';
    final value = Formatters.formatPrice((data['price'] as num).toDouble());
    final link = 'precinho://price/${price.id}';

    XFile? file;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final resp = await http.get(Uri.parse(imageUrl));
      final bytes = resp.bodyBytes;
      file = XFile.fromData(bytes, name: 'price.jpg', mimeType: 'image/jpeg');
    }

    final text = '$productName no $storeName por $value\nVeja mais: $link';
    if (file != null) {
      await Share.shareXFiles([file], text: text);
    } else {
      await Share.share(text);
    }
  }










  Future<Map<String, DocumentSnapshot?>> _fetchExtraDetails() async {
    final data = price.data() as Map<String, dynamic>;
    final productId = data['product_id'] as String?;
    final userId = data['user_id'] as String?;

    final productDoc = productId != null
        ? await FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get()
        : null;

    final userDoc = userId != null
        ? await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get()
        : null;

    return {'product': productDoc, 'user': userDoc};
  }

  Future<List<Map<String, dynamic>>> _fetchNearbyPrices() async {
    final data = price.data() as Map<String, dynamic>;
    final productId = data['product_id'] as String?;
    final baseLat = (data['latitude'] as num?)?.toDouble();
    final baseLng = (data['longitude'] as num?)?.toDouble();
    if (productId == null || baseLat == null || baseLng == null) return [];

    final snap = await FirebaseFirestore.instance
        .collection('prices')
        .where('product_id', isEqualTo: productId)
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(50)
        .get();

    const radiusInMeters = 1000.0;
    final nearby = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      if (doc.id == price.id) continue;
      final pData = doc.data() as Map<String, dynamic>;
      final lat = (pData['latitude'] as num?)?.toDouble();
      final lng = (pData['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;
      final dist = Geolocator.distanceBetween(baseLat, baseLng, lat, lng);
      if (dist <= radiusInMeters) {
        nearby.add({'doc': doc, 'distance': dist / 1000.0});
      }
    }

    nearby.sort((a, b) => (a['distance'] as double)
        .compareTo(b['distance'] as double));

    return nearby;
  }


  @override
  Widget build(BuildContext context) {
    final data = price.data() as Map<String, dynamic>;
    final productName = data['product_name'] as String? ?? '';
    final storeName = data['store_name'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Preço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePrice,
          )
        ],
      ),
      body: FutureBuilder<Map<String, DocumentSnapshot?>>(
        future: _fetchExtraDetails(),
        builder: (context, snapshot) {
          final productDoc = snapshot.data?['product'];
          final userDoc = snapshot.data?['user'];

          final productImage =
              (productDoc?.data() as Map<String, dynamic>?)?['image_url'] as String?;
          final userData = userDoc?.data() as Map<String, dynamic>?;
          final userName = userData?['name'] as String? ?? 'Usu\u00e1rio';
          final userPhoto = userData?['photo_url'] as String?;
          final volume =
              (productDoc?.data() as Map<String, dynamic>?)?['volume'] as num?;
          final unit =
              (productDoc?.data() as Map<String, dynamic>?)?['unit'] as String?;
          var productLabel = productName;
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
          final createdAt = (data['created_at'] as Timestamp?)?.toDate();

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCachedImage(
                  imageUrl: productImage,
                  width: double.infinity,
                  height: 200,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  productLabel.isNotEmpty ? productLabel : 'Produto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Com\u00e9rcio: $storeName'),
                const SizedBox(height: AppTheme.paddingMedium),
                Row(
                  children: [
                    Text(
                      Formatters.formatPrice((data['price'] as num).toDouble()),
                      style: AppTheme.priceTextStyle,
                    ),
                    if (perUnit != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          perUnit,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    const SizedBox(width: 4),
                    if ((data['expires_at'] as Timestamp?) != null &&
                        DateTime.now().isAfter(
                            (data['expires_at'] as Timestamp).toDate()))
                      IconButton(
                        icon: const Icon(Icons.warning,
                            color: AppTheme.warningColor, size: 20),
                        tooltip: 'Preço pode estar desatualizado',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Este preço pode estar desatualizado')),
                          );
                        },
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                if (data['variation'] != null)
                  Row(
                    children: [
                      Icon(
                        (data['variation'] as num) > 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: (data['variation'] as num) > 0
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatPercentage(
                            ((data['variation'] as num).abs()).toDouble()),
                        style: TextStyle(
                          color: (data['variation'] as num) > 0
                              ? AppTheme.errorColor
                              : AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                AvgComparisonIcon(
                    comparison: data['avg_comparison'] as String?),
                const SizedBox(height: AppTheme.paddingLarge),
                Row(
                  children: [
                    if (userPhoto != null && userPhoto.isNotEmpty)
                      CircleAvatar(backgroundImage: NetworkImage(userPhoto))
                    else
                      const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Text(userName),
                  ],
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text('Registrado em: ${Formatters.formatDate(createdAt)}'),
                ],
                const SizedBox(height: AppTheme.paddingLarge),
                Text(
                  'Hist\u00f3rico de pre\u00e7os',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppTheme.paddingSmall),
                StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                      .collection('prices')
                      .where('product_id', isEqualTo: data['product_id'])
                      .where('store_id', isEqualTo: data['store_id'])
                      .where('is_active', isEqualTo: true)
                      .orderBy('created_at', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, historySnapshot) {
                    if (historySnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final historyDocs = historySnapshot.data?.docs ?? [];
                    if (historyDocs.isEmpty) {
                      return const Text('Nenhum hist\u00f3rico encontrado');
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: historyDocs.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final hData =
                            historyDocs[index].data() as Map<String, dynamic>;
                        final date =
                            (hData['created_at'] as Timestamp?)?.toDate();
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(date != null
                                ? Formatters.formatDate(date)
                                : '-'),
                            Text(
                              Formatters.formatPrice(
                                  (hData['price'] as num).toDouble()),
                              style: AppTheme.priceTextStyle,
                            ),
                          ],
                        );
                      },
                  );
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              Text(
                'Preços próximos (1km)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.paddingSmall),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchNearbyPrices(),
                builder: (context, nearbySnapshot) {
                  if (nearbySnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = nearbySnapshot.data ?? [];
                  if (items.isEmpty) {
                    return const Text('Nenhum preço encontrado nas proximidades');
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final doc = item['doc'] as DocumentSnapshot;
                      final pData = doc.data() as Map<String, dynamic>;
                      final distance = item['distance'] as double?;
                      return ListTile(
                        title: Text(pData['store_name'] as String? ?? 'Comércio'),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatPrice((pData['price'] as num).toDouble()),
                              style: AppTheme.priceTextStyle,
                            ),
                            if (distance != null)
                              Text(
                                Formatters.formatDistance(distance),
                                style: AppTheme.distanceTextStyle,
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PriceDetailPage(price: doc),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              const Text('Mais detalhes ser\u00e3o implementados futuramente.'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'price_detail_fab',
        onPressed: () => _updatePrice(context),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
