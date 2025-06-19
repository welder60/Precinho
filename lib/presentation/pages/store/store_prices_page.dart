import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_favorites_provider.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';
import 'store_detail_page.dart';

class StorePricesPage extends ConsumerWidget {
  final DocumentSnapshot store;
  const StorePricesPage({required this.store, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = store.data() as Map<String, dynamic>;
    final isFav = ref.watch(storeFavoritesProvider).contains(store.id);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Com\u00e9rcio'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.amber : AppTheme.textOnPrimaryColor,
            ),
            onPressed: () {
              ref.read(storeFavoritesProvider.notifier).toggleFavorite(store.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetailPage(store: store),
                ),
              );
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteStore(context),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prices')
            .where('store_id', isEqualTo: store.id)
            .where('isApproved', isEqualTo: true)
			.orderBy('price')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum preço para este comércio'));
          }

          final Map<String, DocumentSnapshot> latest = {};
          for (final doc in docs) {
            final priceData = doc.data() as Map<String, dynamic>;
            final productId = priceData['product_id'] as String?;
            if (productId == null) continue;
            if (!latest.containsKey(productId)) {
              latest[productId] = doc;
            }
          }
          final prices = latest.values.toList();

          return ListView.builder(
            itemCount: prices.length,
            itemBuilder: (context, index) {
              final doc = prices[index];
              final priceData = doc.data() as Map<String, dynamic>;
              final productName = priceData['product_name'] as String? ?? '';

              return ListTile(
                title: Text(productName),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPricePage(store: store),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteStore(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Comércio'),
        content: const Text('Tem certeza que deseja excluir este comércio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await store.reference.delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comércio excluído')),
        );
      }
    }
  }
}
