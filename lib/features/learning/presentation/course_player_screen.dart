// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import '../data/progress_models.dart';
import 'enrollment_controller.dart';

class CoursePlayerScreen extends ConsumerStatefulWidget {
  const CoursePlayerScreen({
    required this.courseId,
    this.initialLessonId,
    super.key,
  });

  final String courseId;
  final String? initialLessonId;

  @override
  ConsumerState<CoursePlayerScreen> createState() => _CoursePlayerScreenState();
}

class _CoursePlayerScreenState extends ConsumerState<CoursePlayerScreen>
    with SingleTickerProviderStateMixin {
  LessonModel? _activeLesson;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(courseDetailProvider(widget.courseId));
    final progressAsync = ref.watch(courseProgressProvider(widget.courseId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Học tập'),
      ),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(courseDetailProvider(widget.courseId)),
          ),
          data: (course) {
            // Auto-select initialLessonId if provided, or fallback to first lesson if none is active
            if (_activeLesson == null) {
              if (widget.initialLessonId != null) {
                for (final section in course.sections) {
                  for (final lesson in section.lessons) {
                    if (lesson.id == widget.initialLessonId) {
                      _activeLesson = lesson;
                      break;
                    }
                  }
                  if (_activeLesson != null) break;
                }
              }
              if (_activeLesson == null) {
                for (final section in course.sections) {
                  if (section.lessons.isNotEmpty) {
                    _activeLesson = section.lessons.first;
                    break;
                  }
                }
              }
            }

            final active = _activeLesson;

            return Column(
              children: [
                // Player Area
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: active != null &&
                          active.lessonType == 'Video' &&
                          active.videoUrl != null &&
                          active.videoUrl!.isNotEmpty
                      ? _VideoLessonPlayer(
                          key: ValueKey(active.id),
                          courseId: widget.courseId,
                          lessonId: active.id,
                          videoUrl: active.videoUrl!,
                        )
                      : ClipRRect(
                          child: course.courseImageUrl != null &&
                                  course.courseImageUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: course.courseImageUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (_, _) => Container(
                                    color: AppColors.line,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (_, _, _) => Container(
                                    color: AppColors.primary,
                                    child: const Icon(
                                      Icons.school,
                                      color: Colors.white,
                                      size: 56,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: AppColors.primary,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                    size: 56,
                                  ),
                                ),
                        ),
                ),

                // TabBar
                TabBar(
                  controller: _tabController,
                  indicatorColor: AppColors.primary,
                  labelColor: AppColors.primaryDark,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Mô tả'),
                    Tab(text: 'Bài học'),
                    Tab(text: 'Quiz'),
                  ],
                ),

                // TabBarView content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Description
                      active != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    active.content?.isNotEmpty == true
                                        ? active.content!
                                        : 'Nội dung bài học đang được cập nhật.',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Manual completed button for Text lessons
                                  if (active.lessonType == 'Lesson' ||
                                      active.lessonType == null)
                                    progressAsync.when(
                                      loading: () => const SizedBox(),
                                      error: (_, _) => const SizedBox(),
                                      data: (data) {
                                        final isCompleted = data
                                            .completedLessonIds
                                            .contains(active.id);
                                        if (isCompleted) {
                                          return Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.check_circle,
                                                    color: AppColors.primary),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Bạn đã hoàn thành bài học này!',
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.primaryDark,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                        return SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    enrollmentActionProvider
                                                        .notifier,
                                                  )
                                                  .completeLesson(
                                                    widget.courseId,
                                                    active.id,
                                                  );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            icon: const Icon(Icons.check),
                                            label: const Text(
                                              'Đánh dấu hoàn thành',
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Text('Hãy chọn bài học để xem mô tả.'),
                            ),

                      // Tab 2: Lectures list
                      course.sections.isEmpty
                          ? const Center(
                              child: Text('Khóa học chưa có bài học nào.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: course.sections.length,
                              itemBuilder: (context, sectionIndex) {
                                final section = course.sections[sectionIndex];
                                return Card(
                                  elevation: 0.5,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  child: Theme(
                                    data: Theme.of(context).copyWith(
                                      dividerColor: Colors.transparent,
                                    ),
                                    child: ExpansionTile(
                                      initiallyExpanded: true,
                                      title: Text(
                                        '${sectionIndex + 1}. ${section.title}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${section.lessons.length} bài học',
                                      ),
                                      children: section.lessons.map((lesson) {
                                        final isSelected =
                                            active?.id == lesson.id;
                                        final isCompleted =
                                            progressAsync.maybeWhen(
                                          data: (data) => data
                                              .completedLessonIds
                                              .contains(lesson.id),
                                          orElse: () => false,
                                        );

                                        return ListTile(
                                          selected: isSelected,
                                          selectedTileColor: AppColors.primary
                                              .withValues(alpha: 0.08),
                                          leading: Icon(
                                            lesson.lessonType == 'Video'
                                                ? Icons.play_circle_outline
                                                : (lesson.lessonType == 'Quiz'
                                                    ? Icons.quiz_outlined
                                                    : Icons.article_outlined),
                                            color: isSelected
                                                ? AppColors.primary
                                                : null,
                                          ),
                                          title: Text(
                                            lesson.title,
                                            style: TextStyle(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : null,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : null,
                                            ),
                                          ),
                                          subtitle: Text(
                                            lesson.lessonType == 'Lesson' ||
                                                    lesson.lessonType == null
                                                ? 'Bài học'
                                                : (lesson.lessonType == 'Video'
                                                    ? 'Video'
                                                    : lesson.lessonType!),
                                          ),
                                          trailing: isCompleted
                                              ? const Icon(
                                                  Icons.check_circle,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                )
                                              : null,
                                          onTap: () {
                                            setState(() {
                                              _activeLesson = lesson;
                                            });
                                            if (lesson.lessonType == 'Quiz') {
                                              _tabController.animateTo(2);
                                            } else {
                                              _tabController.animateTo(0);
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                );
                              },
                            ),

                      // Tab 3: Quiz view
                      active != null
                          ? SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: _LessonQuizView(
                                key: ValueKey(active.id),
                                courseId: widget.courseId,
                                lesson: active,
                              ),
                            )
                          : const Center(
                              child: Text('Hãy chọn bài học để làm quiz.'),
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _VideoLessonPlayer extends ConsumerStatefulWidget {
  const _VideoLessonPlayer({
    required this.courseId,
    required this.lessonId,
    required this.videoUrl,
    super.key,
  });

  final String courseId;
  final String lessonId;
  final String videoUrl;

  @override
  ConsumerState<_VideoLessonPlayer> createState() => _VideoLessonPlayerState();
}

class _VideoLessonPlayerState extends ConsumerState<_VideoLessonPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;
  bool _completionSent = false;
  int _lastProgressUpdate = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _error = 'Url video trống';
      });
      return;
    }
    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller.initialize();
      _controller.addListener(_onVideoProgress);
      if (mounted) {
        setState(() {
          _initialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  void _onVideoProgress() {
    if (!mounted || !_controller.value.isInitialized) return;

    final position = _controller.value.position;
    final duration = _controller.value.duration;

    if (duration.inSeconds == 0) return;

    final progressPercent = (position.inSeconds / duration.inSeconds) * 100;

    // Send progress to backend every 10 seconds
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - _lastProgressUpdate > 10000) {
      _lastProgressUpdate = nowMs;
      ref.read(enrollmentActionProvider.notifier).updateLessonProgress(
            widget.courseId,
            widget.lessonId,
            watchedSeconds: position.inSeconds,
            lastPositionSeconds: position.inSeconds,
            completedPercent: progressPercent,
            isCompleted: progressPercent >= 90.0,
          );
    }

    // Auto-complete video when it reaches 90% or finishes
    if (progressPercent >= 90.0 && !_completionSent) {
      _completionSent = true;
      ref.read(enrollmentActionProvider.notifier).completeLesson(
            widget.courseId,
            widget.lessonId,
          );
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_library_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              'Lỗi tải video hoặc Video đang được cập nhật.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (!_initialized) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _VideoControlsOverlay(controller: _controller),
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: AppColors.primary,
              bufferedColor: Colors.white30,
              backgroundColor: Colors.white12,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoControlsOverlay extends StatefulWidget {
  const _VideoControlsOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_VideoControlsOverlay> createState() => _VideoControlsOverlayState();
}

class _VideoControlsOverlayState extends State<_VideoControlsOverlay> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black38,
          child: Center(
            child: IconButton(
              iconSize: 64,
              icon: Icon(
                widget.controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (widget.controller.value.isPlaying) {
                    widget.controller.pause();
                  } else {
                    widget.controller.play();
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LessonQuizView extends ConsumerStatefulWidget {
  const _LessonQuizView({
    required this.courseId,
    required this.lesson,
    super.key,
  });

  final String courseId;
  final LessonModel lesson;

  @override
  ConsumerState<_LessonQuizView> createState() => _LessonQuizViewState();
}

class _LessonQuizViewState extends ConsumerState<_LessonQuizView> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _submitted = false;
  late List<_QuizQuestion> _questions;
  QuizResultModel? _pastResult;
  bool _loadingResult = true;
  String? _quizId;

  @override
  void initState() {
    super.initState();
    _questions = _getQuestions(widget.lesson);
    _fetchQuizAndResult();
  }

  Future<void> _fetchQuizAndResult() async {
    try {
      final quizzes = await ref
          .read(enrollmentApiProvider)
          .getLessonQuizzes(widget.lesson.id);
      if (quizzes.isNotEmpty) {
        final quiz = quizzes.first;
        _quizId = quiz.id;
        final result =
            await ref.read(enrollmentApiProvider).getQuizResult(quiz.id);
        if (mounted) {
          setState(() {
            if (result.id.isNotEmpty) {
              _pastResult = result;
              _submitted = true;
            }
            _loadingResult = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loadingResult = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingResult = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingResult) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Chưa có câu hỏi trắc nghiệm cho bài học này.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (_submitted) {
      final scoreVal = _pastResult?.score ?? 0.0;
      final passedVal = _pastResult?.passed ?? false;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  passedVal ? Icons.stars : Icons.cancel_outlined,
                  size: 48,
                  color: passedVal ? AppColors.primary : AppColors.danger,
                ),
                const SizedBox(height: 8),
                Text(
                  passedVal ? 'Hoàn thành bài quiz!' : 'Chưa đạt yêu cầu bài quiz',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: passedVal ? AppColors.primaryDark : AppColors.danger,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kết quả: ${scoreVal.toStringAsFixed(0)}% (Yêu cầu qua môn: 50%)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Làm lại',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _selectedAnswers.clear();
                _submitted = false;
                _pastResult = null;
              });
            },
          ),
        ],
      );
    }

    final q = _questions[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Câu hỏi ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Đã chọn: ${_selectedAnswers.length}/${_questions.length}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _questions.length,
          color: AppColors.primary,
          backgroundColor: Colors.grey[200],
        ),
        const SizedBox(height: 16),
        Text(
          q.text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...q.options.asMap().entries.map((entry) {
          final idx = entry.key;
          final option = entry.value;
          final isAnswered = _selectedAnswers.containsKey(_currentIndex);
          final isCorrect = idx == q.correctIndex;
          final isSelected = _selectedAnswers[_currentIndex] == idx;

          Color? cardBg;
          Color borderColor = Colors.grey[300]!;
          Color? textColor;
          Widget leadingIcon;

          if (isAnswered) {
            if (isCorrect) {
              cardBg = AppColors.primary.withValues(alpha: 0.1);
              borderColor = AppColors.primary;
              textColor = AppColors.primaryDark;
              leadingIcon = const Icon(Icons.check_circle, color: AppColors.primary);
            } else if (isSelected) {
              cardBg = AppColors.danger.withValues(alpha: 0.1);
              borderColor = AppColors.danger;
              textColor = AppColors.danger;
              leadingIcon = const Icon(Icons.cancel, color: AppColors.danger);
            } else {
              cardBg = Colors.grey[50];
              borderColor = Colors.grey[200]!;
              textColor = Colors.grey[500];
              leadingIcon = Icon(Icons.radio_button_off, color: Colors.grey[300]);
            }
          } else {
            if (isSelected) {
              borderColor = AppColors.primary;
              textColor = AppColors.primary;
              leadingIcon = const Icon(Icons.radio_button_checked, color: AppColors.primary);
            } else {
              leadingIcon = const Icon(Icons.radio_button_off, color: Colors.grey);
            }
          }

          return Card(
            elevation: isSelected ? 2 : 0.5,
            margin: const EdgeInsets.only(bottom: 10),
            color: cardBg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: borderColor,
                width: isSelected || (isAnswered && isCorrect) ? 1.5 : 1.0,
              ),
            ),
            child: ListTile(
              leading: leadingIcon,
              title: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontWeight: isSelected || (isAnswered && isCorrect) ? FontWeight.bold : null,
                ),
              ),
              onTap: isAnswered
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswers[_currentIndex] = idx;
                      });
                    },
            ),
          );
        }),
        const SizedBox(height: 24),
        Row(
          children: [
            if (_currentIndex > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _currentIndex--;
                    });
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Quay lại'),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: _currentIndex == _questions.length - 1
                    ? 'Nộp bài'
                    : 'Tiếp theo',
                icon: _currentIndex == _questions.length - 1
                    ? Icons.send
                    : Icons.arrow_forward,
                onPressed: _selectedAnswers[_currentIndex] == null
                    ? null
                    : () {
                        if (_currentIndex == _questions.length - 1) {
                          // Submit to backend
                          final answers = _selectedAnswers.entries.map((entry) {
                            final questionIndex = entry.key;
                            final selectedOptIdx = entry.value;
                            final question = _questions[questionIndex];
                            return {
                              'questionId':
                                  '00000000-0000-0000-0000-0000000000${questionIndex + 10}',
                              'answerId':
                                  '00000000-0000-0000-0000-00000000000$selectedOptIdx',
                              'answerText': question.options[selectedOptIdx],
                            };
                          }).toList();

                          final qId = _quizId ??
                              '00000000-0000-0000-0000-000000000000';

                          setState(() {
                            _loadingResult = true;
                          });

                          ref
                              .read(enrollmentActionProvider.notifier)
                              .submitQuiz(widget.courseId, qId, answers)
                              .then((res) {
                            if (mounted) {
                              setState(() {
                                _pastResult = res;
                                _submitted = true;
                                _loadingResult = false;
                              });
                            }
                          });
                        } else {
                          setState(() {
                            _currentIndex++;
                          });
                        }
                      },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuizQuestion {
  final String text;
  final List<String> options;
  final int correctIndex;

  _QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });
}

List<_QuizQuestion> _getQuestions(LessonModel lesson) {
  final title = lesson.title.toLowerCase();
  if (title.contains('java') ||
      title.contains('spring') ||
      title.contains('backend')) {
    return [
      _QuizQuestion(
        text: 'Java là ngôn ngữ lập trình thuộc loại nào?',
        options: [
          'Biên dịch (Compiled)',
          'Thông dịch (Interpreted)',
          'Cả hai',
          'Không phải loại nào'
        ],
        correctIndex: 2,
      ),
      _QuizQuestion(
        text: 'Spring Boot chủ yếu được dùng để làm gì?',
        options: [
          'Phát triển mobile app',
          'Xây dựng REST API/Backend',
          'Lập trình hệ thống',
          'Thiết kế giao diện'
        ],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text:
            'Annotation nào dùng để định nghĩa một REST Controller trong Spring?',
        options: [
          '@Controller',
          '@RestController',
          '@Service',
          '@Repository'
        ],
        correctIndex: 1,
      ),
    ];
  } else if (title.contains('flutter') ||
      title.contains('dart') ||
      title.contains('mobile')) {
    return [
      _QuizQuestion(
        text: 'Widget nào là widget không có trạng thái trong Flutter?',
        options: [
          'StatefulWidget',
          'StatelessWidget',
          'InheritedWidget',
          'ProviderWidget'
        ],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Phương thức nào bắt đầu chu kỳ của một State trong Flutter?',
        options: ['build', 'initState', 'dispose', 'didUpdateWidget'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text:
            'Ngôn ngữ lập trình chính được sử dụng trong Flutter là gì?',
        options: ['Java', 'Swift', 'Kotlin', 'Dart'],
        correctIndex: 3,
      ),
    ];
  } else {
    return [
      _QuizQuestion(
        text: 'Mục tiêu học tập hiệu quả nhất là gì?',
        options: [
          'Chỉ nghe giảng',
          'Vừa học lý thuyết vừa làm thực hành',
          'Copy code từ chat bot',
          'Chỉ làm quiz'
        ],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Bạn nên làm gì khi gặp lỗi trong lúc lập trình?',
        options: [
          'Bỏ cuộc',
          'Đọc thông báo lỗi và debug từng bước',
          'Xóa toàn bộ code đi viết lại',
          'Gửi mail cho thầy cô ngay lập tức'
        ],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Brainery là nền tảng gì?',
        options: [
          'Ứng dụng tin nhắn',
          'Mạng xã hội video',
          'Hệ thống quản lý học tập trực tuyến (LMS)',
          'Chợ mua bán trực tuyến'
        ],
        correctIndex: 2,
      ),
    ];
  }
}
