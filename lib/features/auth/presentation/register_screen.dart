import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/auth_route_helper.dart';
import '../../../core/router/route_names.dart';
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
      appBar: AppBar(title: const Text('Dang ky')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Tao tai khoan Brainery',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Bat dau hoc cac khoa hoc phu hop voi muc tieu cua ban.',
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'Ho va ten',
                    prefixIcon: Icons.person_outline,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhap ho ten'
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
                    label: 'Mat khau',
                    prefixIcon: Icons.lock_outline,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nhap mat khau';
                      }
                      if (value.length < 6) return 'Mat khau toi thieu 6 ky tu';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    controller: _confirmPassword,
                    label: 'Xac nhan mat khau',
                    prefixIcon: Icons.verified_user_outlined,
                    obscureText: true,
                    validator: (value) => value != _password.text
                        ? 'Mat khau xac nhan khong khop'
                        : null,
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: 'Tao tai khoan',
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
              child: const Text('Da co tai khoan? Dang nhap'),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nhap email';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    return ok ? null : 'Email chua dung dinh dang';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .register(_name.text.trim(), _email.text.trim(), _password.text);
  }
}
