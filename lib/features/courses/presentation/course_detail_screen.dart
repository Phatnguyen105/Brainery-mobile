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
import '../../auth/presentation/auth_controller.dart';
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
        SliverToBoxAdapter(
          child: _ReviewsSection(
            courseId: course.id,
            isEnrolled: isEnrolled,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
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

class _ReviewsSection extends ConsumerWidget {
  const _ReviewsSection({
    required this.courseId,
    required this.isEnrolled,
  });

  final String courseId;
  final bool isEnrolled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(courseReviewsProvider(courseId));
    final auth = ref.watch(authControllerProvider);
    final currentUserEmail = auth.value?.email;
    final reviewActionLoading = ref.watch(reviewActionProvider).isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Danh gia tu hoc vien',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          reviewsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Loi tai danh gia: $error'),
            data: (page) {
              final reviews = page.content;
              final existingReview = currentUserEmail == null
                  ? null
                  : reviews.where((r) => r.userEmail.toLowerCase() == currentUserEmail.toLowerCase()).firstOrNull;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Review Stats Summary
                  if (reviews.isNotEmpty) ...[
                    _buildStatsSummary(context, reviews),
                    const SizedBox(height: 20),
                  ],

                  // Action for enrolled user
                  if (isEnrolled && currentUserEmail != null) ...[
                    if (existingReview == null) ...[
                      Center(
                        child: OutlinedButton.icon(
                          onPressed: reviewActionLoading
                              ? null
                              : () => _showReviewDialog(context, ref, courseId: courseId),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Viet danh gia cho khoa hoc nay'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Danh gia cua ban:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReviewCard(context, ref, existingReview, isCurrentUser: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],

                  // Reviews List
                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Chua co danh gia nao cho khoa hoc nay. Hay la nguoi dau tien danh gia!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        // Skip if it's the current user's review as we displayed it separately above
                        if (existingReview != null && review.id == existingReview.id) {
                          return const SizedBox.shrink();
                        }
                        return _buildReviewCard(context, ref, review, isCurrentUser: false);
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, List<ReviewModel> reviews) {
    final double avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              avg.toStringAsFixed(1),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < avg.round() ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${reviews.length} xep hang',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    BuildContext context,
    WidgetRef ref,
    ReviewModel review, {
    required bool isCurrentUser,
  }) {
    final dateStr = DateFormat('dd/MM/yyyy').format(review.createdAt);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.line,
                  child: Text(
                    review.userEmail.isNotEmpty
                        ? review.userEmail.characters.first.toUpperCase()
                        : 'B',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userEmail.split('@').first,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dateStr,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            if (isCurrentUser)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                    onPressed: () => _showReviewDialog(
                      context,
                      ref,
                      courseId: courseId,
                      existingReview: review,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    onPressed: () => _showDeleteConfirmation(context, ref, review),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ),
        if (review.content.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(review.content, style: const TextStyle(height: 1.4)),
        ],
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa danh gia'),
        content: const Text('Ban co chac chan muon xoa danh gia nay khong?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(reviewActionProvider.notifier).deleteReview(courseId, review.id);
            },
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }
}

void _showReviewDialog(
  BuildContext context,
  WidgetRef ref, {
  required String courseId,
  ReviewModel? existingReview,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return _ReviewSubmitBottomSheet(
        courseId: courseId,
        existingReview: existingReview,
      );
    },
  );
}

class _ReviewSubmitBottomSheet extends ConsumerStatefulWidget {
  const _ReviewSubmitBottomSheet({
    required this.courseId,
    this.existingReview,
  });

  final String courseId;
  final ReviewModel? existingReview;

  @override
  ConsumerState<_ReviewSubmitBottomSheet> createState() => _ReviewSubmitBottomSheetState();
}

class _ReviewSubmitBottomSheetState extends ConsumerState<_ReviewSubmitBottomSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingReview != null) {
      _rating = widget.existingReview!.rating;
      _commentController.text = widget.existingReview!.content;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(reviewActionProvider).isLoading;
    final isEdit = widget.existingReview != null;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? 'Chinh sua danh gia' : 'Danh gia khoa hoc',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Star rating Row selector
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final score = index + 1;
                return IconButton(
                  icon: Icon(
                    score <= _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                  onPressed: isLoading
                      ? null
                      : () {
                          setState(() {
                            _rating = score;
                          });
                        },
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          // Comment box
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Hay chia se cam nghi cua ban ve khoa hoc nay...',
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Submit Button
          AppButton(
            label: isEdit ? 'Cap nhat' : 'Gui danh gia',
            isLoading: isLoading,
            onPressed: () async {
              if (isEdit) {
                await ref.read(reviewActionProvider.notifier).updateReview(
                      widget.courseId,
                      widget.existingReview!.id,
                      rating: _rating,
                      content: _commentController.text.trim(),
                    );
              } else {
                await ref.read(reviewActionProvider.notifier).createReview(
                      widget.courseId,
                      rating: _rating,
                      content: _commentController.text.trim(),
                    );
              }
              final state = ref.read(reviewActionProvider);
              if (state.hasError) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.error.toString())),
                  );
                }
              } else {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isEdit ? 'Cap nhat thanh cong!' : 'Gui danh gia thanh cong! Cam on ban.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
