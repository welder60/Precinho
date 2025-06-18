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

class EditProductPage extends StatefulWidget {
  final DocumentSnapshot document;
  const EditProductPage({super.key, required this.document});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _weightController;
  late final TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  ProductCategory? _category;
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
    _brandController = TextEditingController(text: data['brand'] ?? '');
    _weightController =
        TextEditingController(text: data['weight']?.toString() ?? '');
    _descriptionController =
        TextEditingController(text: data['description'] ?? '');
    _category = ProductCategory.values.firstWhere(
      (c) => c.value == data['category'],
      orElse: () => ProductCategory.other,
    );
    _imageUrl = data['image_url'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _weightController.dispose();
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
        String? imageUrl = _imageUrl;
        if (_imageFile != null) {
          final id = const Uuid().v4();
          final ref = FirebaseStorage.instance.ref().child('product_images/$id.jpg');
          FirebaseLogger.log('Uploading product image', {'path': ref.fullPath});
          await ref.putFile(File(_imageFile!.path));
          imageUrl = await ref.getDownloadURL();
          FirebaseLogger.log('Image uploaded', {'url': imageUrl});
        }

        final data = {
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'weight': double.tryParse(_weightController.text.trim()),
          'description': _descriptionController.text.trim(),
          'category': _category?.value,
          'image_url': imageUrl,
          'updated_at': Timestamp.now(),
        };

        FirebaseLogger.log('Updating product', {'id': widget.document.id});
        await widget.document.reference.update(data);
        FirebaseLogger.log('Product updated', {'id': widget.document.id});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produto atualizado')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        FirebaseLogger.log('Edit product error', {'error': e.toString()});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar produto: ${e.toString()}'),
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
        title: const Text('Editar Produto'),
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
              if (_imageFile != null)
                ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Image.file(
                    File(_imageFile!.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ]
              else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Image.network(
                    _imageUrl!,
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
