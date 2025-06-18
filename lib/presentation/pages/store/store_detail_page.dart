import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/store_favorites_provider.dart';

class StoreDetailPage extends ConsumerWidget {
  final DocumentSnapshot store;
  const StoreDetailPage({required this.store, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = store.data() as Map<String, dynamic>;
    final isFav = ref.watch(storeFavoritesProvider).contains(store.id);

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
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(data['address'] ?? ''),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('store', isEqualTo: data['name'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum preço para este estabelecimento'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final priceData = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(priceData['product'] ?? ''),
                      trailing: Text(
                        'R\$ ${(priceData['price'] as num).toStringAsFixed(2)}',
                        style: AppTheme.priceTextStyle,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
