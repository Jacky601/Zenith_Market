import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zenith_market/data/models/product.dart';
import 'package:zenith_market/providers/cart_provider.dart';

void main() {
  const testProduct1 = Product(
    id: 'p1',
    title: 'Test T-Shirt',
    price: 20.0,
    description: 'A great t-shirt',
    category: "men's clothing",
    imageUrl: 'https://example.com/tshirt.png',
  );

  const testProduct2 = Product(
    id: 'p2',
    title: 'Test Casque Audio',
    price: 40.0,
    description: 'High fidelity audio',
    category: 'electronics',
    imageUrl: 'https://example.com/headphones.png',
  );

  group('CartNotifier unit tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Le panier démarre vide', () {
      final cartState = container.read(cartNotifierProvider);
      expect(cartState.isEmpty, isTrue);
      expect(cartState.items.length, 0);
      expect(cartState.totalItemCount, 0);
      expect(cartState.subtotal, 0.0);
      expect(cartState.shippingFee, 0.0);
      expect(cartState.total, 0.0);
    });

    test('addItem ajoute un nouvel article dans le panier', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1);

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.items.length, 1);
      expect(cartState.items.first.product.id, 'p1');
      expect(cartState.items.first.quantity, 1);
      expect(cartState.totalItemCount, 1);
    });

    test('addItem cumule la quantité si le produit est déjà présent', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1);
      notifier.addItem(testProduct1, quantity: 2);

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.items.length, 1);
      expect(cartState.items.first.quantity, 3);
      expect(cartState.totalItemCount, 3);
    });

    test('incrementQuantity augmente la quantité d’un article existant', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1);

      notifier.incrementQuantity('p1');
      expect(container.read(cartNotifierProvider).getQuantity('p1'), 2);
    });

    test('decrementQuantity diminue la quantité quand elle est supérieure à 1', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 3);

      notifier.decrementQuantity('p1');
      expect(container.read(cartNotifierProvider).getQuantity('p1'), 2);
    });

    test('decrementQuantity lorsque la quantité est de 1 supprime l’article', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1);
      expect(container.read(cartNotifierProvider).items.length, 1);

      // Quantité initiale = 1, décrémenter doit supprimer l'article
      notifier.decrementQuantity('p1');

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.items.isEmpty, isTrue);
      expect(cartState.totalItemCount, 0);
      expect(cartState.getQuantity('p1'), 0);
    });

    test('removeItem retire directement un article du panier', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 2);
      notifier.addItem(testProduct2, quantity: 1);
      expect(container.read(cartNotifierProvider).items.length, 2);

      notifier.removeItem('p1');

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.items.length, 1);
      expect(cartState.items.first.product.id, 'p2');
    });

    test('clearCart vide complètement le panier', () {
      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 2);
      notifier.addItem(testProduct2, quantity: 1);
      expect(container.read(cartNotifierProvider).isEmpty, isFalse);

      // Vidage du panier
      notifier.clearCart();

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.isEmpty, isTrue);
      expect(cartState.items, isEmpty);
      expect(cartState.totalItemCount, 0);
      expect(cartState.total, 0.0);
    });

    test('Calcul des frais de port : payants sous 50€ et offerts dès 50€', () {
      final notifier = container.read(cartNotifierProvider.notifier);

      // Sous 50€ (20€)
      notifier.addItem(testProduct1, quantity: 1);
      var cartState = container.read(cartNotifierProvider);
      expect(cartState.subtotal, 20.0);
      expect(cartState.shippingFee, 4.99);
      expect(cartState.total, closeTo(24.99, 0.001));

      // Ajout de 40€ supplémentaires => 60€ (>= 50€)
      notifier.addItem(testProduct2, quantity: 1);
      cartState = container.read(cartNotifierProvider);
      expect(cartState.subtotal, 60.0);
      expect(cartState.shippingFee, 0.0);
      expect(cartState.total, 60.0);
    });
  });
}
