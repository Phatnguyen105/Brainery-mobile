class CategoryModel {
  const CategoryModel({required this.id, required this.name, this.slug});

  final String id;
  final String name;
  final String? slug;

  factory CategoryModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return CategoryModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Danh muc',
      slug: map['slug']?.toString(),
    );
  }
}

typedef TagModel = CategoryModel;

class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.title,
    required this.level,
    required this.price,
    required this.instructorName,
    required this.averageRating,
    required this.totalReviews,
    required this.isFeatured,
    this.slug,
    this.courseImageUrl,
  });

  final String id;
  final String title;
  final String? slug;
  final String level;
  final double price;
  final String? courseImageUrl;
  final String instructorName;
  final double averageRating;
  final int totalReviews;
  final bool isFeatured;

  bool get isFree => price <= 0;

  factory CourseSummary.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return CourseSummary(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Khoa hoc Brainery',
      slug: map['slug']?.toString(),
      level: map['level']?.toString() ?? 'BEGINNER',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0,
      courseImageUrl: map['courseImageUrl']?.toString(),
      instructorName: map['instructorName']?.toString() ?? 'Brainery',
      averageRating:
          double.tryParse(map['averageRating']?.toString() ?? '') ?? 0,
      totalReviews: int.tryParse(map['totalReviews']?.toString() ?? '') ?? 0,
      isFeatured: map['isFeatured'] == true,
    );
  }
}

class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.title,
    required this.level,
    required this.price,
    required this.tags,
    required this.sections,
    this.categoryId,
    this.instructorId,
    this.slug,
    this.description,
    this.courseImageUrl,
    this.previewVideoUrl,
    this.status,
    this.isFeatured = false,
  });

  final String id;
  final String? categoryId;
  final String? instructorId;
  final String title;
  final String? slug;
  final String? description;
  final String level;
  final double price;
  final String? courseImageUrl;
  final String? previewVideoUrl;
  final String? status;
  final bool isFeatured;
  final List<TagModel> tags;
  final List<CourseSectionModel> sections;

  bool get isFree => price <= 0;

  factory CourseDetail.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return CourseDetail(
      id: map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString(),
      instructorId: map['instructorId']?.toString(),
      title: map['title']?.toString() ?? 'Khoa hoc Brainery',
      slug: map['slug']?.toString(),
      description: map['description']?.toString(),
      level: map['level']?.toString() ?? 'BEGINNER',
      price: double.tryParse(map['price']?.toString() ?? '') ?? 0,
      courseImageUrl: map['courseImageUrl']?.toString(),
      previewVideoUrl: map['previewVideoUrl']?.toString(),
      status: map['status']?.toString(),
      isFeatured: map['isFeatured'] == true,
      tags: _readList(map['tags']).map(TagModel.fromJson).toList(),
      sections: _readList(
        map['sections'],
      ).map(CourseSectionModel.fromJson).toList(),
    );
  }
}

class CourseSectionModel {
  const CourseSectionModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.sortOrder,
    required this.lessons,
  });

  final String id;
  final String courseId;
  final String title;
  final int sortOrder;
  final List<LessonModel> lessons;

  factory CourseSectionModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return CourseSectionModel(
      id: map['id']?.toString() ?? '',
      courseId: map['courseId']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Section',
      sortOrder: int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0,
      lessons: _readList(map['lessons']).map(LessonModel.fromJson).toList(),
    );
  }
}

class LessonModel {
  const LessonModel({
    required this.id,
    required this.title,
    required this.sortOrder,
    required this.isPreview,
    required this.fullAccess,
    this.sectionId,
    this.videoUrl,
    this.thumbnailUrl,
    this.content,
    this.lessonType,
    this.videoQuality,
    this.transcriptUrl,
  });

  final String id;
  final String? sectionId;
  final String title;
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? content;
  final int sortOrder;
  final String? lessonType;
  final String? videoQuality;
  final bool isPreview;
  final String? transcriptUrl;
  final bool fullAccess;

  factory LessonModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return LessonModel(
      id: map['id']?.toString() ?? '',
      sectionId: map['sectionId']?.toString(),
      title: map['title']?.toString() ?? 'Bai hoc',
      videoUrl: map['videoUrl']?.toString(),
      thumbnailUrl: map['thumbnailUrl']?.toString(),
      content: map['content']?.toString(),
      sortOrder: int.tryParse(map['sortOrder']?.toString() ?? '') ?? 0,
      lessonType: map['lessonType']?.toString(),
      videoQuality: map['videoQuality']?.toString(),
      isPreview: map['isPreview'] == true,
      transcriptUrl: map['transcriptUrl']?.toString(),
      fullAccess: map['fullAccess'] == true,
    );
  }
}

class PageResult<T> {
  const PageResult({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  factory PageResult.fromJson(
    Object? json,
    T Function(Object? json) parseItem,
  ) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return PageResult(
      content: _readList(map['content']).map(parseItem).toList(),
      page: int.tryParse(map['page']?.toString() ?? '') ?? 0,
      size: int.tryParse(map['size']?.toString() ?? '') ?? 0,
      totalElements: int.tryParse(map['totalElements']?.toString() ?? '') ?? 0,
      totalPages: int.tryParse(map['totalPages']?.toString() ?? '') ?? 0,
      last: map['last'] == true,
    );
  }
}

List<Object?> _readList(Object? value) {
  if (value is List) return value;
  return const [];
}
