import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../admin/add_product_page.dart';
import '../product/product_prices_page.dart';
import '../../providers/auth_provider.dart';
class ProductSearchPage extends ConsumerStatefulWidget {
  final ValueChanged<DocumentSnapshot>? onSelected;
  const ProductSearchPage({this.onSelected, super.key});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Produtos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: data['image_url'] != null &&
                                (data['image_url'] as String).isNotEmpty
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(data['image_url']),
                              )
                            : const Icon(Icons.shopping_bag,
                                color: AppTheme.primaryColor),
                        title: Text(data['name'] ?? 'Produto'),
                        subtitle: Text(data['brand'] ?? ''),
                        onTap: () {
                          if (widget.onSelected != null) {
                            widget.onSelected!(doc);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductPricesPage(product: doc),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Query _buildQuery() {
    final text = _controller.text.trim();
    var query = FirebaseFirestore.instance.collection('products').orderBy('name');
    if (text.isNotEmpty) {
      query = query.startAt([text]).endAt(["$text\uf8ff"]);
    }
    return query;
  }
}
