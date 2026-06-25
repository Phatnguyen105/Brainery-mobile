import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/data/course_models.dart';
import '../data/enrollment_api.dart';
import '../data/enrollment_models.dart';
import '../data/progress_models.dart';

final enrollmentApiProvider = Provider<EnrollmentApi>((ref) {
  return EnrollmentApi(ref.watch(apiClientProvider));
});

final enrollmentStatusProvider =
    FutureProvider.family<EnrollmentStatusModel, String>((ref, courseId) {
      ref.watch(authControllerProvider);
      return ref.watch(enrollmentApiProvider).status(courseId);
    });

final courseProgressProvider =
    FutureProvider.family<CourseProgressModel, String>((ref, courseId) {
      ref.watch(authControllerProvider);
      return ref.watch(enrollmentApiProvider).getCourseProgress(courseId);
    });

final lessonQuizzesProvider =
    FutureProvider.family<List<QuizMetadataModel>, String>((ref, lessonId) {
      ref.watch(authControllerProvider);
      return ref.watch(enrollmentApiProvider).getLessonQuizzes(lessonId);
    });

final quizResultProvider =
    FutureProvider.family<QuizResultModel, String>((ref, quizId) {
      ref.watch(authControllerProvider);
      return ref.watch(enrollmentApiProvider).getQuizResult(quizId);
    });

final myEnrollmentsProvider = FutureProvider<List<CourseSummary>>((ref) async {
  ref.watch(authControllerProvider);
  final page = await ref.watch(enrollmentApiProvider).myEnrollments();
  return page.content;
});

final enrollmentActionProvider =
    AsyncNotifierProvider<EnrollmentActionController, void>(
      EnrollmentActionController.new,
    );

class EnrollmentActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> enroll(String courseId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(enrollmentApiProvider).enroll(courseId);
      } on ApiException catch (error) {
        if (error.statusCode != 409) {
          rethrow;
        }
      }
      ref.invalidate(enrollmentStatusProvider(courseId));
      ref.invalidate(myEnrollmentsProvider);
    });
  }

  Future<void> completeLesson(String courseId, String lessonId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(enrollmentApiProvider).completeLesson(lessonId);
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(enrollmentStatusProvider(courseId));
    });
  }

  Future<void> updateLessonProgress(
    String courseId,
    String lessonId, {
    required int watchedSeconds,
    required int lastPositionSeconds,
    required double completedPercent,
    required bool isCompleted,
  }) async {
    await ref.read(enrollmentApiProvider).updateProgress(
          lessonId,
          watchedSeconds: watchedSeconds,
          lastPositionSeconds: lastPositionSeconds,
          completedPercent: completedPercent,
          isCompleted: isCompleted,
        );
    if (isCompleted) {
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(enrollmentStatusProvider(courseId));
    }
  }

  Future<QuizResultModel?> submitQuiz(
    String courseId,
    String quizId,
    List<Map<String, dynamic>> answers,
  ) async {
    state = const AsyncLoading();
    QuizResultModel? result;
    state = await AsyncValue.guard(() async {
      result =
          await ref.read(enrollmentApiProvider).submitQuiz(quizId, answers);
      ref.invalidate(courseProgressProvider(courseId));
      ref.invalidate(enrollmentStatusProvider(courseId));
    });
    return result;
  }
}
