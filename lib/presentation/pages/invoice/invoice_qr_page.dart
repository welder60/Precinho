import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  final MobileScannerController _controller = MobileScannerController();
  String? _qrLink;
  bool _isProcessing = false;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code n\u00e3o \u00e9 uma Nota Fiscal')),
        );
      }
      return;
    }
    setState(() {
      _qrLink = value;
      _isProcessing = true;
    });
    await _submit(key);
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
    try {
      await ContributionService().submitInvoice(
        qrLink: _qrLink!,
        accessKey: key,
        cnpj: cnpj,
        userId: user.id,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nota fiscal cadastrada com sucesso')),
        );
        Navigator.pop(context);
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
            const SizedBox(height: AppTheme.paddingLarge),
            if (_isProcessing)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
