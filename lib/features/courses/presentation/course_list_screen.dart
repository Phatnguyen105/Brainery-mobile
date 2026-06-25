import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/widgets/course_card.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../data/course_models.dart';
import 'course_controller.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({this.initialCategoryId, super.key});

  final String? initialCategoryId;

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _keyword = TextEditingController();
  String? _categoryId;
  String? _level;
  bool _freeOnly = false;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    Future.microtask(() {
      ref
          .read(courseListControllerProvider.notifier)
          .search(
            categoryId: _categoryId,
            keyword: _keyword.text.trim(),
            level: _level,
            minPrice: _freeOnly ? 0 : null,
            maxPrice: _freeOnly ? 0 : null,
          );
    });
  }

  @override
  void dispose() {
    _keyword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(courseListControllerProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.hasValue
        ? categoriesAsync.requireValue
        : const <CategoryModel>[];

    return Scaffold(
      appBar: AppBar(title: const Text('Khoa hoc')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  TextField(
                    controller: _keyword,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _applyFilters(),
                    decoration: InputDecoration(
                      hintText: 'Tim theo tu khoa',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.tune),
                        onPressed: _applyFilters,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _categoryId?.isEmpty == true
                                ? null
                                : _categoryId,
                            hint: const Text('Danh muc'),
                            items: categories
                                .map(
                                  (item) => DropdownMenuItem(
                                    value: item.id,
                                    child: Text(item.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _categoryId = value);
                              _applyFilters();
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _level,
                            hint: const Text('Trinh do'),
                            items: const [
                              DropdownMenuItem(
                                value: 'BEGINNER',
                                child: Text('Co ban'),
                              ),
                              DropdownMenuItem(
                                value: 'INTERMEDIATE',
                                child: Text('Trung cap'),
                              ),
                              DropdownMenuItem(
                                value: 'ADVANCED',
                                child: Text('Nang cao'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() => _level = value);
                              _applyFilters();
                            },
                          ),
                        ),
                        const SizedBox(width: 14),
                        FilterChip(
                          label: const Text('Mien phi'),
                          selected: _freeOnly,
                          onSelected: (value) {
                            setState(() => _freeOnly = value);
                            _applyFilters();
                          },
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Xoa loc'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: courses.when(
                data: (state) {
                  if (state.courses.isEmpty) {
                    return const EmptyView(
                      title: 'Khong co khoa hoc phu hop',
                      message: 'Thu thay doi tu khoa hoac bo loc.',
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () => ref
                        .read(courseListControllerProvider.notifier)
                        .refresh(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: state.courses.length + (state.last ? 0 : 1),
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == state.courses.length) {
                          return OutlinedButton.icon(
                            onPressed: () => ref
                                .read(courseListControllerProvider.notifier)
                                .loadMore(),
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Tai them'),
                          );
                        }
                        final course = state.courses[index];
                        return CourseCard(
                          course: course,
                          onTap: () =>
                              context.push(RouteNames.courseDetail(course.id)),
                        );
                      },
                    ),
                  );
                },
                error: (error, _) => ErrorView(
                  message: error.toString(),
                  onRetry: () => ref.invalidate(courseListControllerProvider),
                ),
                loading: () => const LoadingView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyFilters() {
    ref
        .read(courseListControllerProvider.notifier)
        .search(
          keyword: _keyword.text.trim(),
          categoryId: _categoryId,
          level: _level,
          minPrice: _freeOnly ? 0 : null,
          maxPrice: _freeOnly ? 0 : null,
        );
  }

  void _clearFilters() {
    setState(() {
      _keyword.clear();
      _categoryId = null;
      _level = null;
      _freeOnly = false;
    });
    ref
        .read(courseListControllerProvider.notifier)
        .search(keyword: '', categoryId: '', level: '');
  }
}
