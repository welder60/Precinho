import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../store/add_store_page.dart';
import '../store/edit_store_page.dart';
import '../../../core/logging/firebase_logger.dart';

class ManageStoresPage extends StatelessWidget {
  const ManageStoresPage({super.key});

  Future<void> _deleteStore(BuildContext context, DocumentReference doc) async {
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
      FirebaseLogger.log('Deleting store', {'path': doc.path});
      await doc.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comércio excluído')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Comércios'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('stores')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar comércios'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum comércio cadastrado'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.store, color: AppTheme.primaryColor),
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['address'] ?? ''),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditStorePage(document: doc),
                    ),
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                  onPressed: () => _deleteStore(context, doc.reference),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_stores_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddStorePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
