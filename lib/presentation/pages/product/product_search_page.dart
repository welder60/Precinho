import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../admin/add_product_page.dart';
import '../product/product_prices_page.dart';
import '../../providers/auth_provider.dart';
import 'package:precinho_app/presentation/widgets/app_cached_image.dart';
class ProductSearchPage extends ConsumerStatefulWidget {
  final ValueChanged<DocumentSnapshot>? onSelected;
  const ProductSearchPage({this.onSelected, super.key});

  @override
  ConsumerState<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends ConsumerState<ProductSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final Set<String> _selectedCategories = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Produtos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
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
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhum produto encontrado'));
                }

                final categories = <String>{};
                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['categories'] != null) {
                    categories.addAll(
                      List<String>.from(data['categories'] as List),
                    );
                  }
                }

                final textFilter = _controller.text.trim().toLowerCase();
                final filtered = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String? ?? '').toLowerCase();
                  if (textFilter.isNotEmpty && !name.contains(textFilter)) {
                    return false;
                  }
                  if (_selectedCategories.isNotEmpty) {
                    final cats = (data['categories'] as List?)?.cast<String>() ?? [];
                    if (!cats.any(_selectedCategories.contains)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

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
                        itemCount: filtered.length,
                        padding:
                            const EdgeInsets.all(AppTheme.paddingMedium),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppTheme.paddingMedium,
                          mainAxisSpacing: AppTheme.paddingMedium,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          final doc = filtered[index];
                          final data = doc.data() as Map<String, dynamic>;
                          return GestureDetector(
                            onTap: () {
                              if (widget.onSelected != null) {
                                widget.onSelected!(doc);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductPricesPage(product: doc),
                                  ),
                                );
                              }
                            },
                            child: Card(
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(AppTheme.paddingSmall),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppTheme.radiusSmall),
                                        child: AppCachedImage(
                                          imageUrl: data['image_url'] as String?,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                        height: AppTheme.paddingSmall),
                                    Text(
                                      _buildLabel(data),
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
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
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              heroTag: 'product_search_fab',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Query _buildQuery() {
    final text = _controller.text.trim();
    var query = FirebaseFirestore.instance.collection('products').orderBy('name');
    if (text.isNotEmpty) {
      query = query.startAt([text]).endAt(["$text\uf8ff"]);
    }
    return query;
  }

  String _buildLabel(Map<String, dynamic> data) {
    final name = data['name'] ?? 'Produto';
    final volume = data['volume'];
    final unit = data['unit'];
    if (volume != null && unit != null && unit != 'un') {
      return '$name (${volume.toString()} $unit)';
    }
    return name;
  }
}
