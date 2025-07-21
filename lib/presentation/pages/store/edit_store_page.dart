import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/logging/firebase_logger.dart';
import 'place_search_page.dart';
import '../../../data/models/place_result.dart';
import '../../../data/datasources/places_service.dart';

class EditStorePage extends StatefulWidget {
  final DocumentSnapshot document;
  const EditStorePage({super.key, required this.document});

  @override
  State<EditStorePage> createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _placesService = PlacesService();
  double? _latitude;
  double? _longitude;
  double? _initialLatitude;
  double? _initialLongitude;
  String? _initialName;
  String? _placeId;
  

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _nameController.text = data['name'] ?? '';
    _initialName = _nameController.text;
    _addressController.text = data['address'] ?? '';
    _cnpjController.text = data['cnpj'] ?? '';
    _latitude = (data['latitude'] as num?)?.toDouble();
    _longitude = (data['longitude'] as num?)?.toDouble();
    _initialLatitude = _latitude;
    _initialLongitude = _longitude;
    _placeId = data['place_id'] as String?;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final data = {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'cnpj': _cnpjController.text.trim(),
          if (_latitude != null && _longitude != null) ...{
            'latitude': _latitude,
            'longitude': _longitude,
            'place_id': _placeId,
          },
          'updated_at': Timestamp.now(),
        };

        FirebaseLogger.log('Updating store', {'id': widget.document.id});
        await widget.document.reference.update(data);

        if ((_latitude != null && _longitude != null) &&
            (_latitude != _initialLatitude || _longitude != _initialLongitude)) {
          final snap = await FirebaseFirestore.instance
              .collection('prices')
              .where('store_id', isEqualTo: widget.document.id)
              .get();
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in snap.docs) {
            batch.update(doc.reference, {
              'latitude': _latitude,
              'longitude': _longitude,
            });
          }
          await batch.commit();
        }
        if (_nameController.text.trim() != (_initialName ?? '')) {
          final snap = await FirebaseFirestore.instance
              .collection('prices')
              .where('store_id', isEqualTo: widget.document.id)
              .get();
          final batch = FirebaseFirestore.instance.batch();
          for (final doc in snap.docs) {
            batch.update(doc.reference, {
              'store_name': _nameController.text.trim(),
            });
          }
          await batch.commit();
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Com\u00e9rcio atualizado')),
        );
        Navigator.pop(context);
      } catch (e) {
        FirebaseLogger.log('Edit store error', {'error': e.toString()});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _selectAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PlaceSearchPage(),
      ),
    );
    if (result is PlaceResult) {
      setState(() {
        _addressController.text = result.address;
        _nameController.text = result.name;
        _latitude = result.latitude;
        _longitude = result.longitude;
        _placeId = result.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Com\u00e9rcio'),
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
                  labelText: 'Nome do Local',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: Validators.validateStoreName,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _addressController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Endereço',
                  prefixIcon: Icon(Icons.location_on),
                  suffixIcon: Icon(Icons.search),
                ),
                onTap: _selectAddress,
                validator: Validators.validateAddress,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
              TextFormField(
                controller: _cnpjController,
                decoration: const InputDecoration(
                  labelText: 'CNPJ',
                  prefixIcon: Icon(Icons.business),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.validateCnpj,
              ),
              const SizedBox(height: AppTheme.paddingMedium),
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
