import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/firebase_logger.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../../data/datasources/invoice_service.dart';
import 'invoice_qr_page.dart';
import '../home/home_page.dart';
import 'invoices_page.dart';

class InvoiceQrConfirmPage extends ConsumerStatefulWidget {
  final String qrLink;
  const InvoiceQrConfirmPage({required this.qrLink, super.key});

  @override
  ConsumerState<InvoiceQrConfirmPage> createState() => _InvoiceQrConfirmPageState();
}

class _InvoiceQrConfirmPageState extends ConsumerState<InvoiceQrConfirmPage> {
  String? _accessKey;
  bool _isValid = false;
  bool _alreadySent = false;
  bool _loading = true;
  String? _message;

  @override
  void initState() {
    super.initState();
    _validateQr();
  }

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

  Future<void> _validateQr() async {
    final key = _extractAccessKey(widget.qrLink);
    if (key == null) {
      setState(() {
        _loading = false;
        _isValid = false;
        _message = 'QR Code n\u00e3o \u00e9 de uma Nota Fiscal v\u00e1lida';
      });
      return;
    }
    _accessKey = key;
    final exists = await InvoiceService().invoiceExists(key);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (exists) {
        _alreadySent = true;
        _isValid = false;
        _message = 'Nota fiscal j\u00e1 enviada anteriormente';
      } else {
        _isValid = true;
        _message = 'Nota fiscal pronta para envio';
      }
    });
  }

  Future<void> _submit() async {
    if (!_isValid || _accessKey == null) return;
    setState(() => _loading = true);
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final key = _accessKey!;
    final cnpj = key.substring(6, 20);
    final series = key.substring(22, 25);
    final number = key.substring(25, 34);
    try {
      await InvoiceService().submitInvoice(
        qrLink: widget.qrLink,
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const InvoicesPage()),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      FirebaseLogger.log('submitInvoice_error', {'error': e.toString()});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Nota Fiscal')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Icon(
                    _isValid ? Icons.receipt_long : Icons.error,
                    size: 96,
                    color: _isValid ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  Text(
                    _message ?? '',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.paddingLarge),
                  if (_isValid) ...[
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Enviar Nota Fiscal'),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                  ],
                  OutlinedButton(
                    onPressed: () {
                      if (_isValid) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const InvoiceQrPage()),
                        );
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => route.isFirst,
                        );
                      }
                    },
                    child: const Text('Ler novo QR Code'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_isValid) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                          (route) => route.isFirst,
                        );
                      }
                    },
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),
    );
  }
}
