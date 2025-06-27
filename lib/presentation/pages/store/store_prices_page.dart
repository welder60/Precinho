import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/store_favorites_provider.dart';
import '../price/add_price_page.dart';
import '../price/price_detail_page.dart';
import 'store_detail_page.dart';

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
      body: Column(
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('prices')
                  .where('store_id', isEqualTo: widget.store.id)
                  .where('isApproved', isEqualTo: true)
                  .orderBy('price')
                  .orderBy('created_at', descending: true)
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
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
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
                    final volume = info != null ? info['volume'] : null;
                    final unit = info != null ? info['unit'] : null;
                    var label = productName;
                    if (volume != null && unit != null && unit != 'un') {
                      label = '$productName (${volume.toString()} $unit)';
                    }

                    return ListTile(
                      leading: imageUrl != null && imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              child: Image.network(
                                imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.shopping_bag,
                              color: AppTheme.primaryColor,
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
                    );
                  },
                ),
              ),
          );
        },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
