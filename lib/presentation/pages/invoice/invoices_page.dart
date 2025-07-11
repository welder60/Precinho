import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import 'invoice_detail_page.dart';

class InvoicesPage extends ConsumerWidget {
  const InvoicesPage({super.key});

  Future<Map<String, dynamic>> _fetchSummary(String invoiceId) async {
    final snap = await FirebaseFirestore.instance
        .collection('prices')
        .where('invoice_id', isEqualTo: invoiceId)
        .get();
    double total = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      final discount = (data['discount'] as num?)?.toDouble() ?? 0.0;
      total += price - discount;
    }
    return {'total': total, 'count': snap.docs.length};
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Notas Fiscais')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('invoices')
            .where('user_id', isEqualTo: user.id)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma nota fiscal enviada'));
          }
          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final date = (data['created_at'] as Timestamp?)?.toDate();
              final status = ModerationStatus.values.firstWhere(
                (s) => s.value == data['status'],
                orElse: () => ModerationStatus.underReview,
              );
              return Card(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _fetchSummary(doc.id),
                  builder: (context, summarySnapshot) {
                    Widget trailing;
                    if (!summarySnapshot.hasData) {
                      trailing = const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      final total =
                          summarySnapshot.data!['total'] as double? ?? 0.0;
                      final count = summarySnapshot.data!['count'] as int? ?? 0;
                      trailing = Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatPrice(total),
                            style: AppTheme.priceTextStyle,
                          ),
                          Text('$count itens'),
                        ],
                      );
                    }
                    return ListTile(
                      title:
                          Text('Série ${data['series']} - Nº ${data['number']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (date != null)
                            Text(Formatters.formatDateTime(date)),
                          Text(status.displayName),
                        ],
                      ),
                      trailing: trailing,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                InvoiceDetailPage(invoiceId: doc.id),
                          ),
                        );
                      },
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
