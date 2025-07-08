import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../invoice/invoice_detail_page.dart';
import 'import_invoice_page.dart';

class ManageInvoicesPage extends StatefulWidget {
  const ManageInvoicesPage({super.key});

  @override
  State<ManageInvoicesPage> createState() => _ManageInvoicesPageState();
}

class _ManageInvoicesPageState extends State<ManageInvoicesPage> {
  bool _pendingOnly = false;

  Stream<QuerySnapshot> get _invoiceStream {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('invoices')
        .orderBy('created_at', descending: true);
    if (_pendingOnly) {
      query =
          query.where('status', isEqualTo: ModerationStatus.underReview.value);
    }
    return query.snapshots();
  }

  Future<void> _openLink(String? urlStr) async {
    if (urlStr == null || urlStr.isEmpty) return;
    final url = Uri.parse(urlStr);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas Fiscais'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Mostrar apenas pendentes'),
            value: _pendingOnly,
            onChanged: (v) => setState(() => _pendingOnly = v),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _invoiceStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar notas'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('Nenhuma nota fiscal encontrada'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final date = (data['created_at'] as Timestamp?)?.toDate();
                    final status = ModerationStatus.values.firstWhere(
                      (s) => s.value == data['status'],
                      orElse: () => ModerationStatus.underReview,
                    );
                    return Card(
                      child: ListTile(
                        title: Text('Série ${data['series']} - Nº ${data['number']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (date != null)
                              Text(Formatters.formatDateTime(date)),
                            Text(status.displayName),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.link),
                          onPressed: () => _openLink(data['qr_link'] as String?),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoiceDetailPage(invoiceId: doc.id),
                            ),
                          );
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
      floatingActionButton: FloatingActionButton(
        heroTag: 'manage_invoices_import_fab',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ImportInvoicePage()),
          );
        },
        child: const Icon(Icons.file_upload),
      ),
    );
  }
}

