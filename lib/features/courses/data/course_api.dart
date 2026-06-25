import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import 'course_models.dart';

class CourseApi {
  const CourseApi(this._client);

  final ApiClient _client;

  Future<PageResult<CourseSummary>> searchCourses({
    String? keyword,
    String? categoryId,
    String? level,
    double? minPrice,
    double? maxPrice,
    int page = 0,
    int size = 10,
  }) {
    return _client.getData<PageResult<CourseSummary>>(
      ApiConstants.courses,
      queryParameters: {
        'keyword': keyword,
        'categoryId': categoryId,
        'level': level,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'page': page,
        'size': size,
      }..removeWhere((_, value) => value == null || value == ''),
      parse: (json) => PageResult.fromJson(json, CourseSummary.fromJson),
    );
  }

  Future<List<CourseSummary>> featuredCourses() {
    return _client.getData<List<CourseSummary>>(
      ApiConstants.featuredCourses,
      parse: (json) =>
          (json is List ? json : const []).map(CourseSummary.fromJson).toList(),
    );
  }

  Future<CourseDetail> findCourse(String courseId) {
    return _client.getData<CourseDetail>(
      ApiConstants.courseDetail(courseId),
      parse: CourseDetail.fromJson,
    );
  }

  Future<List<CategoryModel>> categories() {
    return _client.getData<List<CategoryModel>>(
      ApiConstants.categories,
      parse: (json) =>
          (json is List ? json : const []).map(CategoryModel.fromJson).toList(),
    );
  }
}
