import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import 'wishlist_controller.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yeu thich')),
      body: SafeArea(
        child: wishlist.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyView(
                title: 'Danh sach yeu thich trong',
                message: 'Bam trai tim trong chi tiet khoa hoc de luu lai.',
                icon: Icons.favorite_outline,
              );
            }
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(wishlistControllerProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final course = items[index];
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 44),
                        child: CourseCard(
                          course: course,
                          onTap: () =>
                              context.push(RouteNames.courseDetail(course.id)),
                        ),
                      ),
                      IconButton.outlined(
                        tooltip: 'Xoa khoi danh sach yeu thich',
                        onPressed: () => ref
                            .read(wishlistControllerProvider.notifier)
                            .remove(course.id),
                        icon: const Icon(Icons.favorite),
                      ),
                    ],
                  );
                },
              ),
            );
          },
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(wishlistControllerProvider),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}
