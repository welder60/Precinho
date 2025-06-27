import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'add_product_page.dart';
import 'edit_product_page.dart';
import '../../../core/logging/firebase_logger.dart';

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
            .orderBy('name')
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
              return ListTile(
                leading: data['image_url'] != null &&
                        (data['image_url'] as String).isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(data['image_url']),
                      )
                    : const Icon(Icons.shopping_bag,
                        color: AppTheme.primaryColor),
                title: Text(data['name'] ?? ''),
                subtitle: Text(
                  "${data['brand'] ?? ''} - ${data['barcode'] ?? ''}\n${data['description'] ?? ''}",
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
