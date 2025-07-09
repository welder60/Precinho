import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../admin/edit_product_page.dart';

import '../../../data/datasources/cosmos_service.dart';
import '../../../core/themes/app_theme.dart';

class ProductDetailPage extends ConsumerWidget {
  final DocumentSnapshot product;
  const ProductDetailPage({required this.product, super.key});

  Future<void> _updateFromCosmos(BuildContext context) async {
    final data = product.data() as Map<String, dynamic>;
    final ean = data['barcode'] as String?;
    if (ean == null || ean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produto sem codigo de barras')),
      );
      return;
    }
    try {
      final cosmos = await CosmosService().fetchProduct(ean);
      if (cosmos == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto nao encontrado')),
        );
        return;
      }
      final productData = cosmos['product'] as Map<String, dynamic>? ?? cosmos;
      final updates = <String, dynamic>{};
      if (productData['description'] != null) {
        updates['name'] = productData['description'];
      }
      final brand = productData['brand'];
      if (brand is Map && brand['name'] != null) {
        updates['brand'] = brand['name'];
      } else if (brand is String) {
        updates['brand'] = brand;
      }
      final picture = productData['picture'] ?? cosmos['thumbnail'];
      if (picture is String && picture.isNotEmpty) {
        updates['image_url'] = picture;
      }
      final ncm = (productData['ncm'] as Map<String, dynamic>?)?['code'];
      if (ncm != null) {
        updates['ncm_code'] = ncm;
      }
      if (updates.isNotEmpty) {
        updates['updated_at'] = Timestamp.now();
        await product.reference.update(updates);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados')), 
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao consultar Cosmos: $e')),
      );
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = product.data() as Map<String, dynamic>;
    final isAdmin = ref.watch(isAdminProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Produto'),
        actions: [
          if (isAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProductPage(document: product),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _updateFromCosmos(context),
            ),
          ],
        ],
      ),
      body: ListView(
        children: [
          if (data['image_url'] != null && (data['image_url'] as String).isNotEmpty)
            Image.network(
              data['image_url'],
              height: 150,
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_detail_fab',
        onPressed: () => _showAddToListDialog(context, ref, data),
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  void _showAddToListDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> data) {
    final lists = ref.read(shoppingListProvider);
    final controller = TextEditingController(text: '1');
    String? selectedId = lists.isNotEmpty ? lists.first.id : null;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar à lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lists.isEmpty)
              Text('Nenhuma lista encontrada'),
            if (lists.isEmpty)
              TextButton(
                onPressed: () {
                  final id = ref
                      .read(shoppingListProvider.notifier)
                      .createList('Minha Lista');
                  selectedId = id;
                },
                child: const Text('Criar lista'),
              )
            else
              DropdownButton<String>(
                value: selectedId,
                onChanged: (v) => selectedId = v,
                items: [
                  for (final l in lists)
                    DropdownMenuItem(value: l.id, child: Text(l.name)),
                ],
              ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedId != null) {
                final quantity = double.tryParse(controller.text) ?? 1;
                ref.read(shoppingListProvider.notifier).addProductToList(
                      listId: selectedId!,
                      productId: product.id,
                      productName: data['name'] ?? 'Produto',
                      quantity: quantity,
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }
}
