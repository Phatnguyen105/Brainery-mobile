import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/cart_api.dart';
import '../data/cart_models.dart';

final cartApiProvider = Provider<CartApi>((ref) {
  return CartApi(ref.watch(apiClientProvider));
});

final cartControllerProvider = AsyncNotifierProvider<CartController, CartModel>(
  CartController.new,
);

class CartController extends AsyncNotifier<CartModel> {
  @override
  Future<CartModel> build() async {
    return ref.read(cartApiProvider).findCart();
  }

  Future<void> addItem(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartApiProvider).addItem(courseId),
    );
  }

  Future<void> removeItem(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartApiProvider).removeItem(courseId),
    );
  }
}
