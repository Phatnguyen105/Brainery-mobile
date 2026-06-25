import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/order_models.dart';
import 'order_controller.dart';

class OrderListScreen extends ConsumerWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Don hang'),
        actions: [
          IconButton(
            tooltip: 'Tai lai',
            onPressed: () =>
                ref.read(orderControllerProvider.notifier).refresh(),
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
                message: 'Thanh toan gio hang de tao don hang moi.',
                icon: Icons.receipt_long_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () =>
                  ref.read(orderControllerProvider.notifier).refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _OrderCard(order: items[index]),
              ),
            );
          },
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.read(orderControllerProvider.notifier).refresh(),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderModel order;

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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: order.isPaid
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : AppColors.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    order.isPaid
                        ? Icons.verified_outlined
                        : Icons.schedule_outlined,
                    color: order.isPaid ? AppColors.primary : AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Don ${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (date != null) Text(date),
                    ],
                  ),
                ),
                _StatusPill(status: order.status, paid: order.isPaid),
              ],
            ),
            const SizedBox(height: 14),
            _MoneyRow(
              label: 'Tong tien',
              value: currency.format(order.totalAmount),
            ),
            if (order.discountAmount > 0)
              _MoneyRow(
                label: 'Giam gia',
                value: '-${currency.format(order.discountAmount)}',
              ),
            const Divider(height: 20),
            _MoneyRow(
              label: 'Thanh toan',
              value: currency.format(order.finalPrice),
              strong: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.paid});

  final String status;
  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? AppColors.primary : AppColors.accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  const _MoneyRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(context).textTheme.titleMedium
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
