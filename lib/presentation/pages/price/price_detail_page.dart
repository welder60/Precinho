import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import 'add_price_page.dart';

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

  Future<List<DocumentSnapshot?>> _loadDocs(String? productId, String? storeId) async {
    final productDoc = productId != null
        ? await FirebaseFirestore.instance.collection('products').doc(productId).get()
        : null;
    final storeDoc = storeId != null
        ? await FirebaseFirestore.instance.collection('stores').doc(storeId).get()
        : null;
    return [productDoc, storeDoc];
  }

  @override
  Widget build(BuildContext context) {
    final data = price.data() as Map<String, dynamic>;
    final productId = data['product_id'] as String?;
    final storeId = data['store_id'] as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Preço'),
      ),
      body: FutureBuilder<List<DocumentSnapshot?>>(
        future: _loadDocs(productId, storeId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final productData =
              snapshot.data![0]?.data() as Map<String, dynamic>?;
          final storeData = snapshot.data![1]?.data() as Map<String, dynamic>?;
          final productName = productData?['name'] ?? '';
          final storeName = storeData?['name'] ?? '';
          return Padding(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName.isNotEmpty ? productName : 'Produto',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Estabelecimento: $storeName'),
                const SizedBox(height: AppTheme.paddingMedium),
                Text(
                  'R\$ ${(data['price'] as num).toStringAsFixed(2)}',
                  style: AppTheme.priceTextStyle,
                ),
                const SizedBox(height: AppTheme.paddingLarge),
                const Text('Mais detalhes ser\u00e3o implementados futuramente.'),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _updatePrice(context),
        child: const Icon(Icons.edit),
      ),
    );
  }
}
