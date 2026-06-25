import '../../../core/network/api_client.dart';
import '../../courses/data/course_models.dart';
import 'enrollment_models.dart';

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
}
