import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import 'enrollment_controller.dart';

class MyLearningScreen extends ConsumerWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollments = ref.watch(myEnrollmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Khóa học của tôi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
      ),
      body: SafeArea(
        child: enrollments.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(myEnrollmentsProvider),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return const EmptyView(
                title: 'Chưa có khóa học đang học',
                message: 'Đăng ký khóa học miễn phí để bắt đầu học ngay thôi!',
                icon: Icons.school_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myEnrollmentsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return _EnrolledCourseCard(courseId: course.id, course: course);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EnrolledCourseCard extends ConsumerWidget {
  const _EnrolledCourseCard({
    required this.courseId,
    required this.course,
  });

  final String courseId;
  final dynamic course; // CourseSummary

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(enrollmentStatusProvider(courseId));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner/Thumbnail Area
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: course.courseImageUrl != null &&
                          course.courseImageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: course.courseImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Container(
                            color: AppColors.line,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (_, _, _) => Container(
                            color: AppColors.primary,
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ),
                // Level Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatLevel(course.level),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Information Area
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.muted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          course.instructorName ?? 'Brainery Instructor',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Progress Loading / Display
                  statusAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (err, _) => Text(
                      'Lỗi tải tiến độ',
                      style: TextStyle(color: Colors.red[300], fontSize: 13),
                    ),
                    data: (status) {
                      final progressPercent = status.progress;
                      final isFinished = progressPercent >= 100.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Progress Bar header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isFinished ? 'Đã hoàn thành' : 'Đang tiến hành',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isFinished
                                      ? AppColors.primary
                                      : AppColors.accent,
                                ),
                              ),
                              Text(
                                '${progressPercent.toStringAsFixed(0)}% hoàn thành',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Premium Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100.0,
                              minHeight: 8,
                              backgroundColor: AppColors.line,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isFinished ? AppColors.primary : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Resume Study Area
                          if (status.lastLessonTitle != null) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.line),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.play_circle_filled,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Học dở phần:',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.muted,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          status.lastLessonTitle!,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          // Continue learning Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final resumeId = status.lastLessonId;
                                final path = resumeId != null
                                    ? '${RouteNames.courseLearn(courseId)}?lessonId=$resumeId'
                                    : RouteNames.courseLearn(courseId);
                                context.push(path);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0.5,
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                              label: const Text(
                                'Tiếp tục học',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatLevel(String level) {
  switch (level.toUpperCase()) {
    case 'BEGINNER':
      return 'Cơ bản';
    case 'INTERMEDIATE':
      return 'Trung cấp';
    case 'ADVANCED':
      return 'Nâng cao';
    default:
      return level;
  }
}
