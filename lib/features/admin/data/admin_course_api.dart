import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';

class AdminCourseApi {
  const AdminCourseApi(this._client);

  final ApiClient _client;

  Future<List<CourseSummary>> listCourses({String? status}) {
    return _client.getData<List<CourseSummary>>(
      '/api/admin/courses',
      queryParameters: {'status': status, 'size': 50}
        ..removeWhere((_, value) => value == null || value == ''),
      parse: (json) {
        final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
        final content = map['content'] as List<dynamic>? ?? const [];
        return content.map(CourseSummary.fromJson).toList();
      },
    );
  }

  Future<CourseDetail> createCourse({
    required String categoryId,
    required String title,
    required String slug,
    required String level,
    required double price,
    required String status,
    required bool isFeatured,
    String? description,
    String? imageUrl,
  }) {
    return _client.postData<CourseDetail>(
      '/api/admin/courses',
      data: {
        'categoryId': categoryId,
        'title': title,
        'slug': slug,
        'description': description,
        'level': level,
        'price': price,
        'courseImageUrl': imageUrl,
        'status': status,
        'isFeatured': isFeatured,
      },
      parse: CourseDetail.fromJson,
    );
  }

  Future<CourseDetail> publish(String courseId) {
    return _client.patchData<CourseDetail>(
      '/api/admin/courses/$courseId/publish',
      parse: CourseDetail.fromJson,
    );
  }

  Future<CourseDetail> archive(String courseId) {
    return _client.patchData<CourseDetail>(
      '/api/admin/courses/$courseId/archive',
      parse: CourseDetail.fromJson,
    );
  }
}
