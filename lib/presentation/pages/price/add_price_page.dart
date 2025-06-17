import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';

class AddPricePage extends StatefulWidget {
  const AddPricePage({super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preço salvo (apenas interface)')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Preço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _productController,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  prefixIcon: Icon(Icons.shopping_basket),
                ),
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _storeController,
                decoration: const InputDecoration(
                  labelText: 'Estabelecimento',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: Validators.validateStoreName,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: Validators.validatePrice,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Salvar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
