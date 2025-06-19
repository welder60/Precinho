import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/constants/app_constants.dart';
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
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  double? _latitude;
  double? _longitude;
  String? _placeId;
  String? _photoReference;
  String? _imageUrl;
  String? _mapImageUrl;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _nameController.text = data['name'] ?? '';
    _addressController.text = data['address'] ?? '';
    _cnpjController.text = data['cnpj'] ?? '';
    _latitude = (data['latitude'] as num?)?.toDouble();
    _longitude = (data['longitude'] as num?)?.toDouble();
    _placeId = data['place_id'] as String?;
    _imageUrl = data['image_url'] as String?;
    _mapImageUrl = data['map_image_url'] as String?;
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
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
        String? imageUrl = _imageUrl;
        if (_imageFile != null) {
          final id = const Uuid().v4();
          final ref = FirebaseStorage.instance
              .ref()
              .child('store_images/$id.jpg');
          FirebaseLogger.log('Uploading store image', {'path': ref.fullPath});
          await ref.putFile(File(_imageFile!.path));
          imageUrl = await ref.getDownloadURL();
          FirebaseLogger.log('Store image uploaded', {'url': imageUrl});
        }
        final mapImageUrl = (_photoReference != null)
            ? _placesService.buildPhotoUrl(_photoReference!)
            : (_latitude != null && _longitude != null)
                ? 'https://maps.googleapis.com/maps/api/staticmap?center=$_latitude,$_longitude&zoom=16&size=600x400&markers=color:red%7C$_latitude,$_longitude&key=${AppConstants.googleMapsApiKey}'
                : _mapImageUrl;

        final data = {
          'name': _nameController.text.trim(),
          'address': _addressController.text.trim(),
          'cnpj': _cnpjController.text.trim(),
          if (_latitude != null && _longitude != null) ...{
            'latitude': _latitude,
            'longitude': _longitude,
            'place_id': _placeId,
          },
          'map_image_url': mapImageUrl,
          'image_url': imageUrl,
          'updated_at': Timestamp.now(),
        };

        FirebaseLogger.log('Updating store', {'id': widget.document.id});
        await widget.document.reference.update(data);
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
        _photoReference = result.photoReference;
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
                readOnly: true,
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
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Image.file(
                    File(_imageFile!.path),
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
              else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                  child: Image.network(
                    _imageUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo),
                label: const Text('Selecionar Foto'),
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
