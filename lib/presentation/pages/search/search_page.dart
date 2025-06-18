import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../store/store_search_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  ProductCategory? _selectedCategory;
  SortType _sortType = SortType.price;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Preços'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StoreSearchPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                // Campo de busca
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // TODO: Implementar busca em tempo real
                  },
                ),
                const SizedBox(height: AppTheme.paddingMedium),

                // Filtros
                Row(
                  children: [
                    // Categoria
                    Expanded(
                      child: DropdownButtonFormField<ProductCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoria',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppTheme.paddingMedium,
                            vertical: AppTheme.paddingSmall,
                          ),
                        ),
                        items: ProductCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppTheme.paddingMedium),

                    // Ordenação
                    Expanded(
                      child: DropdownButtonFormField<SortType>(
                        value: _sortType,
                        decoration: const InputDecoration(
                          labelText: 'Ordenar por',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppTheme.paddingMedium,
                            vertical: AppTheme.paddingSmall,
                          ),
                        ),
                        items: SortType.values.map((sort) {
                          return DropdownMenuItem(
                            value: sort,
                            child: Text(sort.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _sortType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Resultados da busca
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildEmptyState()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: AppTheme.textSecondaryColor,
          ),
          SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Digite algo para buscar',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondaryColor,
            ),
          ),
          SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Encontre os melhores preços próximos a você',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDisabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      itemCount: 15, // Placeholder
      itemBuilder: (context, index) {
        return _buildProductCard(index);
      },
    );
  }

  Widget _buildProductCard(int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho do produto
            Row(
              children: [
                // Imagem do produto
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.shopping_basket,
                    color: AppTheme.primaryColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),

                // Informações do produto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Produto ${index + 1}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      Text(
                        'Marca ABC',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondaryColor,
                            ),
                      ),
                    ],
                  ),
                ),

                // Preço médio
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'A partir de',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                    Text(
                      'R\$ ${(5.99 + index).toStringAsFixed(2)}',
                      style: AppTheme.priceTextStyle,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            // Lista de preços por loja
            ...List.generate(3, (storeIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: Row(
                  children: [
                    const Icon(
                      Icons.store,
                      size: 16,
                      color: AppTheme.textSecondaryColor,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Expanded(
                      child: Text(
                        'Supermercado ${String.fromCharCode(65 + storeIndex)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Text(
                      'R\$ ${(5.99 + index + storeIndex * 0.5).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    Text(
                      '${(storeIndex + 1) * 200}m',
                      style: AppTheme.distanceTextStyle,
                    ),
                  ],
                ),
              );
            }),

            // Botão ver mais
            const SizedBox(height: AppTheme.paddingSmall),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Ver detalhes do produto
                },
                child: const Text('Ver detalhes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

