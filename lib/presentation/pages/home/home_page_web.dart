import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../providers/auth_provider.dart';

class HomePageWeb extends ConsumerStatefulWidget {
  const HomePageWeb({super.key});

  @override
  ConsumerState<HomePageWeb> createState() => _HomePageWebState();
}

class _HomePageWebState extends ConsumerState<HomePageWeb> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MapPageWeb(),
    const SearchPageWeb(),
    const ShoppingListsPageWeb(),
    const ProfilePageWeb(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Row(
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
            backgroundColor: AppTheme.surfaceColor,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Mapa'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.search),
                label: Text('Buscar'),
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
      ),
    );
  }
}

// Página do Mapa (Demonstração)
class MapPageWeb extends StatelessWidget {
  const MapPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Preços'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Mapa de Preços',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Aqui seria exibido um mapa interativo\ncom os preços próximos à sua localização',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Busca (Demonstração)
class SearchPageWeb extends StatelessWidget {
  const SearchPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Preços'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          children: [
            // Barra de busca
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar produtos...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            
            // Lista de produtos de demonstração
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
                    child: ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: const Icon(
                          Icons.shopping_basket,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      title: Text('Produto ${index + 1}'),
                      subtitle: const Text('Supermercado ABC • 500m'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R\$ ${(10.99 + index).toStringAsFixed(2)}',
                            style: AppTheme.priceTextStyle,
                          ),
                          const Text(
                            'há 2h',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Página de Listas (Demonstração)
class ShoppingListsPageWeb extends StatelessWidget {
  const ShoppingListsPageWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Listas'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lista de Compras ${index + 1}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.paddingSmall,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: const Text(
                            'Ativa',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      'Criada em ${DateTime.now().subtract(Duration(days: index)).day}/${DateTime.now().month}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    LinearProgressIndicator(
                      value: (index + 1) / 5,
                      backgroundColor: AppTheme.backgroundColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Row(
                      children: [
                        Text(
                          '${index + 2}/5 itens',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Spacer(),
                        Text(
                          'R\$ ${(50.0 + index * 10).toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Página de Perfil (Demonstração)
class ProfilePageWeb extends ConsumerWidget {
  const ProfilePageWeb({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          children: [
            // Cabeçalho do perfil
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        user != null && user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Text(
                      user?.name ?? 'Usuário',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppTheme.paddingSmall),
                    Text(
                      user?.email ?? 'email@exemplo.com',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),

            // Estatísticas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estatísticas',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(context, 'Preços', '42', Icons.local_offer),
                        ),
                        Expanded(
                          child: _buildStatItem(context, 'Lojas', '15', Icons.store),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(context, 'Listas', '8', Icons.list),
                        ),
                        Expanded(
                          child: _buildStatItem(context, 'Pontos', '1.250', Icons.stars),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      margin: const EdgeInsets.all(AppTheme.paddingSmall),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

