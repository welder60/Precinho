import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';

class InvoiceDetailPage extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailPage({required this.invoiceId, super.key});

  Stream<DocumentSnapshot> _invoiceStream() {
    return FirebaseFirestore.instance
        .collection('invoices')
        .doc(invoiceId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Fiscal')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _invoiceStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Nota fiscal n\u00e3o encontrada'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final date = (data['created_at'] as Timestamp?)?.toDate();
          final status = ModerationStatus.values.firstWhere(
            (s) => s.value == data['status'],
            orElse: () => ModerationStatus.underReview,
          );
          final products = (data['products'] as List?)?.cast<String>() ?? [];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Link: ${data['qr_link'] ?? ''}'),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('CNPJ: ${data['cnpj']}'),
                Text('S\u00e9rie: ${data['series']}'),
                Text('N\u00famero: ${data['number']}'),
                if (date != null)
                  Text('Enviada em: ${Formatters.formatDateTime(date)}'),
                const SizedBox(height: AppTheme.paddingMedium),
                Text('Status: ${status.displayName}'),
                if (status == ModerationStatus.approved && products.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text(
                    'Produtos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppTheme.paddingSmall),
                  for (final p in products)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppTheme.paddingSmall),
                      child: Text(p),
                    ),
                ]
              ],
            ),
          );
        },
      ),
    );
  }
}
