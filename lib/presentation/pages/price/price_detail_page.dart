import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';

class PriceDetailPage extends StatelessWidget {
  final DocumentSnapshot price;

  const PriceDetailPage({required this.price, super.key});

  @override
  Widget build(BuildContext context) {
    final data = price.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Preço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['product_name'] ?? 'Produto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Estabelecimento: ${data['store_name'] ?? ''}',
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'R\$ ${(data['price'] as num).toStringAsFixed(2)}',
              style: AppTheme.priceTextStyle,
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            const Text('Mais detalhes ser\u00e3o implementados futuramente.'),
          ],
        ),
      ),
    );
  }
}
