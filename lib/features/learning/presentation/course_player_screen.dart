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

class CoursePlayerScreen extends ConsumerStatefulWidget {
  const CoursePlayerScreen({required this.courseId, super.key});

  final String courseId;

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoc tap'),
      ),
      body: SafeArea(
        child: detailAsync.when(
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(courseDetailProvider(widget.courseId)),
          ),
          data: (course) {
            // Auto-select first lesson if none is active
            if (_activeLesson == null) {
              for (final section in course.sections) {
                if (section.lessons.isNotEmpty) {
                  _activeLesson = section.lessons.first;
                  break;
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
                      Tab(text: 'Mo ta'),
                      Tab(text: 'Bai hoc'),
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
                                          : 'Noi dung bai hoc dang duoc cap nhat.',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const Center(
                                child: Text('Hay chon bai hoc de xem mo ta.'),
                              ),

                        // Tab 2: Lectures list
                        course.sections.isEmpty
                            ? const Center(
                                child: Text('Khoa hoc chua co bai hoc nao.'),
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
                                          '${section.lessons.length} bai hoc',
                                        ),
                                        children: section.lessons.map((lesson) {
                                          final isSelected = active?.id == lesson.id;
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
                                                  ? 'Bai hoc'
                                                  : (lesson.lessonType == 'Video'
                                                      ? 'Video'
                                                      : lesson.lessonType!),
                                            ),
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
                                  lesson: active,
                                ),
                              )
                            : const Center(
                                child: Text('Hay chon bai hoc de lam quiz.'),
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

class _VideoLessonPlayer extends StatefulWidget {
  const _VideoLessonPlayer({required this.videoUrl, super.key});

  final String videoUrl;

  @override
  State<_VideoLessonPlayer> createState() => _VideoLessonPlayerState();
}

class _VideoLessonPlayerState extends State<_VideoLessonPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _error = 'Url video trong';
      });
      return;
    }
    try {
      final uri = Uri.parse(widget.videoUrl);
      _controller = VideoPlayerController.networkUrl(uri);
      await _controller.initialize();
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

  @override
  void dispose() {
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
            const Icon(Icons.video_library_outlined, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              'Loi tai video hoac Video dang duoc cap nhat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
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

class _LessonQuizView extends StatefulWidget {
  const _LessonQuizView({required this.lesson, super.key});

  final LessonModel lesson;

  @override
  State<_LessonQuizView> createState() => _LessonQuizViewState();
}

class _LessonQuizViewState extends State<_LessonQuizView> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _submitted = false;
  late List<_QuizQuestion> _questions;

  @override
  void initState() {
    super.initState();
    _questions = _getQuestions(widget.lesson);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'Chua co cau hoi trac nghiem cho bai hoc nay.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    if (_submitted) {
      int score = 0;
      _questions.asMap().forEach((idx, q) {
        if (_selectedAnswers[idx] == q.correctIndex) {
          score++;
        }
      });

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
                const Icon(Icons.stars, size: 48, color: AppColors.primary),
                const SizedBox(height: 8),
                const Text(
                  'Hoan thanh bai quiz!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ket qua: $score/${_questions.length} cau dung (${((score / _questions.length) * 100).toStringAsFixed(0)}%)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Xem chi tiet ket qua:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ..._questions.asMap().entries.map((entry) {
            final idx = entry.key;
            final q = entry.value;
            final userAns = _selectedAnswers[idx];

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0.5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cau ${idx + 1}: ${q.text}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...q.options.asMap().entries.map((optEntry) {
                      final optIdx = optEntry.key;
                      final optText = optEntry.value;

                      Color? tileColor;
                      IconData? leadingIcon = Icons.radio_button_unchecked;

                      if (optIdx == q.correctIndex) {
                        tileColor = Colors.green[50];
                        leadingIcon = Icons.check_circle;
                      } else if (optIdx == userAns) {
                        tileColor = Colors.red[50];
                        leadingIcon = Icons.cancel;
                      }

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: tileColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: tileColor != null
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              leadingIcon,
                              color: optIdx == q.correctIndex
                                  ? Colors.green
                                  : (optIdx == userAns ? Colors.red : Colors.grey),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(optText)),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          AppButton(
            label: 'Lam lai',
            icon: Icons.refresh,
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _selectedAnswers.clear();
                _submitted = false;
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
              'Cau hoi ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Da chon: ${_selectedAnswers.length}/${_questions.length}',
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
          final isSelected = _selectedAnswers[_currentIndex] == idx;

          return Card(
            elevation: isSelected ? 2 : 0.5,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: RadioListTile<int>(
              value: idx,
              groupValue: _selectedAnswers[_currentIndex],
              title: Text(option),
              activeColor: AppColors.primary,
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedAnswers[_currentIndex] = val;
                  });
                }
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
                  label: const Text('Quay lai'),
                ),
              ),
            if (_currentIndex > 0) const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: _currentIndex == _questions.length - 1 ? 'Nop bai' : 'Tiep theo',
                icon: _currentIndex == _questions.length - 1 ? Icons.send : Icons.arrow_forward,
                onPressed: _selectedAnswers[_currentIndex] == null
                    ? null
                    : () {
                        if (_currentIndex == _questions.length - 1) {
                          setState(() {
                            _submitted = true;
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
  if (title.contains('java') || title.contains('spring') || title.contains('backend')) {
    return [
      _QuizQuestion(
        text: 'Java la ngon ngu lap trinh thuoc loai nao?',
        options: ['Bien dich (Compiled)', 'Thong dich (Interpreted)', 'Ca hai', 'Khong phai loai nao'],
        correctIndex: 2,
      ),
      _QuizQuestion(
        text: 'Spring Boot chu yeu duoc dung de lam gi?',
        options: ['Phat trien mobile app', 'Xay dung REST API/Backend', 'Lap trinh he thong', 'Thiet ke giao dien'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Annotation nao dung de dinh nghia mot REST Controller trong Spring?',
        options: ['@Controller', '@RestController', '@Service', '@Repository'],
        correctIndex: 1,
      ),
    ];
  } else if (title.contains('flutter') || title.contains('dart') || title.contains('mobile')) {
    return [
      _QuizQuestion(
        text: 'Widget nao la widget khong co trang thai trong Flutter?',
        options: ['StatefulWidget', 'StatelessWidget', 'InheritedWidget', 'ProviderWidget'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Phuong thuc nao bat dau chu ky cua mot State trong Flutter?',
        options: ['build', 'initState', 'dispose', 'didUpdateWidget'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Ngon ngu lap trinh chinh duoc su dung trong Flutter la gi?',
        options: ['Java', 'Swift', 'Kotlin', 'Dart'],
        correctIndex: 3,
      ),
    ];
  } else {
    return [
      _QuizQuestion(
        text: 'Muc tieu hoc tap hieu qua nhat la gi?',
        options: ['Chi nghe giang', 'Vua hoc ly thuyet vua lam thuc hanh', 'Copy code tu chat bot', 'Chi lam quiz'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Ban nen lam gi khi gap loi trong luc lap trinh?',
        options: ['Bo cuoc', 'Doc thong bao loi va debug tung buoc', 'Xoa toan bo code di viet lai', 'Gui mail cho thay co ngay lap tuc'],
        correctIndex: 1,
      ),
      _QuizQuestion(
        text: 'Brainery la nen tang gi?',
        options: ['Ung dung tin nhan', 'Mang xa hoi video', 'He thong quan ly hoc tap truc tuyen (LMS)', 'Cho mua ban truc tuyen'],
        correctIndex: 2,
      ),
    ];
  }
}
