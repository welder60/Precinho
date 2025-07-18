import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../../core/utils/formatters.dart';
import 'package:precinho_app/presentation/widgets/app_cached_image.dart';

class ManageProductsPage extends StatelessWidget {
  const ManageProductsPage({super.key});

  Future<void> _deleteProduct(BuildContext context, DocumentReference doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: const Text('Tem certeza que deseja excluir este produto?'),
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
      FirebaseLogger.log('Deleting product', {'path': doc.path});
      await doc.delete();
      FirebaseLogger.log('Product deleted', {'path': doc.path});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto exclu\u00eddo')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('updated_at')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            FirebaseLogger.log('Products snapshot',
                {'count': snapshot.data!.docs.length});
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar produtos'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum produto cadastrado'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final updatedAt =
                  (data['updated_at'] as Timestamp?)?.toDate();
              return ListTile(
                leading: ClipOval(
                  child: AppCachedImage(
                    imageUrl: data['image_url'] as String?,
                    width: 40,
                    height: 40,
                  ),
                ),
                title: Text(data['name'] ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${data['brand'] ?? ''} - ${data['barcode'] ?? ''}",
                    ),
                    Text(data['description'] ?? ''),
                    if (updatedAt != null)
                      Text('Atualizado em: '
                          '${Formatters.formatDateTime(updatedAt)}'),
                  ],
                ),
                isThreeLine: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductPage(document: doc),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                  onPressed: () => _deleteProduct(context, doc.reference),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_products_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
