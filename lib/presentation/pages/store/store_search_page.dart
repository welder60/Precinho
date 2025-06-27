import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/store_favorites_provider.dart';
import 'store_prices_page.dart';

class StoreSearchPage extends ConsumerStatefulWidget {
  final ValueChanged<DocumentSnapshot>? onSelected;

  const StoreSearchPage({this.onSelected, super.key});

  @override
  ConsumerState<StoreSearchPage> createState() => _StoreSearchPageState();
}

class _StoreSearchPageState extends ConsumerState<StoreSearchPage> {
  final TextEditingController _controller = TextEditingController();
  Position? _position;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _position = pos;
          });
        } else {
          _position = pos;
        }
      }
    } catch (_) {}
  }

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
        title: const Text('Buscar Com\u00e9rcios'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Buscar com\u00e9rcios...',
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
                  return const Center(child: Text('Nenhum com\u00e9rcio encontrado'));
                }
                final items = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final lat = (data['latitude'] as num?)?.toDouble();
                  final lng = (data['longitude'] as num?)?.toDouble();
                  double? distance;
                  if (_position != null && lat != null && lng != null) {
                    distance = Geolocator.distanceBetween(
                          _position!.latitude,
                          _position!.longitude,
                          lat,
                          lng,
                        ) /
                        1000.0;
                  }
                  return {'doc': doc, 'distance': distance};
                }).toList();

                if (_position != null) {
                  items.sort((a, b) {
                    final da = a['distance'] as double? ?? double.infinity;
                    final db = b['distance'] as double? ?? double.infinity;
                    return da.compareTo(db);
                  });
                } else {
                  items.sort((a, b) {
                    final aDoc = a['doc'] as DocumentSnapshot;
                    final bDoc = b['doc'] as DocumentSnapshot;
                    final aFav = favorites.contains(aDoc.id) ? 0 : 1;
                    final bFav = favorites.contains(bDoc.id) ? 0 : 1;
                    return aFav.compareTo(bFav);
                  });
                }

                return ListView.builder(
                  itemCount: items.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final doc = item['doc'] as DocumentSnapshot;
                    final data = doc.data() as Map<String, dynamic>;
                    final isFav = favorites.contains(doc.id);
                    final distance = item['distance'] as double?;
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        isThreeLine: true,
                        leading: const Icon(
                          Icons.store,
                          color: AppTheme.primaryColor,
                        ),
                        title: Text(data['name'] ?? 'Comércio'),
                        subtitle: Text(data['address'] ?? ''),
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (distance != null)
                              Text(
                                Formatters.formatDistance(distance),
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            IconButton(
                              icon: Icon(
                                isFav ? Icons.star : Icons.star_border,
                                color: isFav ? Colors.amber : AppTheme.textSecondaryColor,
                              ),
                              onPressed: () {
                                ref.read(storeFavoritesProvider.notifier).toggleFavorite(doc.id);
                              },
                            ),
                          ],
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
      // Sem ações de cadastro nesta página
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
