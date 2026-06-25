import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';

class InstructorApi {
  const InstructorApi(this._client);

  final ApiClient _client;

  Future<List<CourseSummary>> listCourses() {
    return _client.getData<List<CourseSummary>>(
      '/api/instructor/courses',
      queryParameters: {'size': 50},
      parse: (json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        final content = map['content'] as List<dynamic>? ?? const [];
        return content.map(CourseSummary.fromJson).toList();
      },
    );
  }

  Future<CourseDetail> findCourse(String courseId) {
    return _client.getData<CourseDetail>(
      ApiConstants.courseDetail(courseId),
      parse: CourseDetail.fromJson,
    );
  }

  Future<CourseDetail> createCourse({
    required String categoryId,
    required String title,
    required String slug,
    required String level,
    required double price,
    String? description,
    String? imageUrl,
  }) {
    return _client.postData<CourseDetail>(
      '/api/instructor/courses',
      data: {
        'categoryId': categoryId,
        'title': title,
        'slug': slug,
        'description': description,
        'level': level,
        'price': price,
        'courseImageUrl': imageUrl,
        'status': 'Published',
        'isFeatured': false,
      },
      parse: CourseDetail.fromJson,
    );
  }

  Future<CourseSectionModel> createSection({
    required String courseId,
    required String title,
    required int sortOrder,
  }) {
    return _client.postData<CourseSectionModel>(
      '/api/instructor/courses/$courseId/sections',
      data: {'title': title, 'sortOrder': sortOrder},
      parse: CourseSectionModel.fromJson,
    );
  }

  Future<LessonModel> createLesson({
    required String sectionId,
    required String title,
    required int sortOrder,
    required String lessonType,
    bool isPreview = false,
    String? videoUrl,
    String? content,
  }) {
    return _client.postData<LessonModel>(
      '/api/instructor/sections/$sectionId/lessons',
      data: {
        'title': title,
        'sortOrder': sortOrder,
        'lessonType': lessonType,
        'isPreview': isPreview,
        'videoUrl': videoUrl,
        'content': content,
      },
      parse: LessonModel.fromJson,
    );
  }

  Future<void> createQuiz({
    required String lessonId,
    required String title,
    String? description,
    int passingScore = 70,
    required String questionText,
    required String correctAnswer,
    required List<String> wrongAnswers,
  }) async {
    await _client.postData<Object?>(
      '/api/instructor/lessons/$lessonId/quizzes',
      data: {
        'title': title,
        'description': description,
        'passingScore': passingScore,
        'questions': [
          {
            'questionText': questionText,
            'questionType': 'SingleChoice',
            'answers': [
              {'answerText': correctAnswer, 'correct': true},
              for (final wrongAnswer in wrongAnswers)
                {'answerText': wrongAnswer, 'correct': false},
            ],
          },
        ],
      },
      parse: (_) => null,
    );
  }
}
