import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../providers/auth_provider.dart';
import '../../../data/datasources/contribution_service.dart';

class InvoiceQrPage extends ConsumerStatefulWidget {
  const InvoiceQrPage({super.key});

  @override
  ConsumerState<InvoiceQrPage> createState() => _InvoiceQrPageState();
}

class _InvoiceQrPageState extends ConsumerState<InvoiceQrPage> {
  final _picker = ImagePicker();
  File? _image;
  String? _qrLink;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: AppConstants.imageQuality);
    if (picked == null) return;
    if (source == ImageSource.camera) {
      _image = File(picked.path);
      await _scanQr(File(picked.path));
    } else {
      _image = File(picked.path);
      await _scanQr(File(picked.path));
    }
    setState(() {});
  }

  Future<void> _scanQr(File file) async {
    final scanner = MobileScannerController();
    try {
      final bool success = await scanner.analyzeImage(file.path);
      if (success) {
        final capture = await scanner.barcodes.first;
        if (capture.barcodes.isNotEmpty) {
          _qrLink = capture.barcodes.first.rawValue;
        }
      }
    } catch (e) {
      FirebaseLogger.log('qr_scan_error', {'error': e.toString()});
    } finally {
      scanner.dispose();
    }
  }

  Future<void> _submit() async {
    final user = ref.read(currentUserProvider);
    if (_image == null || _qrLink == null || user == null) return;
    try {
      await ContributionService().submitInvoice(
        image: _image!,
        qrLink: _qrLink!,
        userId: user.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enviado para análise')));
        Navigator.pop(context);
      }
    } catch (e) {
      FirebaseLogger.log('submitInvoice_error', {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Code NF')),
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
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Escanear'),
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
              onPressed: _image != null && _qrLink != null ? _submit : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
