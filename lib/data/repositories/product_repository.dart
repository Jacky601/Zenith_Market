import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'mock_products_data.dart';

class ProductRepository {
  final http.Client _client;
  static const String _baseUrl = 'https://fakestoreapi.com/products';

  ProductRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.parse(_baseUrl))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        return jsonList
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return _loadFallback();
    } catch (_) {
      // Bascule automatique sur les données de secours en cas d'absence de réseau ou d'erreur
      return _loadFallback();
    }
  }

  Future<Product?> fetchProductById(String id) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/$id'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Product.fromJson(json);
      }
      return _loadFallbackProduct(id);
    } catch (_) {
      return _loadFallbackProduct(id);
    }
  }

  Future<List<Product>> _loadFallback() async {
    // Petit délai simulé pour tester AsyncValue.loading
    await Future.delayed(const Duration(milliseconds: 500));
    return fallbackProducts;
  }

  Product? _loadFallbackProduct(String id) {
    try {
      return fallbackProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
