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

  group('CartNotifier tests', () {
    test('Le panier démarre vide', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.isEmpty, isTrue);
      expect(cartState.items.length, 0);
      expect(cartState.totalItemCount, 0);
      expect(cartState.subtotal, 0.0);
      expect(cartState.shippingFee, 0.0);
    });

    test('Ajout d’un article dans le panier', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 2);

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.items.length, 1);
      expect(cartState.totalItemCount, 2);
      expect(cartState.subtotal, 40.0);
      expect(cartState.shippingFee, 4.99); // Subtotal < 50€ => frais appliqués
      expect(cartState.total, 44.99);
    });

    test('Frais de port offerts à partir de 50€', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1); // 20€
      notifier.addItem(testProduct2, quantity: 1); // 40€ => Total 60€

      final cartState = container.read(cartNotifierProvider);
      expect(cartState.subtotal, 60.0);
      expect(cartState.shippingFee, 0.0); // Offerts car >= 50€
      expect(cartState.total, 60.0);
    });

    test('Incrément et décrément de quantité', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1, quantity: 1);

      notifier.incrementQuantity('p1');
      expect(container.read(cartNotifierProvider).totalItemCount, 2);

      notifier.decrementQuantity('p1');
      expect(container.read(cartNotifierProvider).totalItemCount, 1);

      // Si quantité == 1, décrémenter supprime l'article
      notifier.decrementQuantity('p1');
      expect(container.read(cartNotifierProvider).isEmpty, isTrue);
    });

    test('Vider le panier (clearCart)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartNotifierProvider.notifier);
      notifier.addItem(testProduct1);
      notifier.addItem(testProduct2);
      expect(container.read(cartNotifierProvider).items.length, 2);

      notifier.clearCart();
      expect(container.read(cartNotifierProvider).isEmpty, isTrue);
    });
  });
}
