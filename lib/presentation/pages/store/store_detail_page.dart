import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/store_favorites_provider.dart';
import 'edit_store_page.dart';
// Página de detalhes exibe apenas informações do comércio.

class StoreDetailPage extends ConsumerWidget {
  final DocumentSnapshot store;
  const StoreDetailPage({required this.store, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = store.data() as Map<String, dynamic>;
    final isFav = ref.watch(storeFavoritesProvider).contains(store.id);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(data['name'] ?? 'Comércio'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: isFav ? Colors.amber : AppTheme.textOnPrimaryColor,
            ),
            onPressed: () {
              ref.read(storeFavoritesProvider.notifier).toggleFavorite(store.id);
            },
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStorePage(document: store),
                  ),
                );
              },
            ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteStore(context),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data['latitude'] != null && data['longitude'] != null)
            Image.network(
              'https://maps.googleapis.com/maps/api/staticmap?center=${data['latitude']},${data['longitude']}&zoom=16&size=600x200&markers=color:red%7C${data['latitude']},${data['longitude']}&key=${AppConstants.googleMapsApiKey}',
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.paddingMedium),
            child: Text(data['address'] ?? ''),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
            child: Text(
              'Mais informações serão disponibilizadas em futuras versões.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: const Text('Abrir no Maps'),
                onPressed: () {
                  _openMaps(
                    context,
                    data['latitude'],
                    data['longitude'],
                    data['address'],
                    data['place_id'],
                  );
                },
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              ElevatedButton.icon(
                icon: const Icon(Icons.directions_car),
                label: const Text('Abrir no Waze'),
                onPressed: () {
                  _openWaze(
                    context,
                    data['latitude'],
                    data['longitude'],
                    data['address'],
                    data['place_id'],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      // Sem ações nesta tela
    );
  }

  Future<void> _deleteStore(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Comércio'),
        content: const Text('Tem certeza que deseja excluir este comércio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await store.reference.delete();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Com\u00e9rcio exclu\u00eddo')),
        );
      }
    }
  }

  Future<void> _openMaps(
    BuildContext context,
    Object? lat,
    Object? lng,
    Object? address,
    Object? placeId,
  ) async {
    Uri? url;
    if (placeId is String && placeId.isNotEmpty) {
      url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query_place_id=${Uri.encodeComponent(placeId)}');
    } else if (lat is num && lng is num) {
      url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${lat.toDouble()},${lng.toDouble()}');
    } else if (address is String && address.isNotEmpty) {
      url = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    }
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWaze(
    BuildContext context,
    Object? lat,
    Object? lng,
    Object? address,
    Object? placeId,
  ) async {
    Uri? url;
    if (placeId is String && placeId.isNotEmpty) {
      url = Uri.parse(
          'https://waze.com/ul?place=${Uri.encodeComponent(placeId)}&navigate=yes');
    } else if (lat is num && lng is num) {
      url = Uri.parse(
          'https://waze.com/ul?ll=${lat.toDouble()},${lng.toDouble()}&navigate=yes');
    } else if (address is String && address.isNotEmpty) {
      url = Uri.parse(
          'https://waze.com/ul?query=${Uri.encodeComponent(address)}&navigate=yes');
    }
    if (url != null && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
