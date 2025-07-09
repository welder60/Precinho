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
import '../../data/datasources/cosmos_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _volumeController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String? _imageUrl;
  String? _unit;
  final List<String> _categories = [];
  final TextEditingController _categoryController = TextEditingController();
  final List<DocumentSnapshot> _equivalentProducts = [];
  bool _isFractional = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _volumeController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
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

  Future<void> _updateFromCosmos() async {
    final ean = _barcodeController.text.trim();
    if (ean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o codigo de barras')),
      );
      return;
    }
    try {
      final data = await CosmosService().fetchProduct(ean);
      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto nao encontrado')),
        );
        return;
      }
      final product = data['product'] as Map<String, dynamic>? ?? data;
      setState(() {
        _nameController.text = product['description'] ?? _nameController.text;
        final brand = product['brand'];
        if (brand is Map && brand['name'] != null) {
          _brandController.text = brand['name'];
        } else if (brand is String) {
          _brandController.text = brand;
        }
        final quantity = product['quantity'] as String?;
        if (quantity != null) {
          final parts = quantity.split(' ');
          if (parts.length >= 2) {
            _volumeController.text = parts.first.replaceAll(',', '.');
            _unit = parts[1];
          }
        }
        final picture = product['picture'] ?? data['thumbnail'];
        if (picture is String && picture.isNotEmpty) {
          _imageUrl = picture;
        }
        if (product['description_short'] != null) {
          _descriptionController.text = product['description_short'];
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao consultar Cosmos: $e')),
      );
    }
  }

  Future<void> _updateImageFromCosmos() async {
    final ean = _barcodeController.text.trim();
    if (ean.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o codigo de barras')),
      );
      return;
    }
    try {
      final data = await CosmosService().fetchProduct(ean);
      if (data == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto nao encontrado')),
        );
        return;
      }
      final product = data['product'] as Map<String, dynamic>? ?? data;
      final picture = product['picture'] ?? data['thumbnail'];
      if (picture is String && picture.isNotEmpty) {
        setState(() {
          _imageUrl = picture;
          _imageFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagem nao encontrada')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao consultar Cosmos: $e')),
      );
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
    if (doc != null && !_equivalentProducts.any((p) => p.id == doc.id)) {
      setState(() {
        _equivalentProducts.add(doc);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? imageUrl = _imageUrl;
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

        final equivalentIds = _equivalentProducts.map((e) => e.id).toList();

        final data = {
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'volume': double.tryParse(_volumeController.text.trim()),
          'unit': _unit,
          'barcode': _barcodeController.text.trim(),
          'description': _descriptionController.text.trim(),
          'categories': _categories,
          'image_url': imageUrl,
          'created_at': Timestamp.now(),
          'is_fractional': _isFractional,
          'equivalent_product_ids': equivalentIds,
        };

        FirebaseLogger.log('Adding product', data);
        final ref = FirebaseFirestore.instance.collection('products').doc();
        await ref.set(data);
        for (final doc in _equivalentProducts) {
          await doc.reference.update({
            'equivalent_product_ids': FieldValue.arrayUnion([ref.id])
          });
        }
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
              const SizedBox(height: AppTheme.paddingSmall),
              OutlinedButton(
                onPressed: _updateFromCosmos,
                child: const Text('Atualizar dados'),
              ),
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
              ElevatedButton(
                onPressed: _selectEquivalentProduct,
                child: const Text('Adicionar Produto Equivalente'),
              ),
              Wrap(
                spacing: 8,
                children: _equivalentProducts
                    .map((doc) => InputChip(
                          label: Text(
                              (doc.data() as Map<String, dynamic>)['name'] ?? ''),
                          onDeleted: () {
                            setState(() {
                              _equivalentProducts.remove(doc);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              OutlinedButton(
                onPressed: _pickImage,
                child: const Text('Selecionar Foto'),
              ),
              OutlinedButton(
                onPressed: _updateImageFromCosmos,
                child: const Text('Atualizar Imagem'),
              ),
              if (_imageFile != null) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                Image.file(
                  File(_imageFile!.path),
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ]
              else if (_imageUrl != null && _imageUrl!.isNotEmpty) ...[
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
