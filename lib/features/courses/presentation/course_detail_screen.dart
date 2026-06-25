import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../cart/presentation/cart_controller.dart';
import '../../learning/presentation/enrollment_controller.dart';
import '../../orders/presentation/order_controller.dart';
import '../../wishlist/presentation/wishlist_controller.dart';
import '../data/course_models.dart';
import 'course_controller.dart';

class CourseDetailScreen extends ConsumerWidget {
  const CourseDetailScreen({required this.courseId, super.key});

  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(courseDetailProvider(courseId));

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiet khoa hoc')),
      body: SafeArea(
        child: detail.when(
          data: (course) => _CourseDetailContent(course: course),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(courseDetailProvider(courseId)),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}

class _CourseDetailContent extends ConsumerWidget {
  const _CourseDetailContent({required this.course});

  final CourseDetail course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'd');
    final cartLoading = ref.watch(cartControllerProvider).isLoading;
    final orderLoading = ref.watch(orderControllerProvider).isLoading;
    final enrollmentStatus = ref.watch(enrollmentStatusProvider(course.id));
    final enrollmentLoading = ref.watch(enrollmentActionProvider).isLoading;
    final isEnrolled =
        enrollmentStatus.hasValue && enrollmentStatus.requireValue.isEnrolled;
    final wishlistState = ref.watch(wishlistControllerProvider);
    final wishlistLoading = wishlistState.isLoading;
    final isWishlisted =
        wishlistState.hasValue &&
        wishlistState.requireValue.any((item) => item.id == course.id);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child:
                    course.courseImageUrl == null ||
                        course.courseImageUrl!.isEmpty
                    ? Container(
                        color: AppColors.primary,
                        child: const Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 56,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: course.courseImageUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.primary,
                          child: const Icon(Icons.school, color: Colors.white),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(label: _formatLevel(course.level)),
                        if (course.isFeatured) const _Pill(label: 'Noi bat'),
                        if (course.isFree) const _Pill(label: 'Mien phi'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      course.description?.isNotEmpty == true
                          ? course.description!
                          : 'Mo ta khoa hoc se duoc cap nhat tu backend.',
                      style: const TextStyle(height: 1.45),
                    ),
                    const SizedBox(height: 14),
                    if (course.tags.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: course.tags
                            .map((tag) => Chip(label: Text(tag.name)))
                            .toList(),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      isEnrolled
                          ? 'Da so huu'
                          : course.isFree
                          ? 'Mien phi'
                          : formatter.format(course.price),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: isEnrolled
                                ? 'Vao hoc'
                                : (course.isFree ? 'Dang ky ngay' : 'Them vao gio hang'),
                            icon: isEnrolled
                                ? Icons.play_circle_outline
                                : (course.isFree
                                      ? Icons.school_outlined
                                      : Icons.shopping_cart_outlined),
                            isLoading: isEnrolled
                                ? false
                                : (course.isFree
                                      ? enrollmentLoading ||
                                            enrollmentStatus.isLoading
                                      : cartLoading),
                            onPressed: isEnrolled
                                ? () => context.push(RouteNames.courseLearn(course.id))
                                : (course.isFree
                                      ? () => _enroll(context, ref)
                                      : () => _addToCart(context, ref)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.outlined(
                          tooltip: isWishlisted
                              ? 'Xoa khoi wishlist'
                              : 'Them vao wishlist',
                          onPressed: wishlistLoading
                              ? null
                              : () => _toggleWishlist(
                                  context,
                                  ref,
                                  isWishlisted: isWishlisted,
                                ),
                          icon: wishlistLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: isWishlisted ? Colors.red : null,
                                ),
                        ),
                      ],
                    ),
                    if (!course.isFree && !isEnrolled) ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: cartLoading || orderLoading
                            ? null
                            : () => _buyNow(context, ref),
                        icon: orderLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.flash_on_outlined),
                        label: const Text('Mua ngay'),
                      ),
                    ],
                    const SizedBox(height: 26),
                    Text(
                      'Noi dung khoa hoc',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (course.sections.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Text(
                'Backend chua tra ve section/lesson cho khoa hoc nay.',
              ),
            ),
          )
        else
          SliverList.builder(
            itemCount: course.sections.length,
            itemBuilder: (context, index) =>
                _SectionTile(
                  section: course.sections[index],
                  index: index,
                  isEnrolled: isEnrolled,
                  courseId: course.id,
                ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Future<void> _addToCart(BuildContext context, WidgetRef ref) async {
    await ref.read(cartControllerProvider.notifier).addItem(course.id);
    final state = ref.read(cartControllerProvider);
    if (!context.mounted) return;
    state.whenOrNull(
      data: (_) => _showMessage(context, 'Da them khoa hoc vao gio hang.'),
      error: (error, _) => _showMessage(context, error.toString()),
    );
  }

  Future<void> _buyNow(BuildContext context, WidgetRef ref) async {
    await ref.read(cartControllerProvider.notifier).addItem(course.id);
    final cartState = ref.read(cartControllerProvider);
    if (!context.mounted) return;
    if (cartState.hasError) {
      _showMessage(context, cartState.error.toString());
      return;
    }

    final order = await ref.read(orderControllerProvider.notifier).checkout();
    if (!context.mounted) return;
    final orderState = ref.read(orderControllerProvider);
    if (orderState.hasError) {
      _showMessage(context, orderState.error.toString());
      return;
    }

    if (order == null) {
      context.push(RouteNames.orders);
      return;
    }
    context.push(RouteNames.payment(order.id), extra: order);
  }

  Future<void> _enroll(BuildContext context, WidgetRef ref) async {
    await ref.read(enrollmentActionProvider.notifier).enroll(course.id);
    final state = ref.read(enrollmentActionProvider);
    if (!context.mounted) return;
    state.whenOrNull(
      data: (_) => _showMessage(context, 'Da dang ky khoa hoc.'),
      error: (error, _) => _showMessage(context, error.toString()),
    );
  }

  Future<void> _toggleWishlist(
    BuildContext context,
    WidgetRef ref, {
    required bool isWishlisted,
  }) async {
    if (isWishlisted) {
      await ref.read(wishlistControllerProvider.notifier).remove(course.id);
    } else {
      await ref.read(wishlistControllerProvider.notifier).add(course.id);
    }
    final state = ref.read(wishlistControllerProvider);
    if (!context.mounted) return;
    state.whenOrNull(
      data: (_) => _showMessage(
        context,
        isWishlisted
            ? 'Da xoa khoa hoc khoi wishlist.'
            : 'Da them khoa hoc vao wishlist.',
      ),
      error: (error, _) => _showMessage(context, error.toString()),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.index,
    required this.isEnrolled,
    required this.courseId,
  });

  final CourseSectionModel section;
  final int index;
  final bool isEnrolled;
  final String courseId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              '${index + 1}. ${section.title}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text('${section.lessons.length} bai hoc'),
            children: section.lessons
                .map(
                  (lesson) {
                    final hasAccess = isEnrolled || lesson.isPreview || lesson.fullAccess;
                    return ListTile(
                      leading: Icon(
                        !hasAccess
                            ? Icons.lock_outline
                            : (lesson.lessonType == 'Video'
                                ? Icons.play_circle_outline
                                : (lesson.lessonType == 'Quiz'
                                    ? Icons.quiz_outlined
                                    : Icons.article_outlined)),
                      ),
                      title: Text(lesson.title),
                      subtitle: Text(lesson.lessonType == 'Lesson' || lesson.lessonType == null ? 'Bai hoc' : (lesson.lessonType == 'Video' ? 'Video' : lesson.lessonType!)),
                      trailing: lesson.isPreview ? const Text('Xem thu') : null,
                      onTap: () {
                        if (!hasAccess) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ban can mua khoa hoc de hoc bai nay.'),
                            ),
                          );
                        } else {
                          context.push(RouteNames.courseLearn(courseId));
                        }
                      },
                    );
                  },
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _formatLevel(String level) {
  switch (level.toUpperCase()) {
    case 'BEGINNER':
      return 'Co ban';
    case 'INTERMEDIATE':
      return 'Trung cap';
    case 'ADVANCED':
      return 'Nang cao';
    default:
      return level;
  }
}
