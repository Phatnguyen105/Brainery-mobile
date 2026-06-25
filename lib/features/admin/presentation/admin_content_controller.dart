import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/data/course_models.dart';
import '../data/admin_content_api.dart';

final adminContentApiProvider = Provider<AdminContentApi>((ref) {
  return AdminContentApi(ref.watch(apiClientProvider));
});

final adminContentControllerProvider =
    AsyncNotifierProvider.family<AdminContentController, CourseDetail, String>(
      AdminContentController.new,
    );

class AdminContentController extends AsyncNotifier<CourseDetail> {
  AdminContentController(this.courseId);

  final String courseId;

  @override
  Future<CourseDetail> build() {
    ref.watch(authControllerProvider);
    return ref.read(adminContentApiProvider).findCourse(courseId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(adminContentApiProvider).findCourse(courseId),
    );
  }

  Future<void> saveSection({
    String? id,
    required String title,
    required int sortOrder,
  }) {
    return _mutate(() async {
      if (id == null) {
        await ref
            .read(adminContentApiProvider)
            .createSection(
              courseId: courseId,
              title: title,
              sortOrder: sortOrder,
            );
      } else {
        await ref
            .read(adminContentApiProvider)
            .updateSection(sectionId: id, title: title, sortOrder: sortOrder);
      }
    });
  }

  Future<void> deleteSection(String sectionId) {
    return _mutate(
      () => ref.read(adminContentApiProvider).deleteSection(sectionId),
    );
  }

  Future<void> saveLesson({
    String? id,
    required String sectionId,
    required String title,
    required int sortOrder,
    required String lessonType,
    required bool isPreview,
    String? videoUrl,
    String? content,
  }) {
    return _mutate(() async {
      if (id == null) {
        await ref
            .read(adminContentApiProvider)
            .createLesson(
              sectionId: sectionId,
              title: title,
              sortOrder: sortOrder,
              lessonType: lessonType,
              isPreview: isPreview,
              videoUrl: videoUrl,
              content: content,
            );
      } else {
        await ref
            .read(adminContentApiProvider)
            .updateLesson(
              lessonId: id,
              title: title,
              sortOrder: sortOrder,
              lessonType: lessonType,
              isPreview: isPreview,
              videoUrl: videoUrl,
              content: content,
            );
      }
    });
  }

  Future<void> deleteLesson(String lessonId) {
    return _mutate(
      () => ref.read(adminContentApiProvider).deleteLesson(lessonId),
    );
  }

  Future<void> _mutate(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await action();
      return ref.read(adminContentApiProvider).findCourse(courseId);
    });
  }
}
