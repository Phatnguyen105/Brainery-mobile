import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/device_api.dart';
import '../data/device_models.dart';

final deviceApiProvider = Provider<DeviceApi>((ref) {
  return DeviceApi(ref.watch(apiClientProvider));
});

final deviceControllerProvider =
    AsyncNotifierProvider<DeviceController, List<DeviceModel>>(
      DeviceController.new,
    );

class DeviceController extends AsyncNotifier<List<DeviceModel>> {
  @override
  Future<List<DeviceModel>> build() {
    ref.watch(authControllerProvider);
    return ref.read(deviceApiProvider).devices();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(deviceApiProvider).devices());
  }

  Future<void> registerCurrentDevice() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final storage = ref.read(tokenStorageProvider);
      var deviceId = await storage.readDeviceId();
      if (deviceId == null || deviceId.isEmpty) {
        deviceId = _uuidV4();
        await storage.saveDeviceId(deviceId);
      }
      await ref
          .read(deviceApiProvider)
          .upsert(
            deviceId: deviceId,
            platform: 'Android',
            deviceName: 'Android Emulator',
            appVersion: AppConstants.appVersion,
          );
      return ref.read(deviceApiProvider).devices();
    });
  }

  Future<void> remove(String deviceId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deviceApiProvider).deleteDevice(deviceId);
      return ref.read(deviceApiProvider).devices();
    });
  }

  String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int value) => value.toRadixString(16).padLeft(2, '0');
    final text = bytes.map(hex).join();
    return '${text.substring(0, 8)}-${text.substring(8, 12)}-'
        '${text.substring(12, 16)}-${text.substring(16, 20)}-'
        '${text.substring(20)}';
  }
}
