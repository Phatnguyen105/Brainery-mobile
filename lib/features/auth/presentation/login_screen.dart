import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/auth_route_helper.dart';
import '../../../core/router/route_names.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 42),
            const Icon(Icons.auto_stories, size: 56),
            const SizedBox(height: 18),
            Text(
              'Chao mung tro lai',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Dang nhap de tiep tuc hanh trinh hoc tap cua ban.'),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Nhap mat khau' : null,
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: 'Dang nhap',
                    icon: Icons.login,
                    isLoading: auth.isLoading,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => context.go(RouteNames.register),
              child: const Text('Chua co tai khoan? Dang ky ngay'),
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
        .login(_email.text.trim(), _password.text);
  }
}
