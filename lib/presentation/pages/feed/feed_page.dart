import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shopping_list_provider.dart';
import '../../widgets/feed/feed_price_list.dart';
import '../invoice/invoice_qr_page.dart';
import '../auth/login_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  final Map<String, Map<String, dynamic>> _productInfo = {};
  final Map<String, Map<String, dynamic>> _userInfo = {};
  final Map<String, Map<String, dynamic>> _storeInfo = {};
  final List<DocumentSnapshot> _docs = [];
  final ScrollController _controller = ScrollController();
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _loadLocation();
    _fetchMore();
    _controller.addListener(() {
      if (_controller.position.pixels >=
              _controller.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    try {
      final perm = await Geolocator.requestPermission();
      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        _position = pos;
      }
    } catch (_) {}
  }

  Future<void> _fetchStores(Iterable<String> ids) async {
    final missing = ids.where((id) => !_storeInfo.containsKey(id)).toList();
    for (var i = 0; i < missing.length; i += 10) {
      final chunk = missing.sublist(i, i + 10 > missing.length ? missing.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('stores')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        _storeInfo[doc.id] = doc.data();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchProducts(Iterable<String> ids) async {
    final missing = ids.where((id) => !_productInfo.containsKey(id)).toList();
    for (var i = 0; i < missing.length; i += 10) {
      final chunk = missing.sublist(i, i + 10 > missing.length ? missing.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('products')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        _productInfo[doc.id] = doc.data();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchUsers(Iterable<String> ids) async {
    final missing = ids.where((id) => !_userInfo.containsKey(id)).toList();
    for (var i = 0; i < missing.length; i += 10) {
      final chunk = missing.sublist(i, i + 10 > missing.length ? missing.length : i + 10);
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        _userInfo[doc.id] = doc.data();
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _fetchMore() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('prices')
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .limit(20);
    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snap = await query.get();
    if (snap.docs.isNotEmpty) {
      _lastDoc = snap.docs.last;
      _docs.addAll(snap.docs);
      final productIds = _docs
          .map((d) => (d.data() as Map<String, dynamic>)['product_id'] as String?)
          .whereType<String>()
          .toSet();
      final userIds = _docs
          .map((d) => (d.data() as Map<String, dynamic>)['user_id'] as String?)
          .whereType<String>()
          .toSet();
      final storeIds = _docs
          .map((d) => (d.data() as Map<String, dynamic>)['store_id'] as String?)
          .whereType<String>()
          .toSet();

      if (productIds.any((id) => !_productInfo.containsKey(id))) {
        await _fetchProducts(productIds);
      }
      if (userIds.any((id) => !_userInfo.containsKey(id))) {
        await _fetchUsers(userIds);
      }
      if (storeIds.any((id) => !_storeInfo.containsKey(id))) {
        await _fetchStores(storeIds);
      }
    } else {
      _hasMore = false;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _refresh() async {
    _docs.clear();
    _lastDoc = null;
    _hasMore = true;
    await _fetchMore();
  }


  Future<void> _addToList(DocumentSnapshot doc) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
      return;
    }
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

    final data = doc.data() as Map<String, dynamic>;
    ref.read(shoppingListProvider.notifier).addProductToList(
      listId: listId,
      productId: data['product_id'],
      productName: data['product_name'] ?? 'Produto',
      quantity: quantity,
      price: (data['price'] as num?)?.toDouble(),
      storeId: data['store_id'],
      storeName: data['store_name'],
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adicionado à lista')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In\u00edcio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoiceQrPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'feed_page_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InvoiceQrPage()),
          );
        },
        icon: const Icon(Icons.qr_code),
        label: const Text('Ler nota'),
      ),
      body: FeedPriceList(
        controller: _controller,
        docs: _docs,
        hasMore: _hasMore,
        isLoading: _isLoading,
        position: _position,
        productInfo: _productInfo,
        userInfo: _userInfo,
        storeInfo: _storeInfo,
        onAdd: _addToList,
      ),
    );
  }
}
