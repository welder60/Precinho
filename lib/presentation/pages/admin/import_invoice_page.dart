import 'dart:io';

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
  File? _selectedFile;
  String? _message;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['html', 'htm', 'xml'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _message = null;
      });
    }
  }

  Future<void> _import() async {
    if (_selectedFile == null) return;
    final content = await _selectedFile!.readAsString();
    if (_selectedFile!.path.toLowerCase().endsWith('.xml')) {
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
              Text(_selectedFile!.path),
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
