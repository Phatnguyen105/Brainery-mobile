import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../courses/presentation/course_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final user = auth.hasValue ? auth.requireValue : null;
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredCoursesProvider);
    final courses = ref.watch(courseListControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredCoursesProvider);
            await ref.read(courseListControllerProvider.notifier).refresh();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, ${user?.fullName.split(' ').first ?? 'ban'}',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      const Text('Tim khoa hoc tot nhat de hoc hom nay.'),
                      if (user?.isAdmin ?? false) ...[
                        const SizedBox(height: 14),
                        _AdminShortcut(
                          onTap: () => context.go(RouteNames.admin),
                        ),
                      ],
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => context.push(RouteNames.courses),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.line),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 10),
                              Text('Tim kiem khoa hoc, ky nang, giang vien'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Danh muc',
                        action: 'Xem tat ca',
                        onTap: () => context.push(RouteNames.courses),
                      ),
                      const SizedBox(height: 10),
                      categories.when(
                        data: (items) => items.isEmpty
                            ? const _InlineEmpty(
                                icon: Icons.category_outlined,
                                text: 'Backend chua co danh muc.',
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
                                    onPressed: () => context.push(
                                      '${RouteNames.courses}?categoryId=${items[index].id}',
                                    ),
                                  ),
                                ),
                              ),
                        error: (_, _) => const Text('Chua tai duoc danh muc.'),
                        loading: () => const SizedBox(
                          height: 42,
                          child: LinearProgressIndicator(),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _SectionTitle(
                        title: 'Noi bat',
                        action: 'Xem them',
                        onTap: () => context.push(RouteNames.courses),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: featured.when(
                  data: (items) => items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _InlineEmpty(
                            icon: Icons.star_outline,
                            text: 'Backend chua co khoa hoc noi bat.',
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
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) => CourseCard(
                              course: items[index],
                              compact: true,
                              onTap: () => context.push(
                                RouteNames.courseDetail(items[index].id),
                              ),
                            ),
                          ),
                        ),
                  error: (error, _) => ErrorView(message: error.toString()),
                  loading: () =>
                      const SizedBox(height: 180, child: LoadingView()),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
                  child: _SectionTitle(
                    title: 'Pho bien',
                    action: 'Tat ca',
                    onTap: () => context.push(RouteNames.courses),
                  ),
                ),
              ),
              courses.when(
                data: (state) => state.courses.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: _InlineEmpty(
                            icon: Icons.menu_book_outlined,
                            text: 'Backend chua co khoa hoc published.',
                          ),
                        ),
                      )
                    : SliverList.separated(
                        itemCount: state.courses.take(5).length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CourseCard(
                            course: state.courses[index],
                            onTap: () => context.push(
                              RouteNames.courseDetail(state.courses[index].id),
                            ),
                          ),
                        ),
                      ),
                error: (error, _) => SliverToBoxAdapter(
                  child: ErrorView(
                    message: error.toString(),
                    onRetry: () => ref.invalidate(courseListControllerProvider),
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
      borderRadius: BorderRadius.circular(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vao khu vuc quan tri',
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
        borderRadius: BorderRadius.circular(8),
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
