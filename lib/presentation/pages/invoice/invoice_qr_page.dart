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
  final MobileScannerController _controller = MobileScannerController();
  File? _image;
  String? _qrLink;

  void _onDetect(BarcodeCapture capture) {
    if (_qrLink != null) return;
    if (capture.barcodes.isNotEmpty) {
      final value = capture.barcodes.first.rawValue;
      if (value != null) {
        setState(() {
          _qrLink = value;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: AppConstants.imageQuality);
    if (picked == null) return;
    _image = File(picked.path);
    setState(() {});
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
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            ),
            if (_qrLink != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
                child: Text(_qrLink!),
              ),
            if (_image != null)
              Image.file(_image!, height: 200),
            const SizedBox(height: AppTheme.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto'),
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
              onPressed: _qrLink != null && _image != null ? _submit : null,
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }
}
