import 'dart:io' show File;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../../../core/themes/app_theme.dart';
import '../../../data/parsers/invoice_html_parser.dart';
import '../../../data/exceptions/missing_store_location_exception.dart';
import '../store/edit_store_page.dart';
import '../../../data/parsers/invoice_xml_parser.dart';

class ImportInvoicePage extends StatefulWidget {
  const ImportInvoicePage({super.key});

  @override
  State<ImportInvoicePage> createState() => _ImportInvoicePageState();
}

class _ImportInvoicePageState extends State<ImportInvoicePage> {
  PlatformFile? _selectedFile;
  String? _message;
  final TextEditingController _linkController = TextEditingController();

  Future<String?> _processImport(String html, {String qrLink = ''}) async {
    while (true) {
      try {
        final msg = await InvoiceHtmlParser.importInvoice(
          html,
          userId: 'system',
          qrLink: qrLink,
        );
        return msg;
      } on MissingStoreLocationException catch (e) {
        final doc = await e.storeRef.get();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditStorePage(document: doc),
          ),
        );
        // After the user edits the store, retry the import
      } catch (e) {
        return 'Erro: $e';
      }
    }
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      // Permit both lower and upper case extensions
      allowedExtensions: ['html', 'HTML', 'htm', 'HTM', 'xml'],
      withData: true,
    );
    if (result != null) {
      setState(() {
        _selectedFile = result.files.single;
        _message = null;
      });
    }
  }

  Future<void> _import() async {
    if (_selectedFile == null) return;
    String content;
    final bytes = _selectedFile!.bytes;
    if (bytes != null) {
      content = utf8.decode(bytes);
    } else {
      final file = File(_selectedFile!.path!);
      content = await file.readAsString();
    }

    if (_selectedFile!.extension?.toLowerCase() == 'xml') {
      final msg = InvoiceXmlParser.parse(content);
      setState(() => _message = msg);
    } else {
      final msg = await _processImport(content) ?? 'Importação cancelada';
      setState(() => _message = msg);
    }
  }

  @override
  void dispose() {
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _importFromLink() async {
    final link = _linkController.text.trim();
    if (link.isEmpty) return;
    setState(() => _message = null);
    try {
      final response = await http.get(
        Uri.parse(link),
        headers: const {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        },
      );
      if (response.statusCode == 200) {
        final msg =
            await _processImport(response.body, qrLink: link) ?? 'Importação cancelada';
        if (mounted) setState(() => _message = msg);
      } else {
        if (mounted) {
          setState(() =>
              _message = 'Erro ao baixar HTML (${response.statusCode})');
        }
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Erro: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Importar Nota Fiscal')),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Link da Nota Fiscal',
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            ElevatedButton(
              onPressed: _importFromLink,
              child: const Text('Baixar e Importar'),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Selecionar Arquivo'),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text(_selectedFile!.name),
            ],
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton(
              onPressed: _selectedFile != null ? _import : null,
              child: const Text('Importar'),
            ),
            if (_message != null) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text(_message!),
            ]
          ],
        ),
      ),
    );
  }
}
