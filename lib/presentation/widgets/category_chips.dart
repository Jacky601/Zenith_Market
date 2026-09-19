import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/filter_providers.dart';
import '../../providers/products_provider.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  String _formatCategoryLabel(String category) {
    switch (category.toLowerCase()) {
      case "men's clothing":
        return 'Mode Homme';
      case "women's clothing":
        return 'Mode Femme';
      case 'jewelery':
        return 'Bijoux';
      case 'electronics':
        return 'Électronique';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(availableCategoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final allCategories = [null, ...categories];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (_, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = (category == null && selectedCategory == null) ||
              (category != null && category == selectedCategory);

          final label =
              category == null ? 'Tous' : _formatCategoryLabel(category);

          return FilterChip(
            selected: isSelected,
            label: Text(label),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
            backgroundColor: Colors.white,
            selectedColor: AppTheme.primaryColor,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {
              ref
                  .read(selectedCategoryProvider.notifier)
                  .selectCategory(category);
            },
          );
        },
      ),
    );
  }
}
