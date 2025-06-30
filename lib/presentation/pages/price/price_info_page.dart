import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/enums.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/price_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../product/product_search_page.dart';
import '../store/store_search_page.dart';
import 'user_prices_page.dart';

class PriceInfoPage extends ConsumerStatefulWidget {
  final File image;
  final Position position;

  const PriceInfoPage({
    required this.image,
    required this.position,
    super.key,
  });

  @override
  ConsumerState<PriceInfoPage> createState() => _PriceInfoPageState();
}

class _PriceInfoPageState extends ConsumerState<PriceInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();

  DocumentSnapshot? _selectedProduct;
  DocumentSnapshot? _selectedStore;

  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectProduct() async {
    final doc = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          onSelected: (product) => Navigator.pop(context, product),
        ),
      ),
    );
    if (doc != null) {
      setState(() {
        _selectedProduct = doc;
        _productController.text =
            (doc.data() as Map<String, dynamic>)['name'] ?? '';
      });
    }
  }

  Future<void> _selectStore() async {
    final doc = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => StoreSearchPage(
          onSelected: (store) => Navigator.pop(context, store),
        ),
      ),
    );
    if (doc != null) {
      setState(() {
        _selectedStore = doc;
        _storeController.text =
            (doc.data() as Map<String, dynamic>)['name'] ?? '';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      final path = 'price_photos/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final refStorage = FirebaseStorage.instance.ref().child(path);
      await refStorage.putFile(widget.image);
      final imageUrl = await refStorage.getDownloadURL();

      final priceValue = Formatters.parsePrice(_priceController.text.trim());
      final data = {
        'user_id': user.id,
        'image_url': imageUrl,
        'created_at': Timestamp.now(),
        'isApproved': false,
        'status': ModerationStatus.pending.value,
        'latitude': widget.position.latitude,
        'longitude': widget.position.longitude,
        if (priceValue != null) 'price': priceValue,
        if (_selectedProduct != null) ...{
          'product_id': _selectedProduct!.id,
          'product_name':
              (_selectedProduct!.data() as Map<String, dynamic>)['name'],
        },
        if (_selectedStore != null) ...{
          'store_id': _selectedStore!.id,
          'store_name':
              (_selectedStore!.data() as Map<String, dynamic>)['name'],
        },
      };

      await FirebaseFirestore.instance.collection('prices').add(data);
      SystemSound.play(SystemSoundType.alert);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const UserPricesPage()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Preço')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Image.file(widget.image, height: 200),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _productController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  prefixIcon: Icon(Icons.shopping_basket),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectProduct,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _storeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Comércio',
                  prefixIcon: Icon(Icons.store),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectStore,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [PriceInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
                ),
                validator: (_) {
                  final text = _priceController.text.trim();
                  if (text.isEmpty) return null;
                  return Validators.validatePrice(text);
                },
              ),
              const SizedBox(height: AppTheme.paddingLarge),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Enviar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
