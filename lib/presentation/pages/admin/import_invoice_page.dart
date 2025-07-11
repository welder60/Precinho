
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../../../core/themes/app_theme.dart';
import '../../../data/parsers/invoice_html_parser.dart';
import '../../../data/parsers/invoice_xml_parser.dart';

class ImportInvoicePage extends StatefulWidget {
  const ImportInvoicePage({super.key});

  @override
  State<ImportInvoicePage> createState() => _ImportInvoicePageState();
}

class _ImportInvoicePageState extends State<ImportInvoicePage> {
  XFile? _selectedFile;
  String? _message;

  Future<void> _pickFile() async {
    final typeGroup = XTypeGroup(
      label: 'invoice',
      extensions: ['html', 'htm', 'xml'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file != null) {
      setState(() {
        _selectedFile = file;
        _message = null;
      });
    }
  }

  Future<void> _import() async {
    if (_selectedFile == null) return;
    final content = await _selectedFile!.readAsString();

    final extension = _selectedFile!.name.split('.').last.toLowerCase();
    if (extension == 'xml') {
      final msg = InvoiceXmlParser.parse(content);
      setState(() => _message = msg);
    } else {
      final msg = await InvoiceHtmlParser.importInvoice(
        content,
        userId: 'system',
      );
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
