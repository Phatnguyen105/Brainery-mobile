import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/device_models.dart';
import 'device_controller.dart';

class DeviceManagementScreen extends ConsumerWidget {
  const DeviceManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devices = ref.watch(deviceControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thiet bi'),
        actions: [
          IconButton(
            tooltip: 'Tai lai',
            onPressed: () =>
                ref.read(deviceControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: devices.when(
          data: (items) => Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _register(context, ref),
                    icon: const Icon(Icons.add_to_home_screen_outlined),
                    label: const Text('Ghi nhan thiet bi nay'),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyView(
                        title: 'Chua co thiet bi',
                        message: 'Bam ghi nhan de them emulator hien tai.',
                        icon: Icons.devices_outlined,
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(deviceControllerProvider.notifier)
                            .refresh(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _DeviceCard(
                            device: items[index],
                            onDelete: () => _delete(context, ref, items[index]),
                          ),
                        ),
                      ),
              ),
            ],
          ),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.read(deviceControllerProvider.notifier).refresh(),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }

  Future<void> _register(BuildContext context, WidgetRef ref) async {
    await ref.read(deviceControllerProvider.notifier).registerCurrentDevice();
    if (!context.mounted) return;
    final state = ref.read(deviceControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError ? state.error.toString() : 'Da ghi nhan thiet bi.',
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    DeviceModel device,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa thiet bi?'),
        content: Text(device.deviceName ?? device.deviceId),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(deviceControllerProvider.notifier).remove(device.deviceId);
    if (!context.mounted) return;
    final state = ref.read(deviceControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError ? state.error.toString() : 'Da xoa thiet bi.',
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onDelete});

  final DeviceModel device;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final lastSeen = device.lastSeenAt == null
        ? 'Chua co lan truy cap'
        : DateFormat('dd/MM/yyyy HH:mm').format(device.lastSeenAt!);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone_android, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName?.isNotEmpty == true
                        ? device.deviceName!
                        : 'Android Emulator',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('${device.platform} - ${device.appVersion ?? '1.0.0'}'),
                  const SizedBox(height: 4),
                  Text(lastSeen, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Text(
                    device.deviceId,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Xoa',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}
