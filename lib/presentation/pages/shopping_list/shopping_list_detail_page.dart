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
  final Set<String> _selectedStores = {};

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(shoppingListProvider).firstWhere((e) => e.id == widget.listId);
    final totals = ref.read(shoppingListProvider.notifier).totalsByStore(widget.listId);

    final storeOptions = totals.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          ...list.items.map(
            (item) {
              return ListTile(
                title: Text(item.productName),
                subtitle: Text(item.storeName ?? '-'),
                trailing: Text(
                  item.price != null
                      ? '${item.quantity} x ${item.price!.toStringAsFixed(2)}'
                      : item.quantity.toString(),
                ),
              );
            },
          ),
          const Divider(),
          ...storeOptions.map(
            (s) {
              final selected = _selectedStores.contains(s);
              return CheckboxListTile(
                value: selected,
                title: Text(s),
                secondary: selected
                    ? Text('R\$ ${totals[s]!.toStringAsFixed(2)}')
                    : null,
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedStores.add(s);
                    } else {
                      _selectedStores.remove(s);
                    }
                  });
                },
              );
            },
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
