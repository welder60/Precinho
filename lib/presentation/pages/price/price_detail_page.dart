import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'add_price_page.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

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
      file = XFile.fromData(resp.bodyBytes, name: 'price.jpg', mimeType: 'image/jpeg');
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

          final productImage = (productDoc?.data() as Map<String, dynamic>?)?['image_url'] as String?;
          final userData = userDoc?.data() as Map<String, dynamic>?;
          final userName = userData?['name'] as String? ?? 'Usu\u00e1rio';
          final userPhoto = userData?['photo_url'] as String?;
          final createdAt = (data['created_at'] as Timestamp?)?.toDate();

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (productImage != null && productImage.isNotEmpty)
                  Image.network(
                    productImage,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  productName.isNotEmpty ? productName : 'Produto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Com\u00e9rcio: $storeName'),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  Formatters.formatPrice((data['price'] as num).toDouble()),
                  style: AppTheme.priceTextStyle,
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
                  Text('Registrado em: ${Formatters.formatDateTime(createdAt)}'),
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
                                ? Formatters.formatDateTime(date)
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
