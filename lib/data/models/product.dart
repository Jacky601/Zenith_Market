class Product {
  final String id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String imageUrl;
  final double rating;
  final int ratingCount;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.imageUrl,
    this.rating = 0.0,
    this.ratingCount = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final ratingMap = json['rating'] is Map<String, dynamic>
        ? json['rating'] as Map<String, dynamic>
        : null;

    final rawRating = ratingMap != null ? ratingMap['rate'] : json['rating'];
    final rawCount = ratingMap != null ? ratingMap['count'] : json['ratingCount'];

    return Product(
      id: json['id'].toString(),
      title: json['title'] as String? ?? 'Sans titre',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Général',
      imageUrl: json['image'] as String? ?? json['imageUrl'] as String? ?? '',
      rating: (rawRating as num?)?.toDouble() ?? 0.0,
      ratingCount: (rawCount as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'description': description,
      'category': category,
      'imageUrl': imageUrl,
      'rating': rating,
      'ratingCount': ratingCount,
    };
  }

  Product copyWith({
    String? id,
    String? title,
    double? price,
    String? description,
    String? category,
    String? imageUrl,
    double? rating,
    int? ratingCount,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      description: description ?? this.description,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
