import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/enums.dart';
import '../../providers/store_favorites_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';
import 'store_detail_page.dart';
import 'package:precinho_app/presentation/widgets/app_cached_image.dart';
import 'package:precinho_app/presentation/widgets/avg_comparison_icon.dart';

class StorePricesPage extends ConsumerStatefulWidget {
  final DocumentSnapshot store;
  const StorePricesPage({required this.store, super.key});

  @override
  ConsumerState<StorePricesPage> createState() => _StorePricesPageState();
}

class _StorePricesPageState extends ConsumerState<StorePricesPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, List<String>> _productCategories = {};
  final Map<String, Map<String, dynamic>> _productInfo = {};
  final Set<String> _selectedCategories = {};
  String _orderByField = 'price';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories(Iterable<String> ids) async {
    final missing = ids.where((id) => !_productInfo.containsKey(id)).toList();
    for (var i = 0; i < missing.length; i += 10) {
      final chunk = missing.sublist(i, i + 10 > missing.length ? missing.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        final data = doc.data();
        _productCategories[doc.id] = List<String>.from(data['categories'] ?? []);
        _productInfo[doc.id] = data;
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _addPriceToList(DocumentSnapshot price) async {
    final lists = ref.read(shoppingListProvider);
    String? selectedId = lists.isNotEmpty ? lists.first.id : null;
    final quantityController = TextEditingController(text: '1');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar à lista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lists.isNotEmpty)
              DropdownButtonFormField<String>(
                value: selectedId,
                items: [
                  for (final l in lists)
                    DropdownMenuItem(value: l.id, child: Text(l.name)),
                ],
                onChanged: (v) => selectedId = v,
                decoration: const InputDecoration(labelText: 'Lista'),
              ),
            if (lists.isEmpty)
              TextField(
                decoration: const InputDecoration(labelText: 'Nome da lista'),
                onChanged: (v) => selectedId = v,
              ),
            TextField(
              controller: quantityController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    if (result != true || selectedId == null) return;

    String listId = selectedId!;
    if (lists.isEmpty) {
      listId = ref.read(shoppingListProvider.notifier).createList(selectedId!);
    }

    final quantity = double.tryParse(quantityController.text) ?? 1;
    quantityController.dispose();

    final data = price.data() as Map<String, dynamic>;
    ref.read(shoppingListProvider.notifier).addProductToList(
      listId: listId,
      productId: data['product_id'],
      productName: data['product_name'] ?? 'Produto',
      quantity: quantity,
      price: (data['price'] as num?)?.toDouble(),
      storeId: data['store_id'] ?? widget.store.id,
      storeName: data['store_name'] ?? (widget.store.data() as Map<String, dynamic>)['name'],
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicionado à lista')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.store.data() as Map<String, dynamic>;
    final isFav = ref.watch(storeFavoritesProvider).contains(widget.store.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Com\u00e9rcio'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.amber : AppTheme.textOnPrimaryColor,
            ),
            onPressed: () {
              ref
                  .read(storeFavoritesProvider.notifier)
                  .toggleFavorite(widget.store.id);
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StoreDetailPage(store: widget.store),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(data['address'] ?? ''),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar produto...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _controller.clear(),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium),
            child: DropdownButtonFormField<String>(
              value: _orderByField,
              decoration: const InputDecoration(labelText: 'Ordenar por'),
              items: const [
                DropdownMenuItem(value: 'price', child: Text('Pre\u00e7o')),
                DropdownMenuItem(
                    value: 'unit_price', child: Text('Pre\u00e7o unit\u00e1rio')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _orderByField = v;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('store_id', isEqualTo: widget.store.id)
                  .where('is_active', isEqualTo: true)
                  .orderBy(_orderByField)
                  .snapshots(),
              builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum preço para este comércio'));
          }

          final Map<String, DocumentSnapshot> latest = {};
          final Set<String> ids = {};
          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final productId = data['product_id'] as String?;
            if (productId == null) continue;
            ids.add(productId);
            latest.putIfAbsent(productId, () => doc);
          }

          if (ids.any((id) => !_productInfo.containsKey(id))) {
            Future.microtask(() => _fetchCategories(ids));
          }

          var prices = latest.values.toList();
          final text = _controller.text.trim().toLowerCase();
          prices = prices.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final name = (data['product_name'] as String? ?? '').toLowerCase();
            if (text.isNotEmpty && !name.contains(text)) return false;
            final cats = _productCategories[data['product_id']] ?? [];
            if (_selectedCategories.isNotEmpty &&
                !cats.any(_selectedCategories.contains)) {
              return false;
            }
            return true;
          }).toList();

          final categories =
              _productCategories.values.expand((e) => e).toSet().toList();
          final bottomPadding =
              MediaQuery.of(context).padding.bottom + kToolbarHeight;

          return Column(
            children: [
              if (categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingMedium),
                  child: Row(
                    children: categories.map((c) {
                      final selected = _selectedCategories.contains(c);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              if (selected) {
                                _selectedCategories.remove(c);
                              } else {
                                _selectedCategories.add(c);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppTheme.paddingMedium,
                    AppTheme.paddingMedium,
                    AppTheme.paddingMedium,
                    bottomPadding,
                  ),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final doc = prices[index];
                    final priceData = doc.data() as Map<String, dynamic>;
                    final productName =
                        priceData['product_name'] as String? ?? '';
                    final productId = priceData['product_id'] as String?;
                    final info =
                        productId != null ? _productInfo[productId] : null;
                    final String? imageUrl =
                        info != null ? info['image_url'] as String? : null;
                    final volume = info != null ? info['volume'] as num? : null;
                    final unit = info != null ? info['unit'] as String? : null;
                    var label = productName;
                    if (volume != null && unit != null && unit != 'un') {
                      label = '$productName (${volume.toString()} $unit)';
                    }

                    final perUnit = volume != null && unit != null
                        ? Formatters.formatPricePerQuantity(
                            price: (priceData['price'] as num).toDouble(),
                            volume: volume.toDouble(),
                            unit: unit,
                          )
                        : null;

                    return SizedBox(
                      height: AppTheme.productCardHeight,
                      child: Card(
                        margin: const EdgeInsets.only(
                            bottom: AppTheme.paddingSmall),
                        child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: AppCachedImage(
                            imageUrl: imageUrl,
                            width: 56,
                            height: 56,
                          ),
                        ),
                      title: Text(label),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatPrice(
                                (priceData['price'] as num).toDouble()),
                            style: AppTheme.priceTextStyle,
                          ),
                          if (perUnit != null)
                            Text(
                              perUnit,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          if (priceData['variation'] != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  (priceData['variation'] as num) > 0
                                      ? Icons.arrow_upward
                                      : Icons.arrow_downward,
                                  color: (priceData['variation'] as num) > 0
                                      ? AppTheme.errorColor
                                      : AppTheme.successColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  Formatters.formatPercentage(
                                      ((priceData['variation'] as num).abs()).toDouble()),
                                  style: TextStyle(
                                    color: (priceData['variation'] as num) > 0
                                        ? AppTheme.errorColor
                                        : AppTheme.successColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          AvgComparisonIcon(
                            comparison: priceData['avg_comparison'] as String?,
                          ),
                          if ((priceData['expires_at'] as Timestamp?) != null &&
                              DateTime.now().isAfter(
                                  (priceData['expires_at'] as Timestamp).toDate()))
                            IconButton(
                              icon: const Icon(Icons.warning,
                                  color: AppTheme.warningColor, size: 20),
                              tooltip: 'Preço pode estar desatualizado',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Este preço pode estar desatualizado'),
                                  ),
                                );
                              },
                              padding: EdgeInsets.zero,
                            ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if ((priceData['created_at'] as Timestamp?) != null)
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Text(
                                    Formatters.formatDate(
                                        (priceData['created_at'] as Timestamp).toDate()),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(Icons.playlist_add),
                                onPressed: () => _addPriceToList(doc),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriceDetailPage(price: doc),
                          ),
                        );
                      },
                    ));
                  },
                ),
              ),
            ],
          );
        },
      ),
          ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'store_prices_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPricePage(store: widget.store),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

}
