import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_favorites_provider.dart';
import 'add_store_page.dart';
import 'store_prices_page.dart';

class StoreSearchPage extends ConsumerStatefulWidget {
  final ValueChanged<DocumentSnapshot>? onSelected;

  const StoreSearchPage({this.onSelected, super.key});

  @override
  ConsumerState<StoreSearchPage> createState() => _StoreSearchPageState();
}

class _StoreSearchPageState extends ConsumerState<StoreSearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(storeFavoritesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Estabelecimentos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar estabelecimentos...',
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
                  return const Center(child: Text('Nenhum estabelecimento encontrado'));
                }
                final sortedDocs = docs.toList()
                  ..sort((a, b) {
                    final aFav = favorites.contains(a.id) ? 0 : 1;
                    final bFav = favorites.contains(b.id) ? 0 : 1;
                    return aFav.compareTo(bFav);
                  });
                return ListView.builder(
                  itemCount: sortedDocs.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final doc = sortedDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isFav = favorites.contains(doc.id);
                    return Card(
                      child: ListTile(
                        title: Text(data['name'] ?? 'Loja'),
                        subtitle: Text(data['address'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(
                            isFav ? Icons.star : Icons.star_border,
                            color: isFav ? Colors.amber : AppTheme.textSecondaryColor,
                          ),
                          onPressed: () {
                            ref.read(storeFavoritesProvider.notifier).toggleFavorite(doc.id);
                          },
                        ),
                        onTap: () {
                          if (widget.onSelected != null) {
                            widget.onSelected!(doc);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StorePricesPage(store: doc),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddStorePage(),
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
    var query = FirebaseFirestore.instance.collection('stores').orderBy('name');
    if (text.isNotEmpty) {
      query = query.startAt([text]).endAt(["$text\uf8ff"]);
    }
    return query;
  }
}
