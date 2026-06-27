import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.hasValue ? auth.requireValue : null;
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredCoursesProvider);
    final bestSellers = ref.watch(bestSellerCoursesProvider);
    final topRated = ref.watch(topRatedCoursesProvider);
    final newCourses = ref.watch(newCoursesProvider);
    final popular = ref.watch(popularCoursesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredCoursesProvider);
            ref.invalidate(bestSellerCoursesProvider);
            ref.invalidate(topRatedCoursesProvider);
            ref.invalidate(newCoursesProvider);
            ref.invalidate(popularCoursesProvider);
            await ref.read(courseListControllerProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, ${user?.fullName.split(' ').first ?? 'bạn'} 👋',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Tìm khóa học tốt nhất để học hôm nay.',
                              style: TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                            const SizedBox(height: 18),
                            InkWell(
                              onTap: () => context.push(RouteNames.courses),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.search, color: AppColors.primary),
                                    SizedBox(width: 10),
                                    Text(
                                      'Tìm kiếm khóa học, kỹ năng, giảng viên',
                                      style: TextStyle(color: AppColors.muted, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (user?.isAdmin ?? false) ...[
                        const SizedBox(height: 16),
                        _AdminShortcut(
                          onTap: () => context.go(RouteNames.admin),
                        ),
                      ],
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Danh mục',
                        action: 'Xem tất cả',
                        onTap: () => context.push(RouteNames.courses),
                      ),
                      const SizedBox(height: 10),
                      categories.when(
                        data: (items) => items.isEmpty
                            ? const _InlineEmpty(
                                icon: Icons.category_outlined,
                                text: 'Hệ thống chưa có danh mục.',
                              )
                            : SizedBox(
                                height: 46,
                                child: ListView.separated(
                                  padding: const EdgeInsets.only(right: 20),
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  primary: false,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(width: 8),
                                  itemBuilder: (context, index) => ActionChip(
                                    label: Text(items[index].name),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    onPressed: () => context.push(
                                      '${RouteNames.courses}?categoryId=${items[index].id}',
                                    ),
                                  ),
                                ),
                              ),
                        error: (_, _) => const Text('Chưa tải được danh mục.'),
                        loading: () => const SizedBox(
                          height: 42,
                          child: LinearProgressIndicator(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Nổi bật',
                        action: 'Xem thêm',
                        onTap: () => context.push(RouteNames.courses),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HorizontalCourseList(
                  coursesAsync: featured,
                  emptyText: 'Backend chua co khoa hoc noi bat.',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: _SectionTitle(
                    title: 'Mua nhiều nhất',
                    action: 'Xem thêm',
                    onTap: () => context.push('${RouteNames.courses}?sort=best_seller'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HorizontalCourseList(
                  coursesAsync: bestSellers,
                  emptyText: 'Chưa có khóa học bán chạy.',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: _SectionTitle(
                    title: 'Đánh giá cao nhất',
                    action: 'Xem thêm',
                    onTap: () => context.push('${RouteNames.courses}?sort=rating'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HorizontalCourseList(
                  coursesAsync: topRated,
                  emptyText: 'Chưa có khóa học đánh giá cao.',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
                  child: _SectionTitle(
                    title: 'Khóa học mới',
                    action: 'Xem thêm',
                    onTap: () => context.push('${RouteNames.courses}?sort=newest'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _HorizontalCourseList(
                  coursesAsync: newCourses,
                  emptyText: 'Chưa có khóa học mới.',
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: _SectionTitle(
                    title: 'Phổ biến nhất',
                    action: 'Tất cả',
                    onTap: () => context.push('${RouteNames.courses}?sort=popular'),
                  ),
                ),
              ),
              popular.when(
                data: (items) => items.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _InlineEmpty(
                            icon: Icons.menu_book_outlined,
                            text: 'Chưa có khóa học phổ biến.',
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: items.take(5).length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CourseCard(
                            course: items[index],
                            onTap: () => context.push(
                              RouteNames.courseDetail(items[index].id),
                            ),
                          ),
                        ),
                      ),
                error: (error, _) => SliverToBoxAdapter(
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(popularCoursesProvider),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(child: LoadingView()),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminShortcut extends StatelessWidget {
  const _AdminShortcut({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vào khu vực quản trị',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.muted),
            const SizedBox(width: 8),
            Flexible(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.action,
    required this.onTap,
  });

  final String title;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onTap, child: Text(action)),
      ],
    );
  }
}

class _HorizontalCourseList extends StatelessWidget {
  const _HorizontalCourseList({
    required this.coursesAsync,
    required this.emptyText,
  });

  final AsyncValue<List<CourseSummary>> coursesAsync;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return coursesAsync.when(
      data: (items) => items.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _InlineEmpty(
                icon: Icons.star_outline,
                text: emptyText,
              ),
            )
          : SizedBox(
              height: 310,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const AlwaysScrollableScrollPhysics(),
                primary: false,
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) => CourseCard(
                  course: items[index],
                  compact: true,
                  onTap: () => context.push(
                    RouteNames.courseDetail(items[index].id),
                  ),
                ),
              ),
            ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ErrorView(message: error.toString()),
      ),
      loading: () => const SizedBox(height: 180, child: LoadingView()),
    );
  }
}
