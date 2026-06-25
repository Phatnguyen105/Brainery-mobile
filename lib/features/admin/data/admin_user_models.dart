class AdminUserModel {
  const AdminUserModel({
    required this.id,
    required this.email,
    required this.status,
    required this.roles,
    this.fullName,
  });

  final String id;
  final String? fullName;
  final String email;
  final String status;
  final List<String> roles;

  bool get isActive => status.toUpperCase() == 'ACTIVE';
  bool get isBanned => status.toUpperCase() == 'BANNED';

  factory AdminUserModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return AdminUserModel(
      id: map['id']?.toString() ?? '',
      fullName: map['fullName']?.toString(),
      email: map['email']?.toString() ?? '',
      status: map['status']?.toString() ?? 'ACTIVE',
      roles:
          (map['roles'] as List<dynamic>?)
              ?.map((role) => role.toString())
              .toList() ??
          const [],
    );
  }
}
