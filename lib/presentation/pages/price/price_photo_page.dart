import 'dart:io';
import 'dart:typed_data';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import 'price_info_page.dart';

class PricePhotoPage extends ConsumerStatefulWidget {
  const PricePhotoPage({super.key});

  @override
  ConsumerState<PricePhotoPage> createState() => _PricePhotoPageState();
}

class _PricePhotoPageState extends ConsumerState<PricePhotoPage> {
  final _picker = ImagePicker();
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  File? _image;
  Position? _position;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    _cameraController =
        CameraController(backCamera, ResolutionPreset.medium, enableAudio: false);
    await _cameraController!.initialize();
    if (mounted) {
      setState(() => _isCameraInitialized = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aponte a câmera para o preço do produto')),
      );
    }
  }

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
      double _convert(dynamic values) {
        final list = values is List ? values : values.toList();
        final d = list[0].toDouble();
        final m = list[1].toDouble();
        final s = list[2].toDouble();
        return d + m / 60 + s / 3600;
      }
      final lat = _convert(latValues);
      final lon = _convert(lonValues);
      _position = Position(
        latitude: lat,
        longitude: lon,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        isMocked: false,
      );
      setState(() {
        _image = File(picked.path);
      });

      if (mounted && _image != null && _position != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PriceInfoPage(
              image: _image!,
              position: _position!,
            ),
          ),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Permissão de localização negada')));
      }
      return;
    }
    final xFile = await _cameraController!.takePicture();
    _position = await Geolocator.getCurrentPosition();
    _image = File(xFile.path);

    if (mounted && _image != null && _position != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PriceInfoPage(
            image: _image!,
            position: _position!,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto de Preço'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isCameraInitialized
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Center(
                  child: Container(
                    width: 250,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 160,
                  left: 0,
                  right: 0,
                  child: const Text(
                    'Aponte a câmera para o preço do produto',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        heroTag: 'take_photo',
                        onPressed: _takePhoto,
                        child: const Icon(Icons.camera_alt),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        heroTag: 'pick_gallery',
                        onPressed: () => _pickImage(ImageSource.gallery),
                        child: const Icon(Icons.photo),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
