import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/favorites_storage.dart';
import '../data/models/product.dart';
import 'products_provider.dart';

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage();
});

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  FutureOr<Set<String>> build() async {
    final storage = ref.watch(favoritesStorageProvider);
    return storage.loadFavorites();
  }

  Future<void> toggleFavorite(String productId) async {
    final currentSet = state.value ?? {};
    final updatedSet = Set<String>.from(currentSet);

    if (updatedSet.contains(productId)) {
      updatedSet.remove(productId);
    } else {
      updatedSet.add(productId);
    }

    state = AsyncData(updatedSet);

    final storage = ref.read(favoritesStorageProvider);
    await storage.saveFavorites(updatedSet);
  }

  bool isFavorite(String productId) {
    return state.value?.contains(productId) ?? false;
  }
}

final favoritesNotifierProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);

/// Provider dérivé retournant les objets Product complets correspondant aux IDs favoris
final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsFutureProvider);
  final favoriteIdsAsync = ref.watch(favoritesNotifierProvider);

  if (productsAsync.isLoading || favoriteIdsAsync.isLoading) {
    return const AsyncLoading();
  }

  if (productsAsync.hasError) {
    return AsyncError(productsAsync.error!, productsAsync.stackTrace!);
  }

  if (favoriteIdsAsync.hasError) {
    return AsyncError(favoriteIdsAsync.error!, favoriteIdsAsync.stackTrace!);
  }

  final products = productsAsync.value ?? [];
  final favoriteIds = favoriteIdsAsync.value ?? {};

  final favProducts =
      products.where((product) => favoriteIds.contains(product.id)).toList();

  return AsyncData(favProducts);
});
