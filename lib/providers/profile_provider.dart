import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_profile.dart';

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier()
      : super(UserProfile(
          id: 'usr_001',
          fullName: 'Alexandre Dupont',
          email: 'alexandre.dupont@example.com',
          phone: '+33 6 12 34 56 78',
          address: '142 Avenue des Champs-Élysées, 75008 Paris',
          avatarUrl:
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&fit=crop&q=80',
          recentOrders: [
            MockOrder(
              orderId: 'CMD-84920',
              date: DateTime.now().subtract(const Duration(days: 3)),
              totalAmount: 132.25,
              itemCount: 2,
              status: 'Livrée',
            ),
            MockOrder(
              orderId: 'CMD-73819',
              date: DateTime.now().subtract(const Duration(days: 18)),
              totalAmount: 64.00,
              itemCount: 1,
              status: 'Livrée',
            ),
            MockOrder(
              orderId: 'CMD-61023',
              date: DateTime.now().subtract(const Duration(days: 42)),
              totalAmount: 219.98,
              itemCount: 3,
              status: 'Livrée',
            ),
          ],
        ));

  void updateProfile({
    String? fullName,
    String? email,
    String? phone,
    String? address,
  }) {
    state = state.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
      address: address,
    );
  }
}

final userProfileProvider =
    StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});
