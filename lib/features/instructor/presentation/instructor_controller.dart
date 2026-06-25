import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import '../data/instructor_api.dart';

final instructorApiProvider = Provider<InstructorApi>((ref) {
  return InstructorApi(ref.watch(apiClientProvider));
});

final instructorCourseControllerProvider =
    AsyncNotifierProvider<InstructorCourseController, List<CourseSummary>>(
      InstructorCourseController.new,
    );

final instructorCourseDetailProvider =
    FutureProvider.family<CourseDetail, String>((ref, courseId) {
      return ref.watch(instructorApiProvider).findCourse(courseId);
    });

class InstructorCourseController extends AsyncNotifier<List<CourseSummary>> {
  @override
  Future<List<CourseSummary>> build() {
    return ref.read(instructorApiProvider).listCourses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(instructorApiProvider).listCourses(),
    );
  }

  Future<void> createCourse({
    required String categoryId,
    required String title,
    required String slug,
    required String level,
    required double price,
    String? description,
    String? imageUrl,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(instructorApiProvider)
          .createCourse(
            categoryId: categoryId,
            title: title,
            slug: slug,
            level: level,
            price: price,
            description: description,
            imageUrl: imageUrl,
          );
      ref.invalidate(courseListControllerProvider);
      ref.invalidate(featuredCoursesProvider);
      return ref.read(instructorApiProvider).listCourses();
    });
  }

  Future<void> createSection({
    required String courseId,
    required String title,
    required int sortOrder,
  }) async {
    await ref
        .read(instructorApiProvider)
        .createSection(courseId: courseId, title: title, sortOrder: sortOrder);
    ref.invalidate(instructorCourseDetailProvider(courseId));
  }

  Future<void> createLesson({
    required String courseId,
    required String sectionId,
    required String title,
    required int sortOrder,
    required String lessonType,
    String? videoUrl,
    String? content,
  }) async {
    await ref
        .read(instructorApiProvider)
        .createLesson(
          sectionId: sectionId,
          title: title,
          sortOrder: sortOrder,
          lessonType: lessonType,
          videoUrl: videoUrl,
          content: content,
        );
    ref.invalidate(instructorCourseDetailProvider(courseId));
  }

  Future<void> createQuiz({
    required String courseId,
    required String lessonId,
    required String title,
    String? description,
    required String questionText,
    required String correctAnswer,
    required List<String> wrongAnswers,
  }) async {
    await ref
        .read(instructorApiProvider)
        .createQuiz(
          lessonId: lessonId,
          title: title,
          description: description,
          questionText: questionText,
          correctAnswer: correctAnswer,
          wrongAnswers: wrongAnswers,
        );
    ref.invalidate(instructorCourseDetailProvider(courseId));
  }
}
