import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
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
    final isAdmin = ref.watch(isAdminProvider);

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
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteStore(context),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((data['image_url'] as String?)?.isNotEmpty == true)
            Image.network(
              data['image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
          else if ((data['map_image_url'] as String?)?.isNotEmpty == true)
            Image.network(
              data['map_image_url'],
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            )
          else if (data['latitude'] != null && data['longitude'] != null)
            Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=${data['latitude']},${data['longitude']}&zoom=16&size=600x200&markers=color:red%7C${data['latitude']},${data['longitude']}&key=${AppConstants.googleMapsApiKey}',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
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
                child: GridView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: AppTheme.paddingMedium,
                    mainAxisSpacing: AppTheme.paddingMedium,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: prices.length,
                  itemBuilder: (context, index) {
                    final doc = prices[index];
                    final priceData = doc.data() as Map<String, dynamic>;
                    final productName = priceData['product_name'] as String? ?? '';
                    final productId = priceData['product_id'] as String?;
                    final info = productId != null ? _productInfo[productId] : null;
                    final String? imageUrl =
                        info != null ? info['image_url'] as String? : null;
                    final volume = info != null ? info['volume'] : null;
                    final unit = info != null ? info['unit'] : null;
                    var label = productName;
                    if (volume != null && unit != null && unit != 'un') {
                      label = '$productName (${volume.toString()} $unit)';
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PriceDetailPage(price: doc),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.paddingSmall),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: imageUrl != null && imageUrl.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall),
                                        child: Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.shopping_bag,
                                        size: 40,
                                        color: AppTheme.primaryColor,
                                      ),
                              ),
                              const SizedBox(height: AppTheme.paddingSmall),
                                Text(
                                  label,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                Formatters.formatPrice((priceData['price'] as num).toDouble()),
                                textAlign: TextAlign.center,
                                style: AppTheme.priceTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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

  Future<void> _deleteStore(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Comércio'),
        content: const Text('Tem certeza que deseja excluir este comércio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await widget.store.reference.delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comércio excluído')),
        );
      }
    }
  }
}
