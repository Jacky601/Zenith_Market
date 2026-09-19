import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/filter_providers.dart';
import '../../providers/products_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import '../widgets/product_card.dart';
import '../widgets/search_and_sort_bar.dart';

class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final width = MediaQuery.of(context).size.width;

    // Calcul responsive du nombre de colonnes (Module 2 Cours 3)
    final crossAxisCount = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Text('Zenith Market'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Rafraîchir les produits',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.invalidate(productsFutureProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SearchAndSortBar(),
          const SizedBox(height: 4),
          const CategoryChips(),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(productsFutureProvider);
                await ref.read(productsFutureProvider.future);
              },
              child: filteredProductsAsync.when(
                loading: () => const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(strokeWidth: 2.5),
                      SizedBox(height: 16),
                      Text(
                        'Chargement des produits...',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                error: (error, stack) => ErrorStateView(
                  errorMessage:
                      'Impossible de charger les produits. Vérifiez votre connexion.',
                  onRetry: () {
                    ref.invalidate(productsFutureProvider);
                  },
                ),
                data: (products) {
                  if (products.isEmpty) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: EmptyStateView(
                          icon: Icons.search_off_rounded,
                          title: 'Aucun produit trouvé',
                          message:
                              'Aucun article ne correspond à votre recherche ou au filtre sélectionné.',
                          actionLabel: 'Réinitialiser les filtres',
                          onAction: () {
                            ref.read(searchQueryProvider.notifier).clear();
                            ref
                                .read(selectedCategoryProvider.notifier)
                                .selectCategory(null);
                          },
                        ),
                      ),
                    );
                  }

                  return GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
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
            ),
          ),
        ],
      ),
    );
  }
}
