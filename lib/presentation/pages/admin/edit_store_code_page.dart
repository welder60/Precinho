import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/logging/firebase_logger.dart';
import '../product/product_search_page.dart';

class EditStoreCodePage extends StatefulWidget {
  final DocumentSnapshot document;
  const EditStoreCodePage({super.key, required this.document});

  @override
  State<EditStoreCodePage> createState() => _EditStoreCodePageState();
}

class _EditStoreCodePageState extends State<EditStoreCodePage> {
  String? _storeName;
  DocumentSnapshot? _productDoc;
  late final String _code;
  late final String _description;

  @override
  void initState() {
    super.initState();
    final data = widget.document.data() as Map<String, dynamic>;
    _code = data['code'] as String? ?? '';
    _description = data['description'] as String? ?? '';
    FirebaseFirestore.instance
        .collection('stores')
        .doc(data['store_id'])
        .get()
        .then((doc) {
      if (mounted) {
        setState(() {
          _storeName = (doc.data() as Map<String, dynamic>?)?['name'];
        });
      }
    });
    FirebaseFirestore.instance
        .collection('products')
        .doc(data['product_id'])
        .get()
        .then((doc) {
      if (mounted) {
        setState(() {
          _productDoc = doc;
        });
      }
    });
  }

  Future<void> _selectProduct() async {
    final doc = await Navigator.push<DocumentSnapshot>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductSearchPage(
          onSelected: (p) => Navigator.pop(context, p),
        ),
      ),
    );
    if (doc != null) {
      setState(() {
        _productDoc = doc;
      });
    }
  }

  Future<void> _submit() async {
    if (_productDoc == null) return;
    try {
      FirebaseLogger.log('Updating store code', {'id': widget.document.id});
      await widget.document.reference.update({'product_id': _productDoc!.id});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código atualizado')),
      );
      Navigator.pop(context);
    } catch (e) {
      FirebaseLogger.log('Edit store code error', {'error': e.toString()});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final productName = _productDoc != null
        ? ((_productDoc!.data() as Map<String, dynamic>)['name'] ?? '')
        : '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Código Próprio'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Comércio: ${_storeName ?? ''}'),
            const SizedBox(height: AppTheme.paddingMedium),
            Text('Código: $_code'),
            const SizedBox(height: AppTheme.paddingMedium),
            Text('Descrição: $_description'),
            const SizedBox(height: AppTheme.paddingLarge),
            ElevatedButton(
              onPressed: _selectProduct,
              child: const Text('Selecionar Produto'),
            ),
            if (productName.isNotEmpty) ...[
              const SizedBox(height: AppTheme.paddingMedium),
              Text('Produto selecionado: $productName'),
            ],
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _productDoc != null ? _submit : null,
                child: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
