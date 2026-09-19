class Formatters {
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(2)} €';
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
