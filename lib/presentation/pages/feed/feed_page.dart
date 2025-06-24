import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../price/price_detail_page.dart';
import '../price/price_photo_page.dart';
import '../invoice/invoice_qr_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final Map<String, Map<String, dynamic>> _productInfo = {};
  final Map<String, Map<String, dynamic>> _userInfo = {};
  final List<DocumentSnapshot> _docs = [];
  final ScrollController _controller = ScrollController();
  DocumentSnapshot? _lastDoc;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
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
        .where('isApproved', isEqualTo: true)
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

      if (productIds.any((id) => !_productInfo.containsKey(id))) {
        await _fetchProducts(productIds);
      }
      if (userIds.any((id) => !_userInfo.containsKey(id))) {
        await _fetchUsers(userIds);
      }
    } else {
      _hasMore = false;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In\u00edcio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PricePhotoPage()),
              );
            },
          ),
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
      body: _docs.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _controller,
              itemCount: _docs.length + (_hasMore ? 1 : 0),
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemBuilder: (context, index) {
                if (index >= _docs.length) {
                  return const Padding(
                    padding: EdgeInsets.all(AppTheme.paddingMedium),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final doc = _docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final productId = data['product_id'] as String?;
              final userId = data['user_id'] as String?;
              final product = productId != null ? _productInfo[productId] : null;
              final user = userId != null ? _userInfo[userId] : null;
              final productImage = product?['image_url'] as String?;
              final userPhoto = user?['photo_url'] as String?;
              final userName = user?['name'] as String? ?? 'Usu\u00e1rio';

              return Card(
                child: ListTile(
                  leading: productImage != null && productImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Image.network(
                            productImage,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.shopping_bag,
                          color: AppTheme.primaryColor,
                        ),
                  title: Text(data['product_name'] ?? 'Produto'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['store_name'] ?? ''),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (userPhoto != null && userPhoto.isNotEmpty)
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(userPhoto),
                            )
                          else
                            const CircleAvatar(
                              radius: 10,
                              child: Icon(Icons.person, size: 12),
                            ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              userName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Formatters.formatPrice((data['price'] as num).toDouble()),
                        style: AppTheme.priceTextStyle,
                      ),
                      if (data['variation'] != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (data['variation'] as num) > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: (data['variation'] as num) > 0
                                  ? AppTheme.errorColor
                                  : AppTheme.successColor,
                              size: 14,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              Formatters.formatPercentage(
                                  ((data['variation'] as num).abs()).toDouble()),
                              style: TextStyle(
                                color: (data['variation'] as num) > 0
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
                ),
              );
            },
          ),
    );
  }
}
