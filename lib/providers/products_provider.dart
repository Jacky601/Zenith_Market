import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/product.dart';
import '../data/models/sort_option.dart';
import '../data/repositories/product_repository.dart';
import 'filter_providers.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository();
});

/// FutureProvider chargeant la liste des produits
final productsFutureProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.fetchProducts();
});

/// Provider extrayant les catégories disponibles à partir des produits
final availableCategoriesProvider = Provider<List<String>>((ref) {
  final productsAsync = ref.watch(productsFutureProvider);
  return productsAsync.maybeWhen(
    data: (products) {
      final categories = products.map((p) => p.category).toSet().toList();
      categories.sort();
      return categories;
    },
    orElse: () => [],
  );
});

/// Provider combinant les données asynchrones avec les filtres et le tri
final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsFutureProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final sortBy = ref.watch(sortByProvider);

  return productsAsync.whenData((products) {
    var list = products;

    // 1. Filtrage par catégorie
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      list = list.where((p) => p.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
    }

    // 2. Filtrage par mot-clé
    if (searchQuery.isNotEmpty) {
      list = list.where((p) {
        final titleMatch = p.title.toLowerCase().contains(searchQuery);
        final descMatch = p.description.toLowerCase().contains(searchQuery);
        return titleMatch || descMatch;
      }).toList();
    }

    // 3. Tri
    final sorted = List<Product>.from(list);
    switch (sortBy) {
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.featured:
        // Garder l'ordre initial
        break;
    }

    return sorted;
  });
});

/// Provider family pour récupérer un produit par son identifiant
final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final productsAsync = ref.watch(productsFutureProvider);
  return productsAsync.maybeWhen(
    data: (products) {
      try {
        return products.firstWhere((p) => p.id == id);
      } catch (_) {
        return null;
      }
    },
    orElse: () => null,
  );
});
