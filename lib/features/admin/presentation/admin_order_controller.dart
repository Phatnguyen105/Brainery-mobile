import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../orders/data/order_models.dart';
import '../../orders/presentation/order_controller.dart';

final adminOrderControllerProvider =
    AsyncNotifierProvider<AdminOrderController, List<OrderModel>>(
      AdminOrderController.new,
    );

class AdminOrderController extends AsyncNotifier<List<OrderModel>> {
  @override
  Future<List<OrderModel>> build() async {
    ref.watch(authControllerProvider);
    final page = await ref.read(orderApiProvider).adminOrders();
    return page.content;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref.read(orderApiProvider).adminOrders();
      return page.content;
    });
  }

  Future<void> markPaid(String orderId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(orderApiProvider).markPaid(orderId);
      final page = await ref.read(orderApiProvider).adminOrders();
      return page.content;
    });
  }
}
