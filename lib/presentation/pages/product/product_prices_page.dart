import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/store_favorites_provider.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';
import 'product_detail_page.dart';

class ProductPricesPage extends ConsumerWidget {
  final DocumentSnapshot product;
  const ProductPricesPage({required this.product, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(storeFavoritesProvider);
    final data = product.data() as Map<String, dynamic>;

    print('[DEBUG] Exibindo preços para o produto: ${data['name']} (ID: ${product.id})');

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Produto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailPage(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prices')
            .where('product_id', isEqualTo: product.id)
            .where('isApproved', isEqualTo: true)
			.orderBy('price')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];
          print('[DEBUG] Total de preços retornados do Firestore: ${docs.length}');

          for (final doc in docs) {
            print('[DEBUG] Documento de preço: ${doc.id} -> ${doc.data()}');
          }

          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum preço para este produto'));
          }

          final Map<String, DocumentSnapshot> latest = {};
          for (final doc in docs) {
            try {
              final priceData = doc.data() as Map<String, dynamic>;
              final storeId = priceData['store_id'] as String?;
              if (storeId == null) continue;
              if (!latest.containsKey(storeId)) {
                latest[storeId] = doc;
              }
            } catch (e) {
              print('[ERRO] Falha ao processar documento de preço: ${doc.id} -> $e');
            }
          }

          final prices = latest.values.toList()
            ..sort((a, b) {
              final aFav = favorites.contains((a.data() as Map<String, dynamic>)['store_id']) ? 0 : 1;
              final bFav = favorites.contains((b.data() as Map<String, dynamic>)['store_id']) ? 0 : 1;
              return aFav.compareTo(bFav);
            });

          return ListView.builder(
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final doc = prices[index];
              final priceData = doc.data() as Map<String, dynamic>;
              final storeId = priceData['store_id'] as String?;
              final storeName = priceData['store_name'] as String? ?? 'Loja desconhecida';
              final isFav = storeId != null && favorites.contains(storeId);

                  print('[DEBUG] Exibindo preço de ${storeName} -> '
                      '${Formatters.formatPrice((priceData['price'] as num).toDouble())}');

              return ListTile(
                leading: const Icon(Icons.store, color: AppTheme.primaryColor),
                title: Text(storeName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatPrice((priceData['price'] as num).toDouble()),
                      style: AppTheme.priceTextStyle,
                    ),
                    IconButton(
                      icon: Icon(
                        isFav ? Icons.star : Icons.star_border,
                        color:
                            isFav ? Colors.amber : AppTheme.textSecondaryColor,
                      ),
                      onPressed: storeId == null
                          ? null
                          : () {
                              ref
                                  .read(storeFavoritesProvider.notifier)
                                  .toggleFavorite(storeId);
                            },
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
