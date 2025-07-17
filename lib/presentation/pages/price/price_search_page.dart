import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import 'price_detail_page.dart';
import 'package:precinho_app/presentation/widgets/avg_comparison_icon.dart';

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
                        subtitle: Text(storeName.isNotEmpty ? storeName : 'Comércio'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              Formatters.formatPrice((data['price'] as num).toDouble()),
                              style: AppTheme.priceTextStyle,
                            ),
                            if (data['variation'] != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (data['variation'] as num) > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: (data['variation'] as num) > 0
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  Formatters.formatPercentage(
                                      ((data['variation'] as num).abs()).toDouble()),
                                  style: TextStyle(
                                    color: (data['variation'] as num) > 0
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          AvgComparisonIcon(
                              comparison: data['avg_comparison'] as String?),
                          if ((data['expires_at'] as Timestamp?) != null &&
                              DateTime.now().isAfter(
                                  (data['expires_at'] as Timestamp).toDate()))
                            IconButton(
                              icon: const Icon(Icons.warning,
                                  color: AppTheme.warningColor, size: 20),
                              tooltip: 'Preço pode estar desatualizado',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Este preço pode estar desatualizado')),
                                );
                              },
                              padding: EdgeInsets.zero,
                            ),
                          ],
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
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true);
  }
}
