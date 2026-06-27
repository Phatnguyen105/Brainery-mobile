import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/auth_route_helper.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/loading_view.dart';
import 'auth_controller.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authControllerProvider, (previous, next) {
      next.whenData((user) {
        if (!context.mounted) return;
        context.go(user == null ? RouteNames.login : routeForUser(user));
      });
    });

    return const Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories, size: 68, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Brainery Mobile',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 28),
            LoadingView(message: 'Đang kiểm tra phiên đăng nhập...'),
          ],
        ),
      ),
    );
  }
}
