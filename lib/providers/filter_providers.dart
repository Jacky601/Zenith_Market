import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/sort_option.dart';

/// Notifier et Provider pour le mot-clé de recherche
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

/// Notifier et Provider pour la catégorie sélectionnée (null = 'Tous')
class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selectCategory(String? category) {
    state = category;
  }
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(
        SelectedCategoryNotifier.new);

/// Notifier et Provider pour l'ordre de tri
class SortByNotifier extends Notifier<SortOption> {
  @override
  SortOption build() => SortOption.featured;

  void setSort(SortOption option) {
    state = option;
  }
}

final sortByProvider =
    NotifierProvider<SortByNotifier, SortOption>(SortByNotifier.new);
