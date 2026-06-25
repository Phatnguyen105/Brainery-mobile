import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../orders/data/order_models.dart';
import 'admin_order_controller.dart';

class AdminOrderManagementScreen extends ConsumerWidget {
  const AdminOrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminOrderControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan ly don hang'),
        actions: [
          IconButton(
            tooltip: 'Tai lai',
            onPressed: () =>
                ref.read(adminOrderControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: orders.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyView(
                title: 'Chua co don hang',
                message: 'Don hang checkout se hien thi tai day.',
                icon: Icons.receipt_long_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(adminOrderControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _AdminOrderCard(
                  order: items[index],
                  onMarkPaid: () => _markPaid(context, ref, items[index]),
                ),
              ),
            );
          },
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(adminOrderControllerProvider.notifier).refresh(),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }

  Future<void> _markPaid(
    BuildContext context,
    WidgetRef ref,
    OrderModel order,
  ) async {
    await ref.read(adminOrderControllerProvider.notifier).markPaid(order.id);
    if (!context.mounted) return;
    final state = ref.read(adminOrderControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError ? state.error.toString() : 'Da mark paid.',
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  const _AdminOrderCard({required this.order, required this.onMarkPaid});

  final OrderModel order;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    final date = order.createdAt == null
        ? null
        : DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  order.isPaid
                      ? Icons.verified_outlined
                      : Icons.pending_outlined,
                  color: order.isPaid ? AppColors.primary : AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    order.userEmail ?? 'Hoc vien',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  order.status,
                  style: TextStyle(
                    color: order.isPaid ? AppColors.primary : AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Don ${order.id}'),
            if (date != null) Text(date),
            const Divider(height: 20),
            Row(
              children: [
                Expanded(child: Text(currency.format(order.finalPrice))),
                if (!order.isPaid)
                  OutlinedButton.icon(
                    onPressed: onMarkPaid,
                    icon: const Icon(Icons.price_check_outlined),
                    label: const Text('Mark paid'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
