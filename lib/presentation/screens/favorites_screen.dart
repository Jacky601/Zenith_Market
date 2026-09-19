import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/favorites_provider.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteProductsProvider);
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: favoritesAsync.maybeWhen(
          data: (list) => Text('Mes Favoris (${list.length})'),
          orElse: () => const Text('Mes Favoris'),
        ),
      ),
      body: favoritesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => ErrorStateView(
          errorMessage: 'Impossible de charger vos favoris.',
          onRetry: () => ref.invalidate(favoritesNotifierProvider),
        ),
        data: (favorites) {
          if (favorites.isEmpty) {
            return EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'Aucun favori pour le moment',
              message:
                  'Enregistrez vos articles préférés en appuyant sur l’icône cœur pour les retrouver facilement.',
              actionLabel: 'Découvrir nos produits',
              onAction: () => context.go('/catalog'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              return ProductCard(
                product: product,
                onTap: () {
                  context.push('/catalog/product/${product.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
