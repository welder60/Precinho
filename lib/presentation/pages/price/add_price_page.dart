import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/logging/firebase_logger.dart';

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
  final List<Map<String, dynamic>> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    _loadNearbyStores();
  }

  Future<void> _loadNearbyStores() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final snapshot =
          await FirebaseFirestore.instance.collection('stores').get();

      const radiusInMeters = 1000.0; // 1km
      final nearby = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final lat = (data['latitude'] as num?)?.toDouble();
        final lng = (data['longitude'] as num?)?.toDouble();
        if (lat == null || lng == null) continue;

        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );

        if (distance <= radiusInMeters) {
          nearby.add({'name': data['name'] ?? '', 'distance': distance});
        }
      }

      nearby.sort((a, b) => (a['distance'] as double)
          .compareTo(b['distance'] as double));

      if (!mounted) return;

      setState(() {
        _nearbyStores
          ..clear()
          ..addAll(nearby);
        if (_nearbyStores.length == 1) {
          _storeController.text = _nearbyStores.first['name'] as String;
        }
      });
    } catch (e) {
      FirebaseLogger.log('Nearby store error', {'error': e.toString()});
    }
  }

  @override
  void dispose() {
    _productController.dispose();
    _storeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final priceValue = Formatters.parsePrice(_priceController.text.trim());

      try {
        Position? position;
        try {
          final permission = await Geolocator.requestPermission();
          if (permission != LocationPermission.denied &&
              permission != LocationPermission.deniedForever) {
            position = await Geolocator.getCurrentPosition();
          }
        } catch (e) {
          FirebaseLogger.log('Location error', {'error': e.toString()});
        }

        final data = {
          'product': _productController.text.trim(),
          'store': _storeController.text.trim(),
          'price': priceValue,
          'created_at': Timestamp.now(),
          if (position != null) ...{
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
        };
        FirebaseLogger.log('Adding price', data);
        await FirebaseFirestore.instance.collection('prices').add(data);
        FirebaseLogger.log('Price added', {'product': data['product']});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Preço salvo')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        FirebaseLogger.log('Add price error', {'error': e.toString()});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar preço: ${e.toString()}'),
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
              if (_nearbyStores.isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingSmall),
                Wrap(
                  spacing: AppTheme.paddingSmall,
                  children: _nearbyStores
                      .map(
                        (store) => ActionChip(
                          label: Text(store['name'] as String),
                          onPressed: () {
                            setState(() {
                              _storeController.text = store['name'] as String;
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
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
