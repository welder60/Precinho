import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import 'price_detail_page.dart';
import 'package:precinho_app/presentation/widgets/app_cached_image.dart';
import 'package:precinho_app/presentation/widgets/avg_comparison_icon.dart';

class UserPricesPage extends ConsumerWidget {
  const UserPricesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final stream = FirebaseFirestore.instance
        .collection('prices')
        .where('user_id', isEqualTo: user.id)
        .where('is_active', isEqualTo: true)
        .orderBy('created_at', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Preços')),
      body: StreamBuilder<QuerySnapshot>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum preço cadastrado'));
          }
          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final imageUrl = data['image_url'] as String?;
              final expiresAt =
                  (data['expires_at'] as Timestamp?)?.toDate();
              final expired = expiresAt != null && DateTime.now().isAfter(expiresAt);
              final isActive = data['is_active'] as bool? ?? true;
              return ListTile(
                leading: AppCachedImage(
                  imageUrl: imageUrl,
                  width: 56,
                  height: 56,
                ),
                title: Text(data['product_name'] ?? 'Produto'),
                subtitle: Text(data['store_name'] ?? 'Comércio'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data['price'] != null
                          ? Formatters.formatPrice((data['price'] as num).toDouble())
                          : '-',
                      style: AppTheme.priceTextStyle.copyWith(
                        decoration: isActive ? null : TextDecoration.lineThrough,
                        color:
                            isActive ? AppTheme.primaryColor : AppTheme.textDisabledColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AvgComparisonIcon(
                        comparison: data['avg_comparison'] as String?),
                    if (expired)
                      IconButton(
                        icon: const Icon(Icons.warning,
                            color: AppTheme.warningColor, size: 20),
                        tooltip: 'Preço pode estar desatualizado',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Este preço pode estar desatualizado')),
                          );
                        },
                        padding: EdgeInsets.zero,
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
          );
        },
      ),
    );
  }
}
