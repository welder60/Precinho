import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import 'price_detail_page.dart';

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
              final status = ModerationStatus.values.firstWhere(
                (e) => e.value == (data['status'] as String? ?? ''),
                orElse: () => ModerationStatus.pending,
              );
              final imageUrl = data['image_url'] as String?;
              return ListTile(
                leading: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover)
                    : const Icon(Icons.photo),
                title: Text(data['product_name'] ?? 'Produto'),
                subtitle: Text('${data['store_name'] ?? 'Comércio'}\n${status.displayName}'),
                isThreeLine: true,
                trailing: Text(
                  data['price'] != null
                      ? Formatters.formatPrice((data['price'] as num).toDouble())
                      : '-',
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
              );
            },
          );
        },
      ),
    );
  }
}
