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
import '../product/product_search_page.dart';

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
  late final TextEditingController _volumeController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _unit;
  final List<String> _categories = [];
  final TextEditingController _categoryController = TextEditingController();
  String? _imageUrl;
  final TextEditingController _equivalentProductController = TextEditingController();
  DocumentSnapshot? _equivalentProduct;
  bool _isFractional = false;
  String? _equivalenceGroupId;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _nameController = TextEditingController(text: data['name'] ?? '');
    _brandController = TextEditingController(text: data['brand'] ?? '');
    _volumeController =
        TextEditingController(text: data['volume']?.toString() ?? '');
    _barcodeController = TextEditingController(text: data['barcode'] ?? '');
    _descriptionController =
        TextEditingController(text: data['description'] ?? '');
    if (data['unit'] != null) {
      _unit = data['unit'] as String?;
    }
    if (data['categories'] != null) {
      _categories.addAll(List<String>.from(data['categories'] as List));
    }
    _imageUrl = data['image_url'] as String?;
    _isFractional = data['is_fractional'] as bool? ?? false;
    _equivalenceGroupId = data['equivalence_group_id'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _volumeController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _equivalentProductController.dispose();
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

  void _addCategory() {
    final text = _categoryController.text.trim();
    if (text.isNotEmpty && !_categories.contains(text)) {
      setState(() {
        _categories.add(text);
      });
      _categoryController.clear();
    }
  }

  Future<void> _selectEquivalentProduct() async {
    final doc = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          onSelected: (p) => Navigator.pop(context, p),
        ),
      ),
    );
    if (doc != null) {
      setState(() {
        _equivalentProduct = doc;
        _equivalentProductController.text =
            (doc.data() as Map<String, dynamic>)['name'] ?? '';
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

        String? equivalenceGroupId = _equivalenceGroupId;
        if (_equivalentProduct != null) {
          final dataOther = _equivalentProduct!.data() as Map<String, dynamic>;
          final otherGroup = dataOther['equivalence_group_id'] as String?;
          equivalenceGroupId ??= otherGroup;
          if (equivalenceGroupId == null) {
            equivalenceGroupId = const Uuid().v4();
          }
          if (otherGroup != equivalenceGroupId) {
            await _equivalentProduct!.reference
                .update({'equivalence_group_id': equivalenceGroupId});
          }
        }

        final data = {
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'volume': double.tryParse(_volumeController.text.trim()),
          'unit': _unit,
          'barcode': _barcodeController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categories': _categories,
          'image_url': imageUrl,
          'updated_at': Timestamp.now(),
          'is_fractional': _isFractional,
          if (equivalenceGroupId != null)
            'equivalence_group_id': equivalenceGroupId,
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
                controller: _volumeController,
                decoration: const InputDecoration(
                  labelText: 'Volume',
                  prefixIcon: Icon(Icons.scale),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validateVolume,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              DropdownButtonFormField<String>(
                value: _unit,
                decoration: const InputDecoration(labelText: 'Unidade de Medida'),
                items: const [
                  DropdownMenuItem(value: 'kg', child: Text('kg')),
                  DropdownMenuItem(value: 'g', child: Text('g')),
                  DropdownMenuItem(value: 'l', child: Text('l')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'un', child: Text('unidade')),
                ],
                onChanged: (value) {
                  setState(() {
                    _unit = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione a unidade' : null,
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
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(
                  labelText: 'Adicionar Categoria',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addCategory,
                  ),
                ),
                onFieldSubmitted: (_) => _addCategory(),
              ),
              Wrap(
                spacing: 8,
                children: _categories
                    .map((c) => InputChip(
                          label: Text(c),
                          onDeleted: () {
                            setState(() {
                              _categories.remove(c);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _equivalentProductController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Produto equivalente',
                  prefixIcon: Icon(Icons.link),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectEquivalentProduct,
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
              SwitchListTile(
                title: const Text('Produto fracionado'),
                value: _isFractional,
                onChanged: (v) => setState(() => _isFractional = v),
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
