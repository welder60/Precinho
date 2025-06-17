import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class ValidatePricesPage extends StatelessWidget {
  const ValidatePricesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validar Preços'),
      ),
      body: ListView.builder(
        itemCount: 5,
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
            child: ListTile(
              leading: const Icon(
                Icons.local_offer,
                color: AppTheme.primaryColor,
              ),
              title: Text('Preço ${index + 1}'),
              subtitle: const Text('Aguardando validação'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Preço aprovado (apenas interface)'),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Preço rejeitado (apenas interface)'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
