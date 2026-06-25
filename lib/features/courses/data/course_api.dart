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
    String? sort,
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
        'sort': sort,
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

  Future<PageResult<ReviewModel>> findCourseReviews(
    String courseId, {
    int page = 0,
    int size = 10,
  }) {
    return _client.getData<PageResult<ReviewModel>>(
      ApiConstants.courseReviews(courseId),
      queryParameters: {
        'page': page,
        'size': size,
      },
      parse: (json) => PageResult.fromJson(json, ReviewModel.fromJson),
    );
  }

  Future<ReviewModel> createReview(
    String courseId, {
    required int rating,
    required String content,
  }) {
    return _client.postData<ReviewModel>(
      ApiConstants.courseReviews(courseId),
      data: {
        'rating': rating,
        'content': content,
      },
      parse: ReviewModel.fromJson,
    );
  }

  Future<ReviewModel> updateReview(
    String reviewId, {
    required int rating,
    required String content,
  }) {
    return _client.putData<ReviewModel>(
      ApiConstants.reviewAction(reviewId),
      data: {
        'rating': rating,
        'content': content,
      },
      parse: ReviewModel.fromJson,
    );
  }

  Future<void> deleteReview(String reviewId) {
    return _client.deleteData<void>(
      ApiConstants.reviewAction(reviewId),
      parse: (_) {},
    );
  }
}
