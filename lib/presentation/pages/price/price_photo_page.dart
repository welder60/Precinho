import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../providers/auth_provider.dart';
import '../../../data/datasources/contribution_service.dart';

class PricePhotoPage extends ConsumerStatefulWidget {
  const PricePhotoPage({super.key});

  @override
  ConsumerState<PricePhotoPage> createState() => _PricePhotoPageState();
}

class _PricePhotoPageState extends ConsumerState<PricePhotoPage> {
  final _picker = ImagePicker();
  File? _image;
  Position? _position;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: AppConstants.imageQuality);
    if (picked == null) return;

    if (source == ImageSource.gallery) {
      final bytes = await picked.readAsBytes();
      final tags = await readExifFromBytes(bytes);
      if (!tags.containsKey('GPS GPSLatitude') || !tags.containsKey('GPS GPSLongitude')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagem sem geolocalização')));
        }
        return;
      }
      final latValues = tags['GPS GPSLatitude']!.values;
      final lonValues = tags['GPS GPSLongitude']!.values;
      double _convert(List values) {
        final d = values[0].toDouble();
        final m = values[1].toDouble();
        final s = values[2].toDouble();
        return d + m / 60 + s / 3600;
      }
      final lat = _convert(latValues);
      final lon = _convert(lonValues);
      _position = Position(latitude: lat, longitude: lon, timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0);
    } else {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada')));
        }
        return;
      }
      _position = await Geolocator.getCurrentPosition();
    }

    setState(() {
      _image = File(picked.path);
    });
  }

  bool _validateImage(File file) {
    final bytes = file.readAsBytesSync();
    final image = img.decodeImage(bytes);
    if (image == null) return false;
    int sum = 0;
    for (final p in image.getBytes()) {
      sum += p;
    }
    final avg = sum / image.length;
    return avg > 20; // evita imagem muito escura
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (_image == null || _position == null || user == null) return;
    if (!_validateImage(_image!)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Imagem de baixa qualidade')));
      }
      return;
    }
    try {
      await ContributionService().submitPricePhoto(
        image: _image!,
        position: _position!,
        userId: user.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviado para análise')));
        Navigator.pop(context);
      }
    } catch (e) {
      FirebaseLogger.log('submitPricePhoto_error', {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto de Preço'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          children: [
            if (_image != null)
              Image.file(_image!, height: 200),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Câmera'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: const Text('Galeria'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton(
              onPressed: _image != null && _position != null ? _submit : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
