import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_favorites_provider.dart';

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
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final priceData = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(priceData['product_name'] ?? ''),
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
