import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../../core/constants/app_constants.dart';
import 'place_search_page.dart';
import '../../../data/models/place_result.dart';

class AddStorePage extends StatefulWidget {
  const AddStorePage({super.key});

  @override
  State<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends State<AddStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _placeId;
  Uint8List? _mapImageBytes;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String? mapImageUrl;
      if (_mapImageBytes != null) {
        final id = const Uuid().v4();
        final ref = FirebaseStorage.instance.ref().child('store_maps/$id.png');
        FirebaseLogger.log('Uploading map image', {'path': ref.fullPath});
        await ref.putData(_mapImageBytes!);
        mapImageUrl = await ref.getDownloadURL();
      }

      final data = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        if (_latitude != null && _longitude != null) ...{
          'latitude': _latitude,
          'longitude': _longitude,
          'place_id': _placeId,
        },
        if (mapImageUrl != null) 'map_image_url': mapImageUrl,
        'created_at': Timestamp.now(),
      };
      try {
        FirebaseLogger.log('Adding store', data);
        await FirebaseFirestore.instance.collection('stores').add(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estabelecimento cadastrado')),
        );
        Navigator.pop(context);
      } catch (e) {
        FirebaseLogger.log('Add store error', {'error': e.toString()});
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar: $e'),
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
        _latitude = result.latitude;
        _longitude = result.longitude;
        _placeId = result.id;
      });
      await _loadMapImage(result.latitude, result.longitude);
    }
  }

  Future<void> _loadMapImage(double lat, double lng) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/staticmap', {
      'center': '$lat,$lng',
      'zoom': '16',
      'size': '600x300',
      'markers': 'color:red|$lat,$lng',
      'key': AppConstants.googleMapsApiKey,
    });
    try {
      final res = await http.get(uri);
      if (res.statusCode == 200) {
        setState(() {
          _mapImageBytes = res.bodyBytes;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Estabelecimento'),
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
              if (_mapImageBytes != null) ...[
                const SizedBox(height: AppTheme.paddingMedium),
                Image.memory(
                  _mapImageBytes!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ],
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
