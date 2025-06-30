import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../../core/constants/enums.dart';

class SubmissionsPage extends ConsumerStatefulWidget {
  const SubmissionsPage({super.key});

  @override
  ConsumerState<SubmissionsPage> createState() => _SubmissionsPageState();
}

class _SubmissionsPageState extends ConsumerState<SubmissionsPage> {
  ModerationStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    Query query = FirebaseFirestore.instance
        .collection('submissions')
        .where('user_id', isEqualTo: user.id);
    if (_filter != null) {
      query = query.where('status', isEqualTo: _filter!.value);
    }
    query = query.orderBy('created_at', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Envios')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todos'),
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Aprovados'),
                    selected: _filter == ModerationStatus.approved,
                    onSelected: (_) =>
                        setState(() => _filter = ModerationStatus.approved),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Pendente'),
                    selected: _filter == ModerationStatus.pending,
                    onSelected: (_) =>
                        setState(() => _filter = ModerationStatus.pending),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Recusados'),
                    selected: _filter == ModerationStatus.rejected,
                    onSelected: (_) =>
                        setState(() => _filter = ModerationStatus.rejected),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhum envio encontrado'));
                }
                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data['created_at'] as Timestamp?)?.toDate();
                    final type = data['type'] as String? ?? '';
                    final status = data['status'] as String? ?? '';
                    final imageUrl = data['image_url'] as String?;
                    final statusLabel = ModerationStatus.values.firstWhere(
                      (e) => e.value == status,
                      orElse: () => ModerationStatus.pending,
                    ).displayName;
                    return Card(
                      child: ListTile(
                        leading: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                                child: Image.network(
                                  imageUrl,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.photo),
                        title: Text(type),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (date != null)
                              Text(Formatters.formatDateTime(date)),
                            Text(statusLabel),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
