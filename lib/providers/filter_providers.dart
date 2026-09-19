import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sort_option.dart';

/// Notifier pour le mot-clé de recherche
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider =
    StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

/// Notifier pour la catégorie sélectionnée (null = 'Tous')
class SelectedCategoryNotifier extends StateNotifier<String?> {
  SelectedCategoryNotifier() : super(null);

  void selectCategory(String? category) {
    state = category;
  }
}

final selectedCategoryProvider =
    StateNotifierProvider<SelectedCategoryNotifier, String?>((ref) {
  return SelectedCategoryNotifier();
});

/// Notifier pour l'ordre de tri
class SortByNotifier extends StateNotifier<SortOption> {
  SortByNotifier() : super(SortOption.featured);

  void setSort(SortOption option) {
    state = option;
  }
}

final sortByProvider =
    StateNotifierProvider<SortByNotifier, SortOption>((ref) {
  return SortByNotifier();
});
