import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../admin/admin_home_page.dart';
import 'submissions_page.dart';
import '../price/user_prices_page.dart';
import '../invoice/invoices_page.dart';

Future<Map<String, int>> _fetchUserStats(String userId) async {
  final priceAgg = await FirebaseFirestore.instance
      .collection('prices')
      .where('user_id', isEqualTo: userId)
      .count()
      .get();
  final invoiceAgg = await FirebaseFirestore.instance
      .collection('invoices')
      .where('user_id', isEqualTo: userId)
      .count()
      .get();

  final priceCount = priceAgg.count ?? 0;
  final invoiceCount = invoiceAgg.count ?? 0;

  return {
    'prices': priceCount,
    'invoices': invoiceCount,
  };
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navegar para configurações
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                children: [
                  // Cabeçalho do perfil
                  _buildProfileHeader(context, user),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Estatísticas
                  _buildStatsSection(context, user),
                  const SizedBox(height: AppTheme.paddingLarge),

                  // Menu de opções
                  _buildMenuSection(context, ref),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryColor,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            // Nome
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingSmall),

            // Email
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.paddingMedium),

            // Pontos
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingMedium,
                vertical: AppTheme.paddingSmall,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  Text(
                    Formatters.formatPoints(user.points),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, user) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchUserStats(user.id),
      builder: (context, snapshot) {
        final priceCount = snapshot.data?['prices'];
        final invoiceCount = snapshot.data?['invoices'];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estatísticas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppTheme.paddingMedium),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Preços Cadastrados',
                        priceCount != null ? '$priceCount' : '...',
                        Icons.local_offer,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserPricesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Notas Fiscais Enviadas',
                        invoiceCount != null ? '$invoiceCount' : '...',
                        Icons.receipt,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const InvoicesPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      margin: const EdgeInsets.all(AppTheme.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, child: content);
    }
    return content;
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Meus envios
        _buildMenuItem(
          context,
          'Meus Envios',
          'Preços e notas fiscais enviados',
          Icons.history,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SubmissionsPage(),
              ),
            );
          },
        ),

        // Painel administrativo (apenas para admins)
        if (ref.watch(isAdminProvider))
          _buildMenuItem(
            context,
            'Painel Administrativo',
            'Gerencie produtos e preços',
            Icons.admin_panel_settings,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminHomePage(),
                ),
              );
            },
          ),

        // Configurações
        _buildMenuItem(
          context,
          'Configurações',
          'Preferências e privacidade',
          Icons.settings,
          () {
            // TODO: Navegar para configurações
          },
        ),

        // Ajuda
        _buildMenuItem(
          context,
          'Ajuda e Suporte',
          'FAQ e contato',
          Icons.help,
          () {
            // TODO: Navegar para ajuda
          },
        ),

        // Sobre
        _buildMenuItem(
          context,
          'Sobre o App',
          'Versão e informações',
          Icons.info,
          () {
            // TODO: Mostrar sobre
          },
        ),

        const SizedBox(height: AppTheme.paddingMedium),

        // Botão de logout
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showLogoutDialog(context, ref);
            },
            icon: const Icon(Icons.logout, color: AppTheme.errorColor),
            label: const Text(
              'Sair',
              style: TextStyle(color: AppTheme.errorColor),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.errorColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppTheme.primaryColor,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

