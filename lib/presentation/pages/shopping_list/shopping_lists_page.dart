import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';

class ShoppingListsPage extends ConsumerStatefulWidget {
  const ShoppingListsPage({super.key});

  @override
  ConsumerState<ShoppingListsPage> createState() => _ShoppingListsPageState();
}

class _ShoppingListsPageState extends ConsumerState<ShoppingListsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateListDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemCount: 5, // Placeholder
        itemBuilder: (context, index) {
          return _buildShoppingListCard(index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateListDialog(context);
        },
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShoppingListCard(int index) {
    final isCompleted = index == 2; // Placeholder
    final itemCount = 5 + index;
    final completedItems = isCompleted ? itemCount : index + 2;
    final progress = completedItems / itemCount;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: InkWell(
        onTap: () {
          // TODO: Navegar para detalhes da lista
        },
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lista ${index + 1}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppTheme.paddingSmall),
                        Text(
                          'Criada em ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Text(
                      isCompleted ? 'Concluída' : 'Em andamento',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isCompleted 
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                      ),
                    ),
                  ),

                  // Menu
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Excluir', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      // TODO: Implementar ações
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Progresso
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppTheme.backgroundColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCompleted ? AppTheme.successColor : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Text(
                    '$completedItems/$itemCount',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingMedium),

              // Informações adicionais
              Row(
                children: [
                  Icon(
                    Icons.shopping_basket,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    '$itemCount itens',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    'R\$ ${(50.0 + index * 10).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                  const Spacer(),
                  if (!isCompleted)
                    TextButton(
                      onPressed: () {
                        // TODO: Continuar compras
                      },
                      child: const Text('Continuar'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Lista de Compras'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nome da lista',
            hintText: 'Ex: Compras da semana',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                // TODO: Criar lista
                Navigator.pop(context);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

