import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../learning/presentation/enrollment_controller.dart';
import '../data/order_api.dart';
import '../data/order_models.dart';

final orderApiProvider = Provider<OrderApi>((ref) {
  return OrderApi(ref.watch(apiClientProvider));
});

final orderControllerProvider =
    AsyncNotifierProvider<OrderController, List<OrderModel>>(
      OrderController.new,
    );

class OrderController extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    final page = await ref.read(orderApiProvider).orders();
    return page.content;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref.read(orderApiProvider).orders();
      return page.content;
    });
  }

  Future<OrderModel?> checkout() async {
    OrderModel? order;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      order = await ref.read(orderApiProvider).checkout();
      ref.invalidate(cartControllerProvider);
      final page = await ref.read(orderApiProvider).orders();
      return page.content;
    });
    return order;
  }

  Future<TransactionModel?> createTransaction(
    OrderModel order,
    String provider,
  ) async {
    TransactionModel? transaction;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      transaction = await ref
          .read(orderApiProvider)
          .createTransaction(order, provider);
      final page = await ref.read(orderApiProvider).orders();
      return page.content;
    });
    return transaction;
  }

  Future<TransactionModel?> confirmSandbox(
    TransactionModel transaction,
  ) async {
    TransactionModel? confirmed;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      confirmed = await ref.read(orderApiProvider).confirmSandbox(transaction);
      ref.invalidate(cartControllerProvider);
      ref.invalidate(myEnrollmentsProvider);
      final page = await ref.read(orderApiProvider).orders();
      return page.content;
    });
    return confirmed;
  }
}
