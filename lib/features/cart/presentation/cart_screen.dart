import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../orders/presentation/order_controller.dart';
import 'cart_controller.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: SafeArea(
        child: cart.when(
          data: (state) {
            if (state.items.isEmpty) {
              return const EmptyView(
                title: 'Giỏ hàng đang trống',
                message: 'Thêm khóa học vào giỏ hàng để thanh toán.',
                icon: Icons.shopping_cart_outlined,
              );
            }
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(cartControllerProvider),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final course = state.items[index];
                        return Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 44),
                              child: CourseCard(
                                course: course,
                                onTap: () => context.push(
                                  RouteNames.courseDetail(course.id),
                                ),
                              ),
                            ),
                            IconButton.outlined(
                              tooltip: 'Xóa',
                              onPressed: () => ref
                                  .read(cartControllerProvider.notifier)
                                  .removeItem(course.id),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(child: Text('Tổng tiền')),
                          Text(
                            formatter.format(state.totalAmount),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final order = await ref
                              .read(orderControllerProvider.notifier)
                              .checkout();
                          if (!context.mounted) return;
                          final orderState = ref.read(orderControllerProvider);
                          if (orderState.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(orderState.error.toString()),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã tạo đơn hàng.')),
                          );
                          if (order != null) {
                            context.push(
                              RouteNames.payment(order.id),
                              extra: order,
                            );
                          } else {
                            context.push(RouteNames.orders);
                          }
                        },
                        icon: const Icon(Icons.payment_outlined),
                        label: const Text('Thanh toán'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(cartControllerProvider),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}
