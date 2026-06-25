import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';

class AdminContentApi {
  const AdminContentApi(this._client);

  final ApiClient _client;

  Future<CourseDetail> findCourse(String courseId) {
    return _client.getData<CourseDetail>(
      ApiConstants.courseDetail(courseId),
      parse: CourseDetail.fromJson,
    );
  }

  Future<CourseSectionModel> createSection({
    required String courseId,
    required String title,
    required int sortOrder,
  }) {
    return _client.postData<CourseSectionModel>(
      '/api/admin/courses/$courseId/sections',
      data: {'title': title, 'sortOrder': sortOrder},
      parse: CourseSectionModel.fromJson,
    );
  }

  Future<CourseSectionModel> updateSection({
    required String sectionId,
    required String title,
    required int sortOrder,
  }) {
    return _client.putData<CourseSectionModel>(
      '/api/admin/sections/$sectionId',
      data: {'title': title, 'sortOrder': sortOrder},
      parse: CourseSectionModel.fromJson,
    );
  }

  Future<void> deleteSection(String sectionId) async {
    await _client.deleteData<Object?>(
      '/api/admin/sections/$sectionId',
      parse: (_) => null,
    );
  }

  Future<LessonModel> createLesson({
    required String sectionId,
    required String title,
    required int sortOrder,
    required String lessonType,
    required bool isPreview,
    String? videoUrl,
    String? content,
  }) {
    return _client.postData<LessonModel>(
      '/api/admin/sections/$sectionId/lessons',
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

  Future<LessonModel> updateLesson({
    required String lessonId,
    required String title,
    required int sortOrder,
    required String lessonType,
    required bool isPreview,
    String? videoUrl,
    String? content,
  }) {
    return _client.putData<LessonModel>(
      '/api/admin/lessons/$lessonId',
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

  Future<void> deleteLesson(String lessonId) async {
    await _client.deleteData<Object?>(
      '/api/admin/lessons/$lessonId',
      parse: (_) => null,
    );
  }
}
