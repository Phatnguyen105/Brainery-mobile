import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../auth/presentation/auth_controller.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

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
      appBar: AppBar(
        title: const Text('Bảng quản trị Admin'),
        actions: [
          IconButton(
            tooltip: 'Ứng dụng học viên',
            onPressed: () => context.go(RouteNames.home),
            icon: const Icon(Icons.school_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.admin_panel_settings, color: Colors.white),
                    const SizedBox(height: 12),
                    Text(
                      user?.fullName ?? 'Brainery Admin',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Quản trị nội dung',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            _AdminTile(
              icon: Icons.menu_book_outlined,
              title: 'Quản lý khóa học',
              subtitle: 'Tạo, sửa, xuất bản, lưu trữ khóa học',
              onTap: () => context.push(RouteNames.adminCourses),
            ),
            _AdminTile(
              icon: Icons.category_outlined,
              title: 'Danh mục và thẻ',
              subtitle: 'Quản lý danh mục và thẻ khóa học',
              onTap: () => context.push(RouteNames.adminLookups),
            ),
            _AdminTile(
              icon: Icons.play_lesson_outlined,
              title: 'Chương mục và bài học',
              subtitle: 'Sắp xếp nội dung và bài học',
              onTap: () => context.push(RouteNames.adminContent),
            ),
            const SizedBox(height: 18),
            Text('Vận hành', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _AdminTile(
              icon: Icons.people_outline,
              title: 'Người dùng',
              subtitle: 'Xem tài khoản, khóa/mở tài khoản, gán quyền',
              onTap: () => context.push(RouteNames.adminUsers),
            ),
            _AdminTile(
              icon: Icons.receipt_long_outlined,
              title: 'Đơn hàng và thanh toán',
              subtitle: 'Kiểm tra đơn hàng, giao dịch, xác nhận thanh toán',
              onTap: () => context.push(RouteNames.adminOrders),
            ),
            _AdminTile(
              icon: Icons.notifications_outlined,
              title: 'Thông báo',
              subtitle: 'Gửi thông báo đến học viên',
              onTap: () => _comingSoon(context),
            ),
            _AdminTile(
              icon: Icons.history_outlined,
              title: 'Nhật ký hệ thống',
              subtitle: 'Theo dõi thao tác quản trị',
              onTap: () => _comingSoon(context),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Đăng xuất',
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

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Màn hình quản trị chi tiết sẽ được kết nối API admin tiếp theo.',
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
