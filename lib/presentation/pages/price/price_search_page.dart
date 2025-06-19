import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'price_detail_page.dart';

class PriceSearchPage extends StatefulWidget {
  const PriceSearchPage({super.key});

  @override
  State<PriceSearchPage> createState() => _PriceSearchPageState();
}

class _PriceSearchPageState extends State<PriceSearchPage> {
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
        title: const Text('Buscar Preços'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
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
                  return const Center(child: Text('Nenhum pre\u00e7o encontrado'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final productName = data['product_name'] as String? ?? '';
                    final storeName = data['store_name'] as String? ?? '';

                    final text = _controller.text.trim().toLowerCase();
                    if (text.isNotEmpty &&
                        !productName.toLowerCase().contains(text)) {
                      return const SizedBox.shrink();
                    }

                    return Card(
                      child: ListTile(
                        title: Text(productName.isNotEmpty ? productName : 'Produto'),
                        subtitle: Text(storeName.isNotEmpty ? storeName : 'Loja'),
                        trailing: Text(
                          Formatters.formatPrice((data['price'] as num).toDouble()),
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

  Query _buildQuery() {
    return FirebaseFirestore.instance
        .collection('prices')
        .orderBy('created_at', descending: true);
  }
}
