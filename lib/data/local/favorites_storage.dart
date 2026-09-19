import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  static const String _favoritesKey = 'zenith_market_favorites_v1';

  Future<Set<String>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_favoritesKey);
      if (list == null) return {};
      return list.toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> saveFavorites(Set<String> favoriteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favoriteIds.toList());
    } catch (_) {
      // Ignorer ou logger l'erreur silencieusement
    }
  }
}
