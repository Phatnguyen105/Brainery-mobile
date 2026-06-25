import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import 'admin_user_models.dart';

class AdminUserApi {
  const AdminUserApi(this._client);

  final ApiClient _client;

  Future<PageResult<AdminUserModel>> users() {
    return _client.getData<PageResult<AdminUserModel>>(
      '/api/admin/users',
      queryParameters: {'size': 50},
      parse: (json) => PageResult.fromJson(json, AdminUserModel.fromJson),
    );
  }

  Future<AdminUserModel> updateStatus(String userId, String status) {
    return _client.patchData<AdminUserModel>(
      '/api/admin/users/$userId/status',
      data: {'status': status},
      parse: AdminUserModel.fromJson,
    );
  }

  Future<AdminUserModel> updateRoles(String userId, List<String> roles) {
    return _client.patchData<AdminUserModel>(
      '/api/admin/users/$userId/roles',
      data: {'roles': roles},
      parse: AdminUserModel.fromJson,
    );
  }

  Future<void> deleteUser(String userId) {
    return _client.deleteData<void>('/api/admin/users/$userId', parse: (_) {});
  }
}
