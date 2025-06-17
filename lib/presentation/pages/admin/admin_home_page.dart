import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'add_product_page.dart';
import 'manage_products_page.dart';
import 'manage_users_page.dart';
import 'validate_prices_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddProductPage(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Produto'),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageProductsPage(),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('Gerenciar Produtos'),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageUsersPage(),
                  ),
                );
              },
              icon: const Icon(Icons.people),
              label: const Text('Gerenciar Usuários'),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ValidatePricesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Validar Preços'),
            ),
          ],
        ),
      ),
    );
  }
}
