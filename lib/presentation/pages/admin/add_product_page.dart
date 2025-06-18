import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/validators.dart';
import '../../../core/logging/firebase_logger.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _weightController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  ProductCategory? _category;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _weightController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl;
        if (_imageFile != null) {
          final id = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('product_images/$id.jpg');
          FirebaseLogger.log('Uploading product image', {'path': ref.fullPath});
          await ref.putFile(File(_imageFile!.path));
          imageUrl = await ref.getDownloadURL();
          FirebaseLogger.log('Image uploaded', {'url': imageUrl});
        }

        final data = {
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'weight': double.tryParse(_weightController.text.trim()),
          'barcode': _barcodeController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _category?.value,
          'image_url': imageUrl,
          'created_at': Timestamp.now(),
        };

        FirebaseLogger.log('Adding product', data);
        await FirebaseFirestore.instance.collection('products').add(data);
        FirebaseLogger.log('Product added', {'name': data['name']});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto cadastrado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        FirebaseLogger.log('Add product error', {'error': e.toString()});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao cadastrar produto: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
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
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Peso (kg)',
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateWeight,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Código de Barras',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateBarcode,
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
              OutlinedButton(
                onPressed: _pickImage,
                child: const Text('Selecionar Foto'),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                Image.file(
                  File(_imageFile!.path),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ],
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
