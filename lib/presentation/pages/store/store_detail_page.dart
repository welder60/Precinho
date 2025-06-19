import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_favorites_provider.dart';
import '../price/price_detail_page.dart';
import '../price/add_price_page.dart';

class StoreDetailPage extends ConsumerWidget {
  final DocumentSnapshot store;
  const StoreDetailPage({required this.store, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = store.data() as Map<String, dynamic>;
    final isFav = ref.watch(storeFavoritesProvider).contains(store.id);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Estabelecimento'),
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
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteStore(context),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['latitude'] != null && data['longitude'] != null)
            Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=${data['latitude']},${data['longitude']}&zoom=16&size=600x200&markers=color:red%7C${data['latitude']},${data['longitude']}&key=${AppConstants.googleMapsApiKey}',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(data['address'] ?? ''),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('store_id', isEqualTo: store.id)
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum preço para este estabelecimento'));
                }

                final Map<String, DocumentSnapshot> latest = {};
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final productId = data['product_id'] as String?;
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
                    return ListTile(
                      title: Text(priceData['product_name'] ?? ''),
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
        title: const Text('Excluir Estabelecimento'),
        content: const Text('Tem certeza que deseja excluir este estabelecimento?'),
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
          const SnackBar(content: Text('Estabelecimento exclu\u00eddo')),
        );
      }
    }
  }
}
