import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../product/product_search_page.dart';
import '../shopping_list/shopping_lists_page.dart';
import '../profile/profile_page.dart';
import '../store/store_search_page.dart';
import '../feed/feed_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FeedPage(),
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
                      icon: Icon(Icons.home),
                      label: Text('Início'),
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
                  icon: Icon(Icons.home),
                  label: 'Início',
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
    );
  }
}
