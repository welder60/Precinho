import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';
import 'invoice_qr_confirm_page.dart';

class InvoiceManualKeyPage extends ConsumerStatefulWidget {
  const InvoiceManualKeyPage({super.key});

  @override
  ConsumerState<InvoiceManualKeyPage> createState() => _InvoiceManualKeyPageState();
}

class _InvoiceManualKeyPageState extends ConsumerState<InvoiceManualKeyPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _keyController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    return Validators.validateInvoiceAccessKey(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final key = _keyController.text.replaceAll(RegExp(r'\D'), '');
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InvoiceQrConfirmPage(qrLink: key),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chave de Acesso')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _keyController,
                keyboardType: TextInputType.number,
                maxLength: 44,
                decoration: const InputDecoration(
                  labelText: 'Chave de Acesso',
                ),
                validator: _validate,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
