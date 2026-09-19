import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/sort_option.dart';
import '../../providers/filter_providers.dart';

class SearchAndSortBar extends ConsumerStatefulWidget {
  const SearchAndSortBar({super.key});

  @override
  ConsumerState<SearchAndSortBar> createState() => _SearchAndSortBarState();
}

class _SearchAndSortBarState extends ConsumerState<SearchAndSortBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSort = ref.watch(sortByProvider);
    final hasSearchText = ref.watch(searchQueryProvider).isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Champ de recherche
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
                suffixIcon: hasSearchText
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).setQuery(value);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Menu de tri
          PopupMenuButton<SortOption>(
            initialValue: currentSort,
            tooltip: 'Trier par',
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: AppTheme.textPrimary,
                size: 20,
              ),
            ),
            onSelected: (option) {
              ref.read(sortByProvider.notifier).setSort(option);
            },
            itemBuilder: (context) => SortOption.values.map((option) {
              final isSelected = option == currentSort;
              return PopupMenuItem<SortOption>(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: isSelected ? AppTheme.accentColor : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      option.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.accentColor : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
