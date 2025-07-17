import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import 'add_product_page.dart';
import 'manage_products_page.dart';
import 'manage_users_page.dart';
import 'manage_invoices_page.dart';
import 'manage_stores_page.dart';
import 'import_invoice_page.dart';
import 'manage_store_codes_page.dart';

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
                    builder: (_) => const ManageStoresPage(),
                  ),
                );
              },
              icon: const Icon(Icons.store),
              label: const Text('Gerenciar Com\u00e9rcios'),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageStoreCodesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('Gerenciar C\u00f3digos'),
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
                    builder: (_) => const ManageInvoicesPage(),
                  ),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Notas Fiscais'),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ImportInvoicePage(),
                  ),
                );
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Importar Nota Fiscal'),
            ),
          ],
        ),
      ),
    );
  }
}
