import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.hasValue ? auth.requireValue : null;

    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((value) {
        if (value == null && context.mounted) context.go(RouteNames.login);
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Ca nhan')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CircleAvatar(
              radius: 42,
              child: Text(
                (user?.fullName.isNotEmpty ?? false)
                    ? user!.fullName.characters.first.toUpperCase()
                    : 'B',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'Hoc vien Brainery',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(user?.email ?? '', textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Don hang'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.orders),
            ),
            ListTile(
              leading: const Icon(Icons.devices_outlined),
              title: const Text('Thiet bi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.devices),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Dang xuat',
              icon: Icons.logout,
              isLoading: auth.isLoading,
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
            ),
          ],
        ),
      ),
    );
  }
}
