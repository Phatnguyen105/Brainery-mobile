import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../data/admin_user_api.dart';
import '../data/admin_user_models.dart';

final adminUserApiProvider = Provider<AdminUserApi>((ref) {
  return AdminUserApi(ref.watch(apiClientProvider));
});

final adminUserControllerProvider =
    AsyncNotifierProvider<AdminUserController, List<AdminUserModel>>(
      AdminUserController.new,
    );

class AdminUserController extends AsyncNotifier<List<AdminUserModel>> {
  @override
  Future<List<AdminUserModel>> build() async {
    final page = await ref.read(adminUserApiProvider).users();
    return page.content;
  }

  Future<void> refresh() {
    return _reload();
  }

  Future<void> updateStatus(String userId, String status) {
    return _mutate(
      () => ref.read(adminUserApiProvider).updateStatus(userId, status),
    );
  }

  Future<void> updateRoles(String userId, List<String> roles) {
    return _mutate(
      () => ref.read(adminUserApiProvider).updateRoles(userId, roles),
    );
  }

  Future<void> deleteUser(String userId) {
    return _mutate(() => ref.read(adminUserApiProvider).deleteUser(userId));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      final page = await ref.read(adminUserApiProvider).users();
      return page.content;
    });
  }

  Future<void> _reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final page = await ref.read(adminUserApiProvider).users();
      return page.content;
    });
  }
}
