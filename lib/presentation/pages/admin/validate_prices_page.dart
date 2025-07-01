import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';

class ValidatePricesPage extends StatefulWidget {
  const ValidatePricesPage({super.key});

  @override
  State<ValidatePricesPage> createState() => _ValidatePricesPageState();
}

class _ValidatePricesPageState extends State<ValidatePricesPage> {

  Stream<QuerySnapshot> get _pendingPricesStream => FirebaseFirestore.instance
      .collection('prices')
      .where('status', isEqualTo: ModerationStatus.pending.value)
      .orderBy('created_at')
      .snapshots();

  Future<void> _updateStatus(
    DocumentReference doc,
    bool approve,
  ) async {
    try {
      await doc.update({
        'status': approve
            ? ModerationStatus.approved.value
            : ModerationStatus.rejected.value,
        'updated_at': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Preço aprovado' : 'Preço rejeitado',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Preços'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _pendingPricesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar preços'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum preço para validar'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final imageUrl = data['image_url'] as String?;
              return Card(
                margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
                child: ListTile(
                  leading: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.local_offer,
                          color: AppTheme.primaryColor,
                        ),
                  title: Text(data['product_name'] ?? 'Produto'),
                  subtitle: Text(data['store_name'] ?? 'Comércio'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _updateStatus(doc.reference, true),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _updateStatus(doc.reference, false),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
