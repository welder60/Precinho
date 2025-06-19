import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';

class ProductDetailPage extends StatelessWidget {
  final DocumentSnapshot product;
  const ProductDetailPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Produto'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['image_url'] != null && (data['image_url'] as String).isNotEmpty)
            Image.network(
              data['image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(data['brand'] ?? ''),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('product_id', isEqualTo: product.id)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum preço para este produto'));
                }
                final Map<String, DocumentSnapshot> latest = {};
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final storeId = data['store_id'] as String?;
                  if (storeId == null) continue;
                  if (!latest.containsKey(storeId)) {
                    latest[storeId] = doc;
                  }
                }
                final prices = latest.values.toList();
                return ListView.builder(
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final doc = prices[index];
                    final priceData = doc.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(priceData['store_name'] ?? ''),
                      trailing: Text(
                        'R\$ ${(priceData['price'] as num).toStringAsFixed(2)}',
                        style: AppTheme.priceTextStyle,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPricePage(product: product),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
