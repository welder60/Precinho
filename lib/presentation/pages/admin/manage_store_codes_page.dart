import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'edit_store_code_page.dart';

class ManageStoreCodesPage extends StatefulWidget {
  const ManageStoreCodesPage({super.key});

  @override
  State<ManageStoreCodesPage> createState() => _ManageStoreCodesPageState();
}

class _ManageStoreCodesPageState extends State<ManageStoreCodesPage> {
  final Map<String, String> _storeNames = {};
  final Map<String, String> _productNames = {};

  Future<void> _loadNames(String storeId, String productId) async {
    if (!_storeNames.containsKey(storeId)) {
      final doc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
      _storeNames[storeId] = (doc.data() as Map<String, dynamic>?)?['name'] ?? storeId;
    }
    if (!_productNames.containsKey(productId)) {
      final doc = await FirebaseFirestore.instance.collection('products').doc(productId).get();
      _productNames[productId] = (doc.data() as Map<String, dynamic>?)?['name'] ?? productId;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Códigos Próprios'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('store_products')
            .orderBy('code')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar códigos'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum código cadastrado'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final storeId = data['store_id'] as String? ?? '';
              final productId = data['product_id'] as String? ?? '';

              if (!_storeNames.containsKey(storeId) || !_productNames.containsKey(productId)) {
                _loadNames(storeId, productId).then((_) => setState(() {}));
              }

              final storeName = _storeNames[storeId] ?? storeId;
              final productName = _productNames[productId] ?? productId;

              return ListTile(
                leading: const Icon(Icons.code, color: AppTheme.primaryColor),
                title: Text('${data['code']} - $storeName'),
                subtitle: Text(productName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditStoreCodePage(document: doc),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
