class CourseProgressModel {
  const CourseProgressModel({
    required this.courseId,
    required this.overallProgress,
    required this.completedLessonIds,
    required this.lessonProgress,
  });

  final String courseId;
  final double overallProgress;
  final List<String> completedLessonIds;
  final List<LessonProgressDto> lessonProgress;

  factory CourseProgressModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};

    final completedList = map['completedLessonIds'] as List?;
    final completedLessonIds =
        completedList?.map((e) => e.toString()).toList() ?? [];

    final progressList = map['lessonProgress'] as List?;
    final lessonProgress =
        progressList?.map(LessonProgressDto.fromJson).toList() ?? [];

    return CourseProgressModel(
      courseId: map['courseId']?.toString() ?? '',
      overallProgress:
          double.tryParse(map['overallProgress']?.toString() ?? '') ?? 0.0,
      completedLessonIds: completedLessonIds,
      lessonProgress: lessonProgress,
    );
  }
}

class LessonProgressDto {
  const LessonProgressDto({
    required this.lessonId,
    required this.watchedSeconds,
    required this.lastPositionSeconds,
    required this.completedPercent,
    required this.completed,
  });

  final String lessonId;
  final int watchedSeconds;
  final int lastPositionSeconds;
  final double completedPercent;
  final bool completed;

  factory LessonProgressDto.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return LessonProgressDto(
      lessonId: map['lessonId']?.toString() ?? '',
      watchedSeconds:
          int.tryParse(map['watchedSeconds']?.toString() ?? '') ?? 0,
      lastPositionSeconds:
          int.tryParse(map['lastPositionSeconds']?.toString() ?? '') ?? 0,
      completedPercent:
          double.tryParse(map['completedPercent']?.toString() ?? '') ?? 0.0,
      completed: map['completed'] == true,
    );
  }
}

class LearningProgressModel {
  const LearningProgressModel({
    required this.targetId,
    this.watchedSeconds,
    this.lastPositionSeconds,
    this.completedPercent,
    required this.completed,
    this.updatedAt,
  });

  final String targetId;
  final int? watchedSeconds;
  final int? lastPositionSeconds;
  final double? completedPercent;
  final bool completed;
  final String? updatedAt;

  factory LearningProgressModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return LearningProgressModel(
      targetId: map['targetId']?.toString() ?? '',
      watchedSeconds: int.tryParse(map['watchedSeconds']?.toString() ?? ''),
      lastPositionSeconds:
          int.tryParse(map['lastPositionSeconds']?.toString() ?? ''),
      completedPercent:
          double.tryParse(map['completedPercent']?.toString() ?? ''),
      completed: map['completed'] == true,
      updatedAt: map['updatedAt']?.toString(),
    );
  }
}

class QuizResultModel {
  const QuizResultModel({
    required this.id,
    required this.quizId,
    this.userEmail,
    required this.score,
    required this.passed,
    this.submittedAt,
  });

  final String id;
  final String quizId;
  final String? userEmail;
  final double score;
  final bool passed;
  final String? submittedAt;

  factory QuizResultModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return QuizResultModel(
      id: map['id']?.toString() ?? '',
      quizId: map['quizId']?.toString() ?? '',
      userEmail: map['userEmail']?.toString(),
      score: double.tryParse(map['score']?.toString() ?? '') ?? 0.0,
      passed: map['passed'] == true,
      submittedAt: map['submittedAt']?.toString(),
    );
  }
}

class QuizMetadataModel {
  const QuizMetadataModel({
    required this.id,
    required this.lessonId,
    required this.title,
  });

  final String id;
  final String lessonId;
  final String title;

  factory QuizMetadataModel.fromJson(Object? json) {
    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return QuizMetadataModel(
      id: map['id']?.toString() ?? '',
      lessonId: map['lessonId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
    );
  }
}
