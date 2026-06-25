class DeviceModel {
  const DeviceModel({
    required this.id,
    required this.deviceId,
    required this.platform,
    this.deviceName,
    this.appVersion,
    this.lastSeenAt,
  });

  final String id;
  final String deviceId;
  final String platform;
  final String? deviceName;
  final String? appVersion;
  final DateTime? lastSeenAt;

  factory DeviceModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return DeviceModel(
      id: map['id']?.toString() ?? '',
      deviceId: map['deviceId']?.toString() ?? '',
      platform: map['platform']?.toString() ?? 'Android',
      deviceName: map['deviceName']?.toString(),
      appVersion: map['appVersion']?.toString(),
      lastSeenAt: DateTime.tryParse(map['lastSeenAt']?.toString() ?? ''),
    );
  }
}
