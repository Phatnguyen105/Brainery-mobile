import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import 'enrollment_models.dart';
import 'progress_models.dart';

class EnrollmentApi {
  const EnrollmentApi(this._client);

  final ApiClient _client;

  Future<EnrollmentResult> enroll(String courseId) {
    return _client.postData<EnrollmentResult>(
      '/api/enrollments',
      data: {'courseId': courseId},
      parse: EnrollmentResult.fromJson,
    );
  }

  Future<EnrollmentStatusModel> status(String courseId) {
    return _client.getData<EnrollmentStatusModel>(
      '/api/me/enrollments/$courseId',
      parse: EnrollmentStatusModel.fromJson,
    );
  }

  Future<PageResult<CourseSummary>> myEnrollments() {
    return _client.getData<PageResult<CourseSummary>>(
      '/api/me/enrollments',
      queryParameters: {'size': 50},
      parse: (json) => PageResult.fromJson(json, CourseSummary.fromJson),
    );
  }

  Future<LearningProgressModel> updateProgress(
    String lessonId, {
    int? watchedSeconds,
    int? lastPositionSeconds,
    double? completedPercent,
    bool? isCompleted,
  }) {
    return _client.postData<LearningProgressModel>(
      '/api/me/lessons/$lessonId/progress',
      data: {
        'watchedSeconds': watchedSeconds ?? 0,
        'lastPositionSeconds': lastPositionSeconds ?? 0,
        'completedPercent': completedPercent ?? 0.0,
        'isCompleted': isCompleted ?? false,
      },
      parse: LearningProgressModel.fromJson,
    );
  }

  Future<LearningProgressModel> completeLesson(String lessonId) {
    return _client.postData<LearningProgressModel>(
      '/api/me/lessons/$lessonId/complete',
      data: {},
      parse: LearningProgressModel.fromJson,
    );
  }

  Future<CourseProgressModel> getCourseProgress(String courseId) {
    return _client.getData<CourseProgressModel>(
      '/api/me/courses/$courseId/progress',
      parse: CourseProgressModel.fromJson,
    );
  }

  Future<QuizResultModel> submitQuiz(
    String quizId,
    List<Map<String, dynamic>> answers,
  ) {
    return _client.postData<QuizResultModel>(
      '/api/me/quizzes/$quizId/submit',
      data: {'answers': answers},
      parse: QuizResultModel.fromJson,
    );
  }

  Future<QuizResultModel> getQuizResult(String quizId) {
    return _client.getData<QuizResultModel>(
      '/api/me/quizzes/$quizId/result',
      parse: QuizResultModel.fromJson,
    );
  }

  Future<List<QuizMetadataModel>> getLessonQuizzes(String lessonId) {
    return _client.getData<List<QuizMetadataModel>>(
      '/api/lessons/$lessonId/quizzes',
      parse: (json) {
        final list = json is List ? json : [];
        return list.map(QuizMetadataModel.fromJson).toList();
      },
    );
  }
}
