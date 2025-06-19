import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/shopping_list_provider.dart';

class ShoppingListDetailPage extends ConsumerWidget {
  final String listId;
  const ShoppingListDetailPage({required this.listId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(shoppingListProvider).firstWhere((e) => e.id == listId);
    final totals = ref.read(shoppingListProvider.notifier).totalsByStore(listId);
    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          ...list.items.map(
            (item) => ListTile(
              title: Text(item.productName),
              subtitle: Text(item.storeName ?? '-'),
              trailing: Text(
                item.price != null
                    ? '${item.quantity} x ${item.price!.toStringAsFixed(2)}'
                    : item.quantity.toString(),
              ),
            ),
          ),
          const Divider(),
          ...totals.entries.map(
            (e) => ListTile(
              title: Text(e.key),
              trailing: Text('R\$ ${e.value.toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }
}
