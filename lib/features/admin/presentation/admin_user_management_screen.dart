import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../data/admin_user_models.dart';
import 'admin_user_controller.dart';

class AdminUserManagementScreen extends ConsumerWidget {
  const AdminUserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUserControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan ly nguoi dung'),
        actions: [
          IconButton(
            tooltip: 'Lam moi',
            onPressed: () =>
                ref.read(adminUserControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(adminUserControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              usersAsync.when(
                loading: () => const _LoadingState(),
                error: (error, _) => _ErrorState(
                  message: error.toString(),
                  onRetry: () =>
                      ref.read(adminUserControllerProvider.notifier).refresh(),
                ),
                data: (users) {
                  if (users.isEmpty) {
                    return const _EmptyState();
                  }
                  return Column(
                    children: users
                        .map(
                          (user) => _UserCard(
                            user: user,
                            onToggleStatus: () => _run(
                              context,
                              ref,
                              () => ref
                                  .read(adminUserControllerProvider.notifier)
                                  .updateStatus(
                                    user.id,
                                    user.isActive ? 'BANNED' : 'ACTIVE',
                                  ),
                              user.isActive
                                  ? 'Da khoa tai khoan.'
                                  : 'Da mo khoa tai khoan.',
                            ),
                            onRoles: () => _openRolesSheet(context, ref, user),
                            onDelete: () => _confirmDelete(context, ref, user),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
    String successMessage,
  ) async {
    await action();
    if (!context.mounted) return;
    final state = ref.read(adminUserControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : successMessage),
      ),
    );
  }

  Future<void> _openRolesSheet(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (_) => _RolesSheet(user: user),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AdminUserModel user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xoa nguoi dung?'),
        content: Text(user.email),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    await _run(
      context,
      ref,
      () => ref.read(adminUserControllerProvider.notifier).deleteUser(user.id),
      'Da xoa nguoi dung.',
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.user,
    required this.onToggleStatus,
    required this.onRoles,
    required this.onDelete,
  });

  final AdminUserModel user;
  final VoidCallback onToggleStatus;
  final VoidCallback onRoles;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName?.isNotEmpty == true
                            ? user.fullName!
                            : user.email,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(user.email, style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                _StatusPill(status: user.status),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.roles.isEmpty
                  ? [const _RolePill(role: 'NO_ROLE')]
                  : user.roles.map((role) => _RolePill(role: role)).toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onRoles,
                  icon: const Icon(Icons.admin_panel_settings_outlined),
                  label: const Text('Role'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleStatus,
                  icon: Icon(
                    user.isActive
                        ? Icons.lock_outline
                        : Icons.lock_open_outlined,
                  ),
                  label: Text(user.isActive ? 'Khoa' : 'Mo khoa'),
                ),
                OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Xoa'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RolesSheet extends ConsumerStatefulWidget {
  const _RolesSheet({required this.user});

  final AdminUserModel user;

  @override
  ConsumerState<_RolesSheet> createState() => _RolesSheetState();
}

class _RolesSheetState extends ConsumerState<_RolesSheet> {
  late final Set<String> _roles = widget.user.roles
      .map((role) => role.toUpperCase().replaceFirst('ROLE_', ''))
      .toSet();

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(adminUserControllerProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Gan role',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Dong',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(widget.user.email),
          const SizedBox(height: 14),
          for (final role in const ['ADMIN', 'INSTRUCTOR', 'STUDENT'])
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(role),
              value: _roles.contains(role),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _roles.add(role);
                  } else {
                    _roles.remove(role);
                  }
                });
              },
            ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: isSaving || _roles.isEmpty ? null : _save,
            icon: isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: const Text('Luu role'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    await ref
        .read(adminUserControllerProvider.notifier)
        .updateRoles(widget.user.id, _roles.toList());
    if (!mounted) return;
    final state = ref.read(adminUserControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.hasError ? state.error.toString() : 'Da cap nhat role.',
        ),
      ),
    );
    if (!state.hasError) Navigator.of(context).pop();
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status.toUpperCase() == 'ACTIVE';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          status,
          style: TextStyle(
            color: isActive ? AppColors.primaryDark : Colors.red.shade700,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  const _RolePill({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(role),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thu lai'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('Chua co nguoi dung nao.')),
    );
  }
}
