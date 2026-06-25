import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../courses/data/course_models.dart';
import '../data/enrollment_api.dart';
import '../data/enrollment_models.dart';

final enrollmentApiProvider = Provider<EnrollmentApi>((ref) {
  return EnrollmentApi(ref.watch(apiClientProvider));
});

final enrollmentStatusProvider =
    FutureProvider.family<EnrollmentStatusModel, String>((ref, courseId) {
      return ref.watch(enrollmentApiProvider).status(courseId);
    });

final myEnrollmentsProvider = FutureProvider<List<CourseSummary>>((ref) async {
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
}
