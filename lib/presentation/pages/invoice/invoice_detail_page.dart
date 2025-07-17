import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';

class InvoiceDetailPage extends ConsumerWidget {
  final String invoiceId;
  const InvoiceDetailPage({required this.invoiceId, super.key});

  Stream<DocumentSnapshot> _invoiceStream() {
    return FirebaseFirestore.instance
        .collection('invoices')
        .doc(invoiceId)
        .snapshots();
  }

  Stream<QuerySnapshot> _pricesStream() {
    return FirebaseFirestore.instance
        .collection('prices')
        .where('invoice_id', isEqualTo: invoiceId)
        .orderBy('created_at')
        .snapshots();
  }

  Future<void> _openLink(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _revertInvoice(BuildContext context) async {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    try {
      final prices = await firestore
          .collection('prices')
          .where('invoice_id', isEqualTo: invoiceId)
          .get();

      for (final doc in prices.docs) {
        final data = doc.data();
        final productId = data['product_id'] as String?;
        final storeId = data['store_id'] as String?;
        if (productId != null && storeId != null) {
          final prevSnap = await firestore
              .collection('prices')
              .where('product_id', isEqualTo: productId)
              .where('store_id', isEqualTo: storeId)
              .orderBy('created_at', descending: true)
              .limit(2)
              .get();
          for (final prev in prevSnap.docs) {
            if (prev.id != doc.id) {
              batch.update(prev.reference, {'is_active': true});
              break;
            }
          }
        }
        batch.delete(doc.reference);
      }

      batch.update(
        firestore.collection('invoices').doc(invoiceId),
        {'status': ModerationStatus.underReview.value},
      );
      await batch.commit();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota fiscal revertida')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao reverter nota fiscal: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _confirmRevert(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reverter Nota Fiscal'),
        content: const Text(
            'Excluir os pre\u00e7os importados e reativar os anteriores?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reverter'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _revertInvoice(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota Fiscal')),
      floatingActionButton: ref.watch(isAdminProvider)
          ? FloatingActionButton(
              heroTag: 'invoice_revert_fab',
              onPressed: () => _confirmRevert(context),
              child: const Icon(Icons.undo),
            )
          : null,
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
          return StreamBuilder<QuerySnapshot>(
            stream: _pricesStream(),
            builder: (context, priceSnapshot) {
              final priceDocs = priceSnapshot.data?.docs ?? [];
              double total = 0;
              for (final doc in priceDocs) {
                final data = doc.data() as Map<String, dynamic>;
                final price = (data['price'] as num?)?.toDouble() ?? 0.0;
                final discount = (data['discount'] as num?)?.toDouble() ?? 0.0;
                total += price - discount;
              }
              final itemCount = priceDocs.length;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(builder: (context) {
                      final link = data['qr_link'] as String?;
                      if (link == null || link.isEmpty) {
                        return const Text('Link: -');
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _openLink(link),
                              child: Text(
                                'Link: $link',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: link));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Link copiado')),
                              );
                            },
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text('CNPJ: ${data['cnpj']}'),
                    Text('S\u00e9rie: ${data['series']}'),
                    Text('N\u00famero: ${data['number']}'),
                    if (date != null)
                      Text('Enviada em: ${Formatters.formatDateTime(date)}'),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text('Status: ${status.displayName}'),
                    if (status == ModerationStatus.approved &&
                        priceDocs.isNotEmpty) ...[
                      const SizedBox(height: AppTheme.paddingMedium),
                      Text('Total: ${Formatters.formatPrice(total)}'),
                      Text('Itens: $itemCount'),
                      const SizedBox(height: AppTheme.paddingLarge),
                      Text(
                        'Produtos',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppTheme.paddingSmall),
                      for (final doc in priceDocs)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.paddingSmall),
                          child: _PriceRow(
                              data: doc.data() as Map<String, dynamic>),
                        ),
                    ]
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PriceRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final name = data['product_name'] as String? ?? '';
    final value = (data['price'] as num?)?.toDouble() ?? 0.0;
    final discount = (data['discount'] as num?)?.toDouble() ?? 0.0;
    final paid = value - discount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(name)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Formatters.formatPrice(paid),
              style: AppTheme.priceTextStyle,
            ),
            if (discount > 0)
              Text(
                'Desconto: ${Formatters.formatPrice(discount)}',
                style: AppTheme.discountTextStyle,
              ),
          ],
        ),
      ],
    );
  }
}
