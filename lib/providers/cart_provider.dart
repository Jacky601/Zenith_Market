import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  double get subtotal =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  /// Frais de port offerts à partir de 50€ d'achats, sinon 4.99€ (0 si panier vide)
  double get shippingFee {
    if (items.isEmpty) return 0.0;
    return subtotal >= 50.0 ? 0.0 : 4.99;
  }

  double get total =>
      double.parse((subtotal + shippingFee).toStringAsFixed(2));

  int get totalItemCount =>
      items.fold(0, (count, item) => count + item.quantity);

  bool get isEmpty => items.isEmpty;

  int getQuantity(String productId) {
    try {
      final item = items.firstWhere((it) => it.product.id == productId);
      return item.quantity;
    } catch (_) {
      return 0;
    }
  }

  CartState copyWith({List<CartItem>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void addItem(Product product, {int quantity = 1}) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedList = List<CartItem>.from(state.items);
      final existingItem = updatedList[existingIndex];
      updatedList[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
      state = state.copyWith(items: updatedList);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: quantity)],
      );
    }
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((item) => item.product.id != productId).toList(),
    );
  }

  void incrementQuantity(String productId) {
    final updatedList = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedList);
  }

  void decrementQuantity(String productId) {
    final updatedList = <CartItem>[];

    for (final item in state.items) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          updatedList.add(item.copyWith(quantity: item.quantity - 1));
        }
        // Si quantité == 1, l'article est supprimé
      } else {
        updatedList.add(item);
      }
    }

    state = state.copyWith(items: updatedList);
  }

  void clearCart() {
    state = const CartState();
  }

  int getQuantity(String productId) {
    try {
      final item = state.items.firstWhere((it) => it.product.id == productId);
      return item.quantity;
    } catch (_) {
      return 0;
    }
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});
