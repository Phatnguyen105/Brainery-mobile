import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/auth_route_helper.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null && context.mounted) context.go(routeForUser(user));
        },
        error: (error, _) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_add_alt_1_outlined,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tạo tài khoản Brainery',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bắt đầu học các khóa học phù hợp với mục tiêu của bạn.',
              style: TextStyle(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'Họ và tên',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập họ tên'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _password,
                    label: 'Mật khẩu',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhập mật khẩu';
                      }
                      if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirmPassword,
                    label: 'Xác nhận mật khẩu',
                    prefixIcon: Icons.verified_user_outlined,
                    obscureText: true,
                    validator: (value) => value != _password.text
                        ? 'Mật khẩu xác nhận không khớp'
                        : null,
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: 'Tạo tài khoản',
                    icon: Icons.person_add_alt,
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => context.go(RouteNames.login),
              child: const Text('Đã có tài khoản? Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nhập email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return ok ? null : 'Email chưa đúng định dạng';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(_name.text.trim(), _email.text.trim(), _password.text);
  }
}
