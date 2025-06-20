import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/shopping_list_provider.dart';
import '../../providers/store_favorites_provider.dart';
import '../product/product_search_page.dart';

class ShoppingListDetailPage extends ConsumerStatefulWidget {
  final String listId;
  const ShoppingListDetailPage({required this.listId, super.key});

  @override
  ConsumerState<ShoppingListDetailPage> createState() => _ShoppingListDetailPageState();
}

class _ShoppingListDetailPageState extends ConsumerState<ShoppingListDetailPage> {
  final List<DocumentSnapshot> _stores = [];
  bool _isLoadingStores = false;
  String? _selectedStoreId;
  String? _selectedStoreName;
  final Map<String, double> _storeTotals = {};

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoadingStores = true;
    });

    final favorites = ref.read(storeFavoritesProvider);
    final collection = FirebaseFirestore.instance.collection('stores');

    final Map<String, DocumentSnapshot> found = {};

    for (final id in favorites) {
      try {
        final doc = await collection.doc(id).get();
        if (doc.exists) {
          found[id] = doc;
        }
      } catch (_) {}
    }

    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        final position = await Geolocator.getCurrentPosition();
        final snap = await collection.get();
        const radius = 2000.0;
        for (final doc in snap.docs) {
          final data = doc.data();
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();
          if (lat == null || lng == null) continue;
          final dist = Geolocator.distanceBetween(
            position.latitude,
            position.longitude,
            lat,
            lng,
          );
          if (dist <= radius && !found.containsKey(doc.id)) {
            found[doc.id] = doc;
          }
        }
      }
    } catch (_) {}

    setState(() {
      _stores
        ..clear()
        ..addAll(found.values);
    });

    await _calculateTotals();

    setState(() {
      _isLoadingStores = false;
    });
  }

  Future<void> _calculateTotals() async {
    final list = ref
        .read(shoppingListProvider)
        .firstWhere((e) => e.id == widget.listId);

    final totals = <String, double>{};

    for (final store in _stores) {
      double sum = 0;
      for (final item in list.items) {
        try {
          final snap = await FirebaseFirestore.instance
              .collection('prices')
              .where('product_id', isEqualTo: item.productId)
              .where('store_id', isEqualTo: store.id)
              .where('isApproved', isEqualTo: true)
              .orderBy('created_at', descending: true)
              .limit(1)
              .get();

          if (snap.docs.isNotEmpty) {
            final data = snap.docs.first.data();
            final price = (data['price'] as num?)?.toDouble();
            if (price != null) {
              sum += price * item.quantity;
            }
          }
        } catch (_) {}
      }

      final name = (store.data() as Map<String, dynamic>)['name'] ?? 'Loja';
      totals[name] = sum;
    }

    setState(() {
      _storeTotals
        ..clear()
        ..addAll(totals);
    });
  }

  Future<void> _applyStore(DocumentSnapshot store) async {
    final notifier = ref.read(shoppingListProvider.notifier);
    final list = notifier.getList(widget.listId);
    if (list == null) return;
    setState(() {
      _selectedStoreId = store.id;
      _selectedStoreName =
          (store.data() as Map<String, dynamic>)['name'] ?? 'Loja';
    });

    for (final item in list.items) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('prices')
            .where('product_id', isEqualTo: item.productId)
            .where('store_id', isEqualTo: store.id)
            .where('isApproved', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          final data = snap.docs.first.data();
          final price = (data['price'] as num?)?.toDouble();
          notifier.updateItemPrice(
            listId: widget.listId,
            productId: item.productId,
            price: price,
            storeId: store.id,
            storeName: _selectedStoreName,
          );
        } else {
          notifier.updateItemPrice(
            listId: widget.listId,
            productId: item.productId,
            price: null,
            storeId: store.id,
            storeName: _selectedStoreName,
          );
        }
      } catch (_) {
        notifier.updateItemPrice(
          listId: widget.listId,
          productId: item.productId,
          price: null,
          storeId: store.id,
          storeName: _selectedStoreName,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(shoppingListProvider).firstWhere((e) => e.id == widget.listId);

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        children: [
          ...list.items.map(
            (item) {
              return ListTile(
                title: Text(item.productName),
                subtitle: Text(item.storeName ?? '-'),
                trailing: Text(
                  item.price != null
                      ? '${item.quantity} x ${item.price!.toStringAsFixed(2)}'
                      : '${item.quantity} x -',
                ),
              );
            },
          ),
          const Divider(),
          if (_isLoadingStores)
            const Center(child: CircularProgressIndicator())
          else if (_stores.isNotEmpty) ...[
            Text(
              'Estabelecimentos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (_selectedStoreName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: Text('Selecionado: $_selectedStoreName'),
              ),
            const SizedBox(height: AppTheme.paddingSmall),
            Column(
              children: _stores.map((doc) {
                final name =
                    (doc.data() as Map<String, dynamic>)['name'] ?? 'Loja';
                final total = _storeTotals[name];
                return ListTile(
                  title: Text(name),
                  trailing: Text(
                    total != null ? Formatters.formatPrice(total) : '-',
                  ),
                  selected: doc.id == _selectedStoreId,
                  onTap: () => _applyStore(doc),
                );
              }).toList(),
            ),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addProduct(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct(BuildContext context) async {
    final product = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          onSelected: (doc) => Navigator.pop(context, doc),
        ),
      ),
    );

    if (product == null) return;

    final data = product.data() as Map<String, dynamic>;
    final controller = TextEditingController(text: '1');

    final quantity = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar produto'),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Quantidade'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final q = double.tryParse(controller.text) ?? 1;
              Navigator.pop(context, q);
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (quantity == null) return;

    ref.read(shoppingListProvider.notifier).addProductToList(
          listId: widget.listId,
          productId: product.id,
          productName: data['name'] ?? 'Produto',
          quantity: quantity,
        );
  }
}
