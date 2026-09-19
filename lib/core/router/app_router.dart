import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/catalog_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/cart_screen.dart';
import '../../presentation/screens/profile_screen.dart';
import '../../presentation/screens/product_detail_screen.dart';
import '../../presentation/screens/main_scaffold_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _catalogNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'catalogNav');
final _favoritesNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'favoritesNav');
final _cartNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'cartNav');
final _profileNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'profileNav');

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/catalog',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branche 1 : Catalogue + Détail produit
          StatefulShellBranch(
            navigatorKey: _catalogNavigatorKey,
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => const CatalogScreen(),
                routes: [
                  GoRoute(
                    path: 'product/:id',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final id = state.pathParameters['id'] ?? '';
                      return ProductDetailScreen(productId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branche 2 : Favoris
          StatefulShellBranch(
            navigatorKey: _favoritesNavigatorKey,
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),

          // Branche 3 : Panier
          StatefulShellBranch(
            navigatorKey: _cartNavigatorKey,
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Branche 4 : Profil
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
