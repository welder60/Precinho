import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../../../core/logging/firebase_logger.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  Future<void> _toggleActive(
    BuildContext context,
    DocumentReference doc,
    bool isActive,
  ) async {
    try {
      final newValue = !isActive;
      FirebaseLogger.log('Updating user active', {
        'path': doc.path,
        'is_active': newValue,
      });
      await doc.update({'is_active': newValue});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue ? 'Usuário desbloqueado' : 'Usuário bloqueado',
          ),
        ),
      );
    } catch (e) {
      FirebaseLogger.log('Toggle active error', {'error': e.toString()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar usuário: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _toggleAdmin(
    BuildContext context,
    DocumentReference doc,
    String role,
  ) async {
    try {
      final newRole =
          role == UserRole.admin.value ? UserRole.user.value : UserRole.admin.value;
      FirebaseLogger.log('Updating user role', {
        'path': doc.path,
        'role': newRole,
      });
      await doc.update({'role': newRole});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newRole == UserRole.admin.value
                ? 'Usuário agora é administrador'
                : 'Usuário não é mais administrador',
          ),
        ),
      );
    } catch (e) {
      FirebaseLogger.log('Toggle role error', {'error': e.toString()});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar usuário: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Usuários'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar usuários'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum usuário encontrado'));
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final isActive = data['is_active'] as bool? ?? true;
              final role = data['role'] as String? ?? UserRole.user.value;
              return ListTile(
                leading: const Icon(Icons.person, color: AppTheme.primaryColor),
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['email'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        isActive ? Icons.block : Icons.check_circle,
                        color: isActive
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                      onPressed: () =>
                          _toggleActive(context, doc.reference, isActive),
                    ),
                    IconButton(
                      icon: Icon(
                        role == UserRole.admin.value
                            ? Icons.admin_panel_settings
                            : Icons.admin_panel_settings_outlined,
                        color: role == UserRole.admin.value
                            ? AppTheme.warningColor
                            : AppTheme.primaryColor,
                      ),
                      onPressed: () =>
                          _toggleAdmin(context, doc.reference, role),
                    ),
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

