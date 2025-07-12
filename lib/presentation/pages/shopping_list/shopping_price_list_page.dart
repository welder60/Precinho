import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/shopping_list_provider.dart';
import '../../../domain/entities/shopping_list.dart';

class ShoppingPriceListPage extends ConsumerWidget {
  final String listId;
  const ShoppingPriceListPage({required this.listId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list =
        ref.watch(shoppingListProvider).firstWhere((l) => l.id == listId);

    final Map<String, List<ShoppingListItem>> groups = {};
    for (final item in list.items) {
      final store = item.storeName ?? 'Comércio';
      groups.putIfAbsent(store, () => []).add(item);
    }
    final stores = groups.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];
          final items = groups[store]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: Text(
                  store,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ...items.map((item) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.paddingSmall),
                  child: Row(
                    children: [
                      Checkbox(
                        value: item.isCompleted,
                        onChanged: (_) {
                          ref
                              .read(shoppingListProvider.notifier)
                              .toggleItemCompleted(
                                listId: listId,
                                itemId: item.id,
                              );
                        },
                      ),
                      Expanded(child: Text(item.productName)),
                      Opacity(
                        opacity: item.isCompleted ? 0.5 : 1.0,
                        child: Text(
                          item.price != null
                              ? Formatters.formatPrice(item.price!)
                              : '-',
                          style: AppTheme.priceTextStyle,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: AppTheme.paddingMedium),
            ],
          );
        },
      ),
    );
  }
}
