import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/cart_provider.dart';

class MainScaffoldScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffoldScreen({
    super.key,
    required this.navigationShell,
  });

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);
    final totalItems = cartState.totalItemCount;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        backgroundColor: Colors.white,
        elevation: 2,
        indicatorColor: AppTheme.accentColor.withValues(alpha: 0.15),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: AppTheme.accentColor),
            label: 'Catalogue',
          ),
          const NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded, color: AppTheme.favoriteColor),
            label: 'Favoris',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalItems > 0,
              label: Text('$totalItems'),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: totalItems > 0,
              label: Text('$totalItems'),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.shopping_bag, color: AppTheme.accentColor),
            ),
            label: 'Panier',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppTheme.accentColor),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
