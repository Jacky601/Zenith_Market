import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/favorites_storage.dart';
import '../data/models/product.dart';
import 'products_provider.dart';

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  return FavoritesStorage();
});

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesStorage _storage;

  FavoritesNotifier(this._storage) : super({}) {
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final saved = await _storage.loadFavorites();
    state = saved;
  }

  Future<void> toggleFavorite(String productId) async {
    final updatedSet = Set<String>.from(state);

    if (updatedSet.contains(productId)) {
      updatedSet.remove(productId);
    } else {
      updatedSet.add(productId);
    }

    state = updatedSet;
    await _storage.saveFavorites(updatedSet);
  }

  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final storage = ref.watch(favoritesStorageProvider);
  return FavoritesNotifier(storage);
});

/// Provider dérivé retournant les objets Product complets correspondant aux IDs favoris
final favoriteProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsFutureProvider);
  final favoriteIds = ref.watch(favoritesNotifierProvider);

  return productsAsync.whenData((products) {
    return products.where((product) => favoriteIds.contains(product.id)).toList();
  });
});
