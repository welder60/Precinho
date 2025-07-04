import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/parsers/invoice_html_parser.dart';
import '../../../data/parsers/invoice_xml_parser.dart';

class ImportInvoicePage extends StatefulWidget {
  const ImportInvoicePage({super.key});

  @override
  State<ImportInvoicePage> createState() => _ImportInvoicePageState();
}

class _ImportInvoicePageState extends State<ImportInvoicePage> {
  PlatformFile? _selectedFile;
  String? _message;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html', 'htm', 'xml'],
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
    if (kIsWeb) {
      final bytes = _selectedFile!.bytes;
      if (bytes == null) return;
      content = utf8.decode(bytes);
    } else {
      final file = File(_selectedFile!.path!);
      content = await file.readAsString();
    }

    if (_selectedFile!.extension?.toLowerCase() == 'xml') {
      final msg = InvoiceXmlParser.parse(content);
      setState(() => _message = msg);
    } else {
      final msg = InvoiceHtmlParser.parse(content);
      setState(() => _message = msg);
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
