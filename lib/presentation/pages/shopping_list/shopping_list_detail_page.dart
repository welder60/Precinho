import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/shopping_list_provider.dart';
import '../product/product_search_page.dart';

class ShoppingListDetailPage extends ConsumerStatefulWidget {
  final String listId;
  const ShoppingListDetailPage({required this.listId, super.key});

  @override
  ConsumerState<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends ConsumerState<ShoppingListDetailPage> {
  String? _selectedStore;

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(shoppingListProvider).firstWhere((e) => e.id == widget.listId);
    final totals = ref.read(shoppingListProvider.notifier).totalsByStore(widget.listId);

    final storeOptions = totals.keys.toList();
    double totalForStore = 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          if (storeOptions.isNotEmpty)
            DropdownButton<String?>(
              isExpanded: true,
              value: _selectedStore,
              hint: const Text('Selecionar estabelecimento'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Todos'),
                ),
                ...storeOptions.map(
                  (s) => DropdownMenuItem<String?>(
                    value: s,
                    child: Text(s),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStore = value;
                });
              },
            ),
          ...list.items.map(
            (item) {
              final price = _selectedStore == null
                  ? item.price
                  : item.storeName == _selectedStore
                      ? item.price
                      : null;
              if (_selectedStore != null) {
                totalForStore += (price ?? 0) * item.quantity;
              }
              return ListTile(
                title: Text(item.productName),
                subtitle: Text(item.storeName ?? '-'),
                trailing: Text(
                  price != null
                      ? '${item.quantity} x ${price.toStringAsFixed(2)}'
                      : item.quantity.toString(),
                ),
              );
            },
          ),
          const Divider(),
          if (_selectedStore == null)
            ...totals.entries.map(
              (e) => ListTile(
                title: Text(e.key),
                trailing: Text('R\$ ${e.value.toStringAsFixed(2)}'),
              ),
            )
          else
            ListTile(
              title: const Text('Total'),
              trailing: Text('R\$ ${totalForStore.toStringAsFixed(2)}'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final product = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          onSelected: (doc) => Navigator.pop(context, doc),
        ),
      ),
    );

    if (product == null) return;

    final data = product.data() as Map<String, dynamic>;
    final controller = TextEditingController(text: '1');

    final quantity = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar produto'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = double.tryParse(controller.text) ?? 1;
              Navigator.pop(context, q);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (quantity == null) return;

    ref.read(shoppingListProvider.notifier).addProductToList(
          listId: widget.listId,
          productId: product.id,
          productName: data['name'] ?? 'Produto',
          quantity: quantity,
        );
  }
}
