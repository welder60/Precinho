import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/logging/firebase_logger.dart';
import '../../providers/auth_provider.dart';
import '../map/map_page.dart';
import '../product/product_search_page.dart';
import '../shopping_list/shopping_lists_page.dart';
import '../profile/profile_page.dart';
import '../price/add_price_page.dart';
import '../store/store_search_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapPage(),
    const StoreSearchPage(),
    const ProductSearchPage(),
    const ShoppingListsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: kIsWeb 
          ? Row(
              children: [
                // Sidebar para web
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.map),
                      label: Text('Mapa'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.store),
                      label: Text('Lojas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.search),
                      label: Text('Produtos'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.shopping_cart),
                      label: Text('Listas'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Perfil'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                // Conteúdo principal
                Expanded(
                  child: _pages[_currentIndex],
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: kIsWeb 
          ? null 
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.textSecondaryColor,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Mapa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.store),
                  label: 'Lojas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Produtos',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Listas',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Perfil',
                ),
              ],
            ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                _showAddPriceDialog(context);
              },
              backgroundColor: AppTheme.secondaryColor,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _showAddPriceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) => const AddPriceBottomSheet(),
    );
  }
}

class AddPriceBottomSheet extends StatelessWidget {
  const AddPriceBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.paddingLarge,
        right: AppTheme.paddingLarge,
        top: AppTheme.paddingLarge,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.paddingLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle do modal
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // Título
          Text(
            'Adicionar Preço',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppTheme.paddingLarge),

          // Opções
          if (!kIsWeb) ...[
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Fotografar Preço'),
              subtitle: const Text('Tire uma foto do preço no estabelecimento'),
              onTap: () async {
                Navigator.pop(context);
                await _takePricePhoto(context);
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
            title: const Text('Inserir Manualmente'),
            subtitle: const Text('Digite o preço manualmente'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddPricePage(),
                ),
              );
            },
          ),
          if (!kIsWeb) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt, color: AppTheme.primaryColor),
              title: const Text('Escanear Nota Fiscal'),
              subtitle: const Text('Extrair preços de uma nota fiscal'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Funcionalidade em desenvolvimento')),
                );
              },
            ),
          ],
          ],
      ),
    );
  }

  Future<void> _takePricePhoto(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;

    Position? position;
    try {
      final permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.denied &&
          permission != LocationPermission.deniedForever) {
        position = await Geolocator.getCurrentPosition();
      }
    } catch (e) {
      FirebaseLogger.log('Location error', {'error': e.toString()});
    }

    final coords = position != null
        ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
        : 'localização indisponível';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Foto capturada ($coords)')),
    );
  }
}

