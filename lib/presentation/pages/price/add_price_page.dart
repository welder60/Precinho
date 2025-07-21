import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/price_input_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../../data/services/price_service.dart';
import '../product/product_search_page.dart';
import '../store/store_search_page.dart';

class AddPricePage extends StatefulWidget {
  final DocumentSnapshot? store;
  final DocumentSnapshot? product;

  const AddPricePage({this.store, this.product, super.key});

  @override
  State<AddPricePage> createState() => _AddPricePageState();
}

class _AddPricePageState extends State<AddPricePage> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _storeController = TextEditingController();
  final _priceController = TextEditingController();
  DocumentSnapshot? _selectedProduct;
  DocumentSnapshot? _selectedStore;
  final List<Map<String, dynamic>> _nearbyStores = [];

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      _selectedStore = widget.store;
      final data = widget.store!.data() as Map<String, dynamic>;
      _storeController.text = data['name'] ?? '';
    }
    if (widget.product != null) {
      _selectedProduct = widget.product;
      final data = widget.product!.data() as Map<String, dynamic>;
      _productController.text = data['name'] ?? '';
    }
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
          nearby.add({'doc': doc, 'distance': distance});
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
          final doc = _nearbyStores.first['doc'] as DocumentSnapshot;
          _selectedStore = doc;
          _storeController.text =
              (doc.data() as Map<String, dynamic>)['name'] ?? '';
        }
      });
    } catch (e) {
      FirebaseLogger.log('Nearby store error', {'error': e.toString()});
    }
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

        final productData = _selectedProduct!.data() as Map<String, dynamic>;
        final storeData = _selectedStore!.data() as Map<String, dynamic>;

        double? variation;
        try {
          final snap = await FirebaseFirestore.instance
              .collection('prices')
              .where('product_id', isEqualTo: _selectedProduct!.id)
              .where('store_id', isEqualTo: _selectedStore!.id)
              .orderBy('created_at', descending: true)
              .limit(5)
              .get();
          for (final doc in snap.docs) {
            final prev = (doc.data()['price'] as num?)?.toDouble();
            if (prev != null && prev != priceValue) {
              variation = (((priceValue ?? 0.0) - (prev ?? 0.0)) / (prev ?? 1.0)) * 100;
              break;
            }
          }
        } catch (e) {
          FirebaseLogger.log('Variation calc error', {'error': e.toString()});
        }

        double? nearbyAvg;
        String? avgComparison;
        try {
          final baseLat = (storeData['latitude'] as num?)?.toDouble() ??
              position?.latitude;
          final baseLng = (storeData['longitude'] as num?)?.toDouble() ??
              position?.longitude;
          if (baseLat != null && baseLng != null) {
            final snap = await FirebaseFirestore.instance
                .collection('prices')
                .where('product_id', isEqualTo: _selectedProduct!.id)
                .orderBy('created_at', descending: true)
                .limit(50)
                .get();

            const radiusInMeters = 1000.0;
            var sum = 0.0;
            var count = 0;
            for (final doc in snap.docs) {
              final pData = doc.data();
              final lat = (pData['latitude'] as num?)?.toDouble();
              final lng = (pData['longitude'] as num?)?.toDouble();
              if (lat == null || lng == null) continue;
              final dist = Geolocator.distanceBetween(baseLat, baseLng, lat, lng);
              if (dist <= radiusInMeters) {
                final p = (pData['price'] as num?)?.toDouble();
                if (p != null) {
                  sum += p;
                  count++;
                }
              }
            }
            if (count > 0) {
              nearbyAvg = sum / count;
              if (priceValue != null) {
                final diff = ((priceValue ?? 0.0) - nearbyAvg) / nearbyAvg;
                if (diff >= 0.1) {
                  avgComparison = 'above_10';
                } else if (diff <= -0.1) {
                  avgComparison = 'below_10';
                }
              }
            }
          }
        } catch (e) {
          FirebaseLogger.log('Nearby average error', {'error': e.toString()});
        }

        final priceService = PriceService();
        await priceService.createPrice(
          productId: _selectedProduct!.id,
          productName: productData['name'],
          storeId: _selectedStore!.id,
          storeName: storeData['name'],
          userId: FirebaseAuth.instance.currentUser?.uid,
          value: priceValue ?? 0.0,
          imageUrl: null,
          latitude: storeData['latitude'] != null
              ? (storeData['latitude'] as num).toDouble()
              : position?.latitude,
          longitude: storeData['longitude'] != null
              ? (storeData['longitude'] as num).toDouble()
              : position?.longitude,
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(
            const Duration(days: AppConstants.defaultPriceValidityDays),
          ),
          extra: {
            if (variation != null) 'variation': variation,
            if (avgComparison != null) 'avg_comparison': avgComparison,
          },
        );
        SystemSound.play(SystemSoundType.alert);
        FirebaseLogger.log('Price added', {
          'product_id': _selectedProduct!.id,
        });
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
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Produto',
                  prefixIcon: Icon(Icons.shopping_basket),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectProduct,
                validator: (_) =>
                    _selectedProduct == null ? 'Selecione o produto' : null,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _storeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Com\u00e9rcio',
                  prefixIcon: Icon(Icons.store),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectStore,
                validator: (_) =>
                    _selectedStore == null ? 'Selecione o com\u00e9rcio' : null,
              ),
              if (_nearbyStores.isNotEmpty) ...[
                const SizedBox(height: AppTheme.paddingSmall),
                Wrap(
                  spacing: AppTheme.paddingSmall,
                  children: _nearbyStores
                      .map(
                        (store) {
                          final doc = store['doc'] as DocumentSnapshot;
                          final name =
                              (doc.data() as Map<String, dynamic>)['name'] ?? '';
                          return ActionChip(
                            label: Text(name),
                            onPressed: () {
                              setState(() {
                                _selectedStore = doc;
                                _storeController.text = name;
                              });
                            },
                          );
                        },
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [PriceInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Preço',
                  prefixText: 'R\$ ',
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
