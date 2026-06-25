import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import '../data/admin_course_api.dart';

final adminCourseApiProvider = Provider<AdminCourseApi>((ref) {
  return AdminCourseApi(ref.watch(apiClientProvider));
});

final adminCourseControllerProvider =
    AsyncNotifierProvider<AdminCourseController, List<CourseSummary>>(
      AdminCourseController.new,
    );

class AdminCourseController extends AsyncNotifier<List<CourseSummary>> {
  String? _status;

  @override
  Future<List<CourseSummary>> build() async {
    ref.watch(authControllerProvider);
    return ref.read(adminCourseApiProvider).listCourses(status: _status);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminCourseApiProvider).listCourses(status: _status),
    );
  }

  Future<void> setStatus(String? status) async {
    _status = status;
    await refresh();
  }

  Future<void> create({
    required String categoryId,
    required String title,
    required String slug,
    required String level,
    required double price,
    required String status,
    required bool isFeatured,
    String? description,
    String? imageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(adminCourseApiProvider)
          .createCourse(
            categoryId: categoryId,
            title: title,
            slug: slug,
            level: level,
            price: price,
            status: status,
            isFeatured: isFeatured,
            description: description,
            imageUrl: imageUrl,
          );
      ref.invalidate(courseListControllerProvider);
      ref.invalidate(featuredCoursesProvider);
      return ref.read(adminCourseApiProvider).listCourses(status: _status);
    });
  }

  Future<void> publish(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminCourseApiProvider).publish(courseId);
      ref.invalidate(courseListControllerProvider);
      ref.invalidate(featuredCoursesProvider);
      return ref.read(adminCourseApiProvider).listCourses(status: _status);
    });
  }

  Future<void> archive(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(adminCourseApiProvider).archive(courseId);
      ref.invalidate(courseListControllerProvider);
      ref.invalidate(featuredCoursesProvider);
      return ref.read(adminCourseApiProvider).listCourses(status: _status);
    });
  }
}
