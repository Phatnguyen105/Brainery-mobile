import 'package:brainery_mobile/core/network/api_response.dart';
import 'package:brainery_mobile/features/courses/data/course_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CourseSummary parses backend json safely', () {
    final course = CourseSummary.fromJson({
      'id': 'course-1',
      'title': 'Flutter for Students',
      'level': 'BEGINNER',
      'price': '199000',
      'instructorName': 'Brainery',
      'averageRating': '4.7',
      'totalReviews': 12,
      'isFeatured': true,
    });

    expect(course.id, 'course-1');
    expect(course.title, 'Flutter for Students');
    expect(course.price, 199000);
    expect(course.averageRating, 4.7);
    expect(course.isFeatured, isTrue);
  });

  test('ApiResponse parses code message data format', () {
    final response = ApiResponse.fromJson<int>(
      {'code': 'SUCCESS', 'message': 'OK', 'data': 5},
      (json) => json as int,
    );

    expect(response.code, 'SUCCESS');
    expect(response.message, 'OK');
    expect(response.data, 5);
  });
}
