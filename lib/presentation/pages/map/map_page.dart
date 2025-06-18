import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';

class MapPage extends ConsumerStatefulWidget {
  const MapPage({super.key});

  @override
  ConsumerState<MapPage> createState() => _MapPageState();
}

class _MapPageState extends ConsumerState<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Preços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Centralizar no usuário
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Placeholder para o mapa
          Container(
            color: AppTheme.backgroundColor,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: AppTheme.textSecondaryColor,
                  ),
                  SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    'Mapa será implementado aqui',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: AppTheme.paddingSmall),
                  Text(
                    'Mostrará preços próximos à sua localização',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textDisabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Barra de busca flutuante
          Positioned(
            top: AppTheme.paddingMedium,
            left: AppTheme.paddingMedium,
            right: AppTheme.paddingMedium,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    const Expanded(
                      child: Text(
                        'Buscar produtos...',
                        style: TextStyle(
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.tune,
                        color: AppTheme.primaryColor,
                      ),
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Lista de preços próximos (bottom sheet)
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle do sheet
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: AppTheme.paddingSmall,
                      ),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Título
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Preços Próximos',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              // TODO: Ver todos
                            },
                            child: const Text('Ver todos'),
                          ),
                        ],
                      ),
                    ),

                    // Lista de preços
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('prices')
                            .orderBy('created_at', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return const Center(child: Text('Erro ao carregar preços'));
                          }
                          final docs = snapshot.data?.docs ?? [];
                          if (docs.isEmpty) {
                            return const Center(child: Text('Nenhum preço cadastrado'));
                          }
                          return ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.paddingMedium,
                            ),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              return _buildPriceCard(data);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(Map<String, dynamic> data) {
    final value = (data['price'] as num?)?.toDouble() ?? 0.0;
    final product = data['product_name'] ?? 'Produto';
    final store = data['store_name'] ?? 'Loja';
    final createdAt = (data['created_at'] as Timestamp?)?.toDate();
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: const Icon(
            Icons.shopping_basket,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(product),
        subtitle: Text('$store${createdAt != null ? ' • ${_formatDate(createdAt)}' : ''}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: AppTheme.priceTextStyle,
            ),
            if (createdAt != null)
              Text(
                _timeAgo(createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondaryColor,
                ),
              ),
          ],
        ),
        onTap: () {
          // TODO: Ver detalhes do preço
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return 'há ${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return 'há ${diff.inHours}h';
    } else {
      return 'há ${diff.inDays}d';
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filtros serão implementados aqui'),
            SizedBox(height: AppTheme.paddingMedium),
            Text('• Categoria de produto'),
            Text('• Raio de busca'),
            Text('• Faixa de preço'),
            Text('• Tipo de estabelecimento'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}

