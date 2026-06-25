import '../../../core/network/api_client.dart';
import 'device_models.dart';

class DeviceApi {
  const DeviceApi(this._client);

  final ApiClient _client;

  Future<List<DeviceModel>> devices() {
    return _client.getData<List<DeviceModel>>(
      '/api/me/devices',
      parse: (json) {
        final list = json is List ? json : const [];
        return list.map(DeviceModel.fromJson).toList();
      },
    );
  }

  Future<DeviceModel> upsert({
    required String deviceId,
    required String platform,
    required String deviceName,
    required String appVersion,
  }) {
    return _client.postData<DeviceModel>(
      '/api/me/devices',
      data: {
        'deviceId': deviceId,
        'platform': platform,
        'deviceName': deviceName,
        'appVersion': appVersion,
      },
      parse: DeviceModel.fromJson,
    );
  }

  Future<void> deleteDevice(String deviceId) {
    return _client.deleteData<void>('/api/me/devices/$deviceId', parse: (_) {});
  }
}
