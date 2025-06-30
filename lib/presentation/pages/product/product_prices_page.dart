import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/enums.dart';
import '../../providers/store_favorites_provider.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';
import 'product_detail_page.dart';

class ProductPricesPage extends ConsumerStatefulWidget {
  final DocumentSnapshot product;
  const ProductPricesPage({required this.product, super.key});

  @override
  ConsumerState<ProductPricesPage> createState() => _ProductPricesPageState();
}

class _ProductPricesPageState extends ConsumerState<ProductPricesPage> {
  final Map<String, Map<String, dynamic>> _storeInfo = {};

  Future<void> _fetchStores(Iterable<String> ids) async {
    final missing = ids.where((id) => !_storeInfo.containsKey(id)).toList();
    for (var i = 0; i < missing.length; i += 10) {
      final chunk = missing.sublist(i, i + 10 > missing.length ? missing.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        _storeInfo[doc.id] = doc.data();
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(storeFavoritesProvider);
    final data = widget.product.data() as Map<String, dynamic>;

    print('[DEBUG] Exibindo preços para o produto: ${data['name']} (ID: ${widget.product.id})');

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
                  builder: (_) => ProductDetailPage(product: widget.product),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (data['image_url'] != null &&
              (data['image_url'] as String).isNotEmpty)
            Image.network(
              data['image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('product_id', isEqualTo: widget.product.id)
                  .where('status',
                      isEqualTo: ModerationStatus.approved.value)
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

          final storeIds = latest.values
              .map((d) => (d.data() as Map<String, dynamic>)['store_id'] as String?)
              .whereType<String>()
              .toSet();

          if (storeIds.any((id) => !_storeInfo.containsKey(id))) {
            Future.microtask(() => _fetchStores(storeIds));
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
              final storeName = priceData['store_name'] as String? ?? 'Comércio desconhecido';
              final isFav = storeId != null && favorites.contains(storeId);

                  print('[DEBUG] Exibindo preço de ${storeName} -> '
                      '${Formatters.formatPrice((priceData['price'] as num).toDouble())}');

              final storeData = storeId != null ? _storeInfo[storeId] : null;

              return ListTile(
                leading: const Icon(
                  Icons.store,
                  color: AppTheme.primaryColor,
                ),
                title: Text(storeName),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Formatters.formatPrice((priceData['price'] as num).toDouble()),
                          style: AppTheme.priceTextStyle,
                        ),
                        if (priceData['variation'] != null)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                (priceData['variation'] as num) > 0
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: (priceData['variation'] as num) > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.successColor,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                Formatters.formatPercentage(
                                    ((priceData['variation'] as num).abs()).toDouble()),
                                style: TextStyle(
                                  color: (priceData['variation'] as num) > 0
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
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
    ),
  ],
),
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_prices_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPricePage(product: widget.product),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
