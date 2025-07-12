import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/shopping_list_provider.dart';
import 'shopping_price_list_page.dart';

class ShoppingListsPage extends ConsumerWidget {
  const ShoppingListsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(shoppingListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ],
      ),
      body: lists.isEmpty
          ? const Center(child: Text('Nenhuma lista encontrada'))
          : ListView.builder(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                final completed = list.completedItems;
                final total = list.totalItems;
                final progress = total > 0 ? completed / total : 0.0;
                return Card(
                  margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShoppingPriceListPage(listId: list.id),
                        ),
                      );
                    },
                    title: Text(list.name),
                    subtitle: LinearProgressIndicator(value: progress),
                    trailing: Text('$completed/$total'),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'shopping_lists_fab',
        onPressed: () => _showCreateListDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateListDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final id = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista de Compras'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Nome da lista'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final id = ref
                    .read(shoppingListProvider.notifier)
                    .createList(controller.text.trim());
                Navigator.pop(context, id);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (id != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ShoppingPriceListPage(listId: id),
        ),
      );
    }
  }
}
