import 'package:flutter_test/flutter_test.dart';
import 'package:zenith_market/data/models/product.dart';

void main() {
  group('Product model tests', () {
    test('Désérialisation JSON standard FakeStoreAPI', () {
      final json = {
        'id': 1,
        'title': 'Sac à dos test',
        'price': 49.99,
        'description': 'Description du test',
        'category': 'accessories',
        'image': 'https://example.com/bag.png',
        'rating': {'rate': 4.5, 'count': 120}
      };

      final product = Product.fromJson(json);

      expect(product.id, '1');
      expect(product.title, 'Sac à dos test');
      expect(product.price, 49.99);
      expect(product.category, 'accessories');
      expect(product.imageUrl, 'https://example.com/bag.png');
      expect(product.rating, 4.5);
      expect(product.ratingCount, 120);
    });

    test('Désérialisation avec valeurs par défaut si null', () {
      final json = {
        'id': 42,
        'price': 15,
      };

      final product = Product.fromJson(json);

      expect(product.id, '42');
      expect(product.title, 'Sans titre');
      expect(product.price, 15.0);
      expect(product.category, 'Général');
      expect(product.rating, 0.0);
    });

    test('copyWith fonctionne correctement', () {
      const product = Product(
        id: '1',
        title: 'Original',
        price: 10.0,
        description: 'Desc',
        category: 'Cat',
        imageUrl: 'url',
      );

      final updated = product.copyWith(title: 'Modifié', price: 15.0);

      expect(updated.id, '1');
      expect(updated.title, 'Modifié');
      expect(updated.price, 15.0);
      expect(updated.description, 'Desc');
    });
  });
}
