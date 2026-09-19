enum SortOption {
  featured('En vedette'),
  priceAsc('Prix : croissant'),
  priceDesc('Prix : décroissant'),
  ratingDesc('Meilleures notes');

  final String label;
  const SortOption(this.label);
}
