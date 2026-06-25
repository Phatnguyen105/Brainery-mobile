import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../data/course_api.dart';
import '../data/course_models.dart';

final courseApiProvider = Provider<CourseApi>((ref) {
  return CourseApi(ref.watch(apiClientProvider));
});

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) {
  return ref.watch(courseApiProvider).categories();
});

final featuredCoursesProvider = FutureProvider<List<CourseSummary>>((ref) {
  return ref.watch(courseApiProvider).featuredCourses();
});

final courseDetailProvider = FutureProvider.family<CourseDetail, String>((
  ref,
  courseId,
) {
  return ref.watch(courseApiProvider).findCourse(courseId);
});

final courseListControllerProvider =
    AsyncNotifierProvider<CourseListController, CourseListState>(
      CourseListController.new,
    );

class CourseListState {
  const CourseListState({
    required this.courses,
    this.keyword,
    this.categoryId,
    this.level,
    this.minPrice,
    this.maxPrice,
    this.page = 0,
    this.last = false,
  });

  final List<CourseSummary> courses;
  final String? keyword;
  final String? categoryId;
  final String? level;
  final double? minPrice;
  final double? maxPrice;
  final int page;
  final bool last;

  CourseListState copyWith({
    List<CourseSummary>? courses,
    String? keyword,
    String? categoryId,
    String? level,
    double? minPrice,
    double? maxPrice,
    int? page,
    bool? last,
    bool clearCategory = false,
    bool clearLevel = false,
    bool clearPrice = false,
  }) {
    return CourseListState(
      courses: courses ?? this.courses,
      keyword: keyword ?? this.keyword,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      level: clearLevel ? null : level ?? this.level,
      minPrice: clearPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearPrice ? null : maxPrice ?? this.maxPrice,
      page: page ?? this.page,
      last: last ?? this.last,
    );
  }
}

class CourseListController extends AsyncNotifier<CourseListState> {
  @override
  Future<CourseListState> build() async {
    final page = await _fetch();
    return CourseListState(courses: page.content, last: page.last);
  }

  Future<void> search({
    String? keyword,
    String? categoryId,
    String? level,
    double? minPrice,
    double? maxPrice,
  }) async {
    final current = state.hasValue
        ? state.requireValue
        : const CourseListState(courses: []);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final next = current.copyWith(
        keyword: keyword,
        categoryId: categoryId,
        level: level,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: 0,
        clearCategory: categoryId == '',
        clearLevel: level == '',
        clearPrice: minPrice == null && maxPrice == null,
      );
      final page = await _fetch(
        keyword: next.keyword,
        categoryId: next.categoryId,
        level: next.level,
        minPrice: next.minPrice,
        maxPrice: next.maxPrice,
      );
      return next.copyWith(courses: page.content, last: page.last);
    });
  }

  Future<void> refresh() async {
    final current = state.hasValue
        ? state.requireValue
        : const CourseListState(courses: []);
    final page = await _fetch(
      keyword: current.keyword,
      categoryId: current.categoryId,
      level: current.level,
      minPrice: current.minPrice,
      maxPrice: current.maxPrice,
    );
    state = AsyncData(
      current.copyWith(courses: page.content, page: 0, last: page.last),
    );
  }

  Future<void> loadMore() async {
    final current = state.hasValue ? state.requireValue : null;
    if (current == null || current.last || state.isLoading) return;
    final nextPage = current.page + 1;
    final page = await _fetch(
      keyword: current.keyword,
      categoryId: current.categoryId,
      level: current.level,
      minPrice: current.minPrice,
      maxPrice: current.maxPrice,
      page: nextPage,
    );
    state = AsyncData(
      current.copyWith(
        courses: [...current.courses, ...page.content],
        page: nextPage,
        last: page.last,
      ),
    );
  }

  Future<PageResult<CourseSummary>> _fetch({
    String? keyword,
    String? categoryId,
    String? level,
    double? minPrice,
    double? maxPrice,
    int page = 0,
  }) {
    return ref
        .read(courseApiProvider)
        .searchCourses(
          keyword: keyword,
          categoryId: categoryId,
          level: level,
          minPrice: minPrice,
          maxPrice: maxPrice,
          page: page,
          size: AppConstants.pageSize,
        );
  }
}
