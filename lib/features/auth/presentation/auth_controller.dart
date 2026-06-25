import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_api.dart';
import '../data/auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(apiClientProvider));
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(AuthController.new);

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final token = await ref.read(tokenStorageProvider).readAccessToken();
    if (token == null || token.isEmpty) return null;
    try {
      return await ref.read(authApiProvider).me();
    } catch (_) {
      await ref.read(tokenStorageProvider).clear();
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final auth = await ref
          .read(authApiProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStorageProvider)
          .saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
          );
      return ref.read(authApiProvider).me();
    });
  }

  Future<void> register(String fullName, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(authApiProvider)
          .register(fullName: fullName, email: email, password: password);
      final auth = await ref
          .read(authApiProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStorageProvider)
          .saveTokens(
            accessToken: auth.accessToken,
            refreshToken: auth.refreshToken,
          );
      return ref.read(authApiProvider).me();
    });
  }

  Future<void> logout() async {
    final storage = ref.read(tokenStorageProvider);
    final refreshToken = await storage.readRefreshToken();
    state = const AsyncLoading();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await ref.read(authApiProvider).logout(refreshToken);
      } catch (_) {
        // Local logout still wins when backend is unavailable.
      }
    }
    await storage.clear();
    state = const AsyncData(null);
  }
}
