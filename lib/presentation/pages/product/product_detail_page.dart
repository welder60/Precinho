import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/themes/app_theme.dart';

class ProductDetailPage extends StatelessWidget {
  final DocumentSnapshot product;
  const ProductDetailPage({required this.product, super.key});

  @override
  Widget build(BuildContext context) {
    final data = product.data() as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Produto'),
      ),
      body: ListView(
        children: [
          if (data['image_url'] != null && (data['image_url'] as String).isNotEmpty)
            Image.network(
              data['image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['brand'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (data['categories'] != null) ...[
                  const SizedBox(height: AppTheme.paddingSmall),
                  Wrap(
                    spacing: 4,
                    children: List<Widget>.from(
                      (data['categories'] as List)
                          .map((c) => Chip(label: Text(c.toString()))),
                    ),
                  ),
                ],
                if (data['volume'] != null && data['unit'] != null) ...[
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text('Volume: ${data['volume']} ${data['unit']}'),
                ],
                if (data['barcode'] != null && (data['barcode'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingSmall),
                  Text('Código de barras: ${data['barcode']}'),
                ],
                if (data['description'] != null && (data['description'] as String).isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(data['description']),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
