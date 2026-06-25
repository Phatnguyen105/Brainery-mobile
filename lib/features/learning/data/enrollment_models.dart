import '../../courses/data/course_models.dart';

class EnrollmentStatusModel {
  const EnrollmentStatusModel({
    required this.courseId,
    this.status,
    this.progress = 0,
    this.enrolledAt,
  });

  final String courseId;
  final String? status;
  final double progress;
  final String? enrolledAt;

  bool get isEnrolled => status != null && status!.isNotEmpty;

  factory EnrollmentStatusModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return EnrollmentStatusModel(
      courseId: map['courseId']?.toString() ?? '',
      status: map['status']?.toString(),
      progress: double.tryParse(map['progress']?.toString() ?? '') ?? 0,
      enrolledAt: map['enrolledAt']?.toString(),
    );
  }
}

class EnrollmentResult {
  const EnrollmentResult({
    required this.id,
    required this.courseId,
    required this.status,
  });

  final String id;
  final String courseId;
  final String status;

  factory EnrollmentResult.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return EnrollmentResult(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      status: map['status']?.toString() ?? 'ACTIVE',
    );
  }
}

typedef EnrolledCourse = CourseSummary;
