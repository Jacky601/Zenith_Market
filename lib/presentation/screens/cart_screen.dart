import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../providers/cart_provider.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/empty_state_view.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  void _showCheckoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green),
            SizedBox(width: 8),
            Text('Commande validée !'),
          ],
        ),
        content: const Text(
          'Merci pour votre achat sur Zenith Market ! Votre commande fictive a été traitée avec succès.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(cartNotifierProvider.notifier).clearCart();
              context.go('/catalog');
            },
            child: const Text('Retour à la boutique'),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Vider le panier'),
        content: const Text(
          'Êtes-vous sûr de vouloir retirer tous les articles de votre panier ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart();
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (!cartState.isEmpty)
            IconButton(
              tooltip: 'Vider le panier',
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: () => _showClearConfirmation(context, ref),
            ),
        ],
      ),
      body: cartState.isEmpty
          ? EmptyStateView(
              icon: Icons.shopping_cart_outlined,
              title: 'Votre panier est vide',
              message:
                  'Parcourez nos articles et ajoutez vos coups de cœur pour commencer vos achats.',
              actionLabel: 'Explorer le catalogue',
              onAction: () => context.go('/catalog'),
            )
          : Column(
              children: [
                // Liste des articles
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartState.items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      return CartItemTile(
                        item: item,
                        onTap: () {
                          context.push('/catalog/product/${item.product.id}');
                        },
                      );
                    },
                  ),
                ),

                // Récapitulatif et bouton de commande
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Sous-total',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              Formatters.formatPrice(cartState.subtotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Frais de livraison',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              cartState.shippingFee == 0.0
                                  ? 'Offerts'
                                  : Formatters.formatPrice(cartState.shippingFee),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: cartState.shippingFee == 0.0
                                    ? Colors.green
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(color: Color(0xFFE2E8F0)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total TTC',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              Formatters.formatPrice(cartState.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showCheckoutDialog(context, ref),
                            child: const Text('Passer la commande'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
