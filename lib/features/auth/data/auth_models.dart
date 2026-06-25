class UserModel {
  const UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.roles,
    this.phoneNumber,
    this.status,
    this.createdAt,
  });

  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? status;
  final List<String> roles;
  final DateTime? createdAt;

  bool get isAdmin => _hasRole('ADMIN');
  bool get isInstructor => _hasRole('INSTRUCTOR');
  bool get isStudent => _hasRole('STUDENT');

  bool _hasRole(String role) {
    return roles.any((value) {
      final normalized = value.toUpperCase().replaceFirst('ROLE_', '');
      return normalized == role;
    });
  }

  factory UserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return UserModel(
      userId: map['userId']?.toString() ?? map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? 'Hoc vien Brainery',
      email: map['email']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString(),
      status: map['status']?.toString(),
      roles:
          (map['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          const [],
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
    );
  }
}

class AuthResponse {
  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresInMs = 0,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresInMs;

  factory AuthResponse.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return AuthResponse(
      accessToken: map['accessToken']?.toString() ?? '',
      refreshToken: map['refreshToken']?.toString() ?? '',
      tokenType: map['tokenType']?.toString() ?? 'Bearer',
      expiresInMs: int.tryParse(map['expiresInMs']?.toString() ?? '') ?? 0,
    );
  }
}
