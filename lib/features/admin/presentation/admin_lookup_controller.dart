import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import '../data/admin_lookup_api.dart';

final adminLookupApiProvider = Provider<AdminLookupApi>((ref) {
  return AdminLookupApi(ref.watch(apiClientProvider));
});

final adminLookupControllerProvider =
    AsyncNotifierProvider<AdminLookupController, AdminLookupState>(
      AdminLookupController.new,
    );
 
class AdminLookupState {
  const AdminLookupState({required this.categories, required this.tags});

  final List<CategoryModel> categories;
  final List<TagModel> tags;
}

class AdminLookupController extends AsyncNotifier<AdminLookupState> {
  @override
  Future<AdminLookupState> build() {
    ref.watch(authControllerProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> saveCategory({
    String? id,
    required String name,
    required String slug,
  }) {
    return _mutate(() async {
      if (id == null) {
        await ref.read(adminLookupApiProvider).createCategory(name, slug);
      } else {
        await ref.read(adminLookupApiProvider).updateCategory(id, name, slug);
      }
      ref.invalidate(categoriesProvider);
    });
  }

  Future<void> deleteCategory(String id) {
    return _mutate(() async {
      await ref.read(adminLookupApiProvider).deleteCategory(id);
      ref.invalidate(categoriesProvider);
    });
  }

  Future<void> saveTag({
    String? id,
    required String name,
    required String slug,
  }) {
    return _mutate(() async {
      if (id == null) {
        await ref.read(adminLookupApiProvider).createTag(name, slug);
      } else {
        await ref.read(adminLookupApiProvider).updateTag(id, name, slug);
      }
    });
  }

  Future<void> deleteTag(String id) {
    return _mutate(() => ref.read(adminLookupApiProvider).deleteTag(id));
  }

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      return _load();
    });
  }

  Future<AdminLookupState> _load() async {
    final api = ref.read(adminLookupApiProvider);
    final results = await Future.wait([api.categories(), api.tags()]);
    return AdminLookupState(categories: results[0], tags: results[1]);
  }
}
