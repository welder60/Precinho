import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/validators.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descriptionController = TextEditingController();
  ProductCategory? _category;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance.collection('products').add({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category?.value,
        'created_at': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto cadastrado')), 
        );
        Navigator.pop(context); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Produto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: Validators.validateProductName,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              DropdownButtonFormField<ProductCategory>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: ProductCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  alignLabelWithHint: true,
                ),
                validator: Validators.validateDescription,
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
