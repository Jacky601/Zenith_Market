import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zenith_market/data/models/product.dart';
import 'package:zenith_market/data/repositories/mock_products_data.dart';
import 'package:zenith_market/data/repositories/product_repository.dart';

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

    test('Désérialisation avec valeurs par défaut si champs null', () {
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
      expect(product.ratingCount, 0);
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

    test('toJson produit un Map valide', () {
      const product = Product(
        id: '99',
        title: 'Montre Luxe',
        price: 199.99,
        description: 'Montre suisse',
        category: 'jewelery',
        imageUrl: 'https://example.com/watch.png',
        rating: 4.8,
        ratingCount: 50,
      );

      final json = product.toJson();
      expect(json['id'], '99');
      expect(json['title'], 'Montre Luxe');
      expect(json['price'], 199.99);
      expect(json['rating'], 4.8);
    });
  });

  group('ProductRepository tests (chargement API et fallback)', () {
    test('fetchProducts retourne la liste des produits en cas de succès HTTP 200', () async {
      final mockData = [
        {
          'id': 101,
          'title': 'Produit API 1',
          'price': 29.99,
          'description': 'Description API',
          'category': 'tech',
          'image': 'https://example.com/item1.png',
          'rating': {'rate': 4.0, 'count': 10}
        }
      ];

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockData), 200);
      });

      final repository = ProductRepository(client: mockClient);
      final products = await repository.fetchProducts();

      expect(products.length, 1);
      expect(products.first.id, '101');
      expect(products.first.title, 'Produit API 1');
      expect(products.first.price, 29.99);
    });

    test('fetchProducts bascule sur les données fallback en cas d’erreur HTTP 500', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Erreur serveur interne', 500);
      });

      final repository = ProductRepository(client: mockClient);
      final products = await repository.fetchProducts();

      // Doit retourner les données de secours locales
      expect(products.isNotEmpty, isTrue);
      expect(products.length, fallbackProducts.length);
      expect(products.first.id, fallbackProducts.first.id);
    });

    test('fetchProducts bascule sur le fallback en cas d’exception réseau', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connexion réseau perdue');
      });

      final repository = ProductRepository(client: mockClient);
      final products = await repository.fetchProducts();

      expect(products.isNotEmpty, isTrue);
      expect(products.length, fallbackProducts.length);
    });

    test('fetchProductById retourne le produit de l’API quand HTTP 200', () async {
      final item = {
        'id': 7,
        'title': 'Clavier mécanique',
        'price': 89.0,
        'description': 'RGB switches',
        'category': 'electronics',
        'image': 'https://example.com/keyboard.png',
        'rating': {'rate': 4.7, 'count': 88}
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(item), 200);
      });

      final repository = ProductRepository(client: mockClient);
      final product = await repository.fetchProductById('7');

      expect(product, isNotNull);
      expect(product!.title, 'Clavier mécanique');
    });

    test('fetchProductById bascule sur le produit fallback en cas d’échec', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repository = ProductRepository(client: mockClient);
      // '1' existe dans fallbackProducts
      final product = await repository.fetchProductById('1');

      expect(product, isNotNull);
      expect(product!.id, '1');
      expect(product.title, fallbackProducts.first.title);
    });
  });
}
