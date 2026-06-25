import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widgets/course_card.dart';
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
      appBar: AppBar(title: const Text('Khoa hoc cua toi')),
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
                title: 'Chua co khoa hoc dang hoc',
                message: 'Dang ky khoa hoc mien phi de bat dau hoc.',
                icon: Icons.school_outlined,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(myEnrollmentsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: courses.length,
                itemBuilder: (context, index) => CourseCard(
                  course: courses[index],
                  owned: true,
                  onTap: () =>
                      context.push(RouteNames.courseLearn(courses[index].id)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
