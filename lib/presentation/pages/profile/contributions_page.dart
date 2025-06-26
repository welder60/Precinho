import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';

class ContributionsPage extends ConsumerWidget {
  const ContributionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Contribuições')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('contributions')
            .where('user_id', isEqualTo: user.id)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhuma contribuição encontrada'));
          }
          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['created_at'] as Timestamp?)?.toDate();
              final type = data['type'] as String? ?? '';
              return Card(
                child: ListTile(
                  title: Text(type),
                  subtitle: Text(
                    date != null ? Formatters.formatDateTime(date) : '',
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
