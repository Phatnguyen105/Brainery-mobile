import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'auth_models.dart';

class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.postData<AuthResponse>(
      ApiConstants.authLogin,
      data: {'email': email, 'password': password},
      parse: AuthResponse.fromJson,
    );
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _client.postData<UserModel>(
      ApiConstants.authRegister,
      data: {'fullName': fullName, 'email': email, 'password': password},
      parse: UserModel.fromJson,
    );
  }

  Future<UserModel> me() {
    return _client.getData<UserModel>(
      ApiConstants.me,
      parse: UserModel.fromJson,
    );
  }

  Future<void> logout(String refreshToken) {
    return _client.postData<void>(
      ApiConstants.authLogout,
      data: {'refreshToken': refreshToken},
      parse: (_) {},
    );
  }
}
