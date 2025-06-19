import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../price/price_detail_page.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  final Map<String, Map<String, dynamic>> _productInfo = {};
  final Map<String, Map<String, dynamic>> _userInfo = {};

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In\u00edcio'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('prices')
            .where('isApproved', isEqualTo: true)
            .orderBy('created_at', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum pre\u00e7o encontrado'));
          }

          final productIds = docs
              .map((d) => (d.data() as Map<String, dynamic>)['product_id'] as String?)
              .whereType<String>()
              .toSet();
          final userIds = docs
              .map((d) => (d.data() as Map<String, dynamic>)['user_id'] as String?)
              .whereType<String>()
              .toSet();

          if (productIds.any((id) => !_productInfo.containsKey(id))) {
            Future.microtask(() => _fetchProducts(productIds));
          }
          if (userIds.any((id) => !_userInfo.containsKey(id))) {
            Future.microtask(() => _fetchUsers(userIds));
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemBuilder: (context, index) {
              final doc = docs[index];
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
                  trailing: Text(
                    Formatters.formatPrice((data['price'] as num).toDouble()),
                    style: AppTheme.priceTextStyle,
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
          );
        },
      ),
    );
  }
}
