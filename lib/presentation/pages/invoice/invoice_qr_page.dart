import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../providers/auth_provider.dart';
import '../../../data/datasources/invoice_service.dart';
import 'invoices_page.dart';

class InvoiceQrPage extends ConsumerStatefulWidget {
  const InvoiceQrPage({super.key});

  @override
  ConsumerState<InvoiceQrPage> createState() => _InvoiceQrPageState();
}

class _InvoiceQrPageState extends ConsumerState<InvoiceQrPage> {
  final MobileScannerController _controller = MobileScannerController();
  String? _qrLink;
  String? _accessKey;
  bool _flashOn = false;
  bool _isProcessing = false;
  String? _message;

  String? _extractAccessKey(String data) {
    final match = RegExp(r'(\d{44})').firstMatch(data);
    if (match == null) return null;
    final key = match.group(0)!;
    if (_validateAccessKey(key)) return key;
    return null;
  }

  bool _validateAccessKey(String key) {
    if (key.length != 44) return false;
    final digits = key.split('').map(int.parse).toList();
    var weight = 2;
    var sum = 0;
    for (var i = digits.length - 2; i >= 0; i--) {
      sum += digits[i] * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    final mod = sum % 11;
    final dv = mod == 0 || mod == 1 ? 0 : 11 - mod;
    return dv == digits.last;
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null) return;
    final key = _extractAccessKey(value);
    if (key == null) {
      setState(() {
        _message = 'QR Code n\u00e3o \u00e9 de uma Nota Fiscal V\u00e1lida';
      });
      return;
    }
    setState(() {
      _qrLink = value;
      _accessKey = key;
      _message = 'QR Code lido com sucesso';
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit(String key) async {
    final user = ref.read(currentUserProvider);
    if (_qrLink == null || user == null) return;
    final cnpj = key.substring(6, 20);
    final series = key.substring(22, 25);
    final number = key.substring(25, 34);
    try {
      await InvoiceService().submitInvoice(
        qrLink: _qrLink!,
        accessKey: key,
        cnpj: cnpj,
        series: series,
        number: number,
        userId: user.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota fiscal cadastrada com sucesso')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const InvoicesPage()),
        );
      }
    } catch (e) {
      FirebaseLogger.log('submitInvoice_error', {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Nota Fiscal'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _flashOn = !_flashOn);
            },
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Text(
              _message ?? 'Aponte para o QR Code da nota fiscal',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          if (_qrLink != null)
            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _qrLink!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_isProcessing)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _qrLink != null && _accessKey != null
                        ? () => _submit(_accessKey!)
                        : null,
                    child: const Text('Enviar Nota Fiscal'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
