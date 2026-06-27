import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import 'instructor_controller.dart';

class InstructorDashboardScreen extends ConsumerWidget {
  const InstructorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(instructorCourseControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giảng viên'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () =>
                ref.read(instructorCourseControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateCourse(context),
        icon: const Icon(Icons.add),
        label: const Text('Tạo khóa học'),
      ),
      body: SafeArea(
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorState(
            message: error.toString(),
            onRetry: () =>
                ref.read(instructorCourseControllerProvider.notifier).refresh(),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return _EmptyState(onCreate: () => _openCreateCourse(context));
            }
            return RefreshIndicator(
              onRefresh: () => ref
                  .read(instructorCourseControllerProvider.notifier)
                  .refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                itemCount: courses.length,
                itemBuilder: (context, index) {
                  return _InstructorCourseCard(course: courses[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openCreateCourse(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CreateCourseSheet(),
    );
  }
}

class _InstructorCourseCard extends ConsumerWidget {
  const _InstructorCourseCard({required this.course});

  final CourseSummary course;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(instructorCourseDetailProvider(course.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
        title: Text(course.title),
        subtitle: Text(
          '${course.level} - ${course.isFree ? 'Miễn phí' : '${course.price.toStringAsFixed(0)} d'}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openSectionSheet(context, course.id),
                icon: const Icon(Icons.view_agenda_outlined),
                label: const Text('Chương mục'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _openQuizSheet(context, course.id),
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Trắc nghiệm'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          detailAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (error, _) => Text(error.toString()),
            data: (detail) {
              if (detail.sections.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Chưa có chương mục. Hãy tạo chương mục trước.'),
                );
              }
              return Column(
                children: detail.sections
                    .map(
                      (section) =>
                          _SectionTile(courseId: course.id, section: section),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openSectionSheet(BuildContext context, String courseId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateSectionSheet(courseId: courseId),
    );
  }

  Future<void> _openQuizSheet(BuildContext context, String courseId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateQuizSheet(courseId: courseId),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({required this.courseId, required this.section});

  final String courseId;
  final CourseSectionModel section;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.view_agenda_outlined),
      title: Text(section.title),
      subtitle: Text('${section.lessons.length} bài học'),
      trailing: IconButton(
        tooltip: 'Thêm bài học',
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) =>
              _CreateLessonSheet(courseId: courseId, sectionId: section.id),
        ),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _CreateCourseSheet extends ConsumerStatefulWidget {
  const _CreateCourseSheet();

  @override
  ConsumerState<_CreateCourseSheet> createState() => _CreateCourseSheetState();
}

class _CreateCourseSheetState extends ConsumerState<_CreateCourseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _slug = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController(text: '0');
  final _image = TextEditingController();
  String? _categoryId;
  String _level = 'Beginner';
  bool _slugTouched = false;

  @override
  void initState() {
    super.initState();
    _title.addListener(() {
      if (!_slugTouched) _slug.text = _slugify(_title.text);
    });
    _slug.addListener(() => _slugTouched = true);
  }

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _description.dispose();
    _price.dispose();
    _image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final saving = ref.watch(instructorCourseControllerProvider).isLoading;

    return _SheetPadding(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHeader(title: 'Tạo khóa học'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Tên khóa học',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _slug,
                decoration: const InputDecoration(
                  labelText: 'Slug',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text('Chưa có danh mục.');
                  }
                  _categoryId ??= categories.first.id;
                  return DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _categoryId = value),
                    validator: (value) =>
                        value == null ? 'Chọn danh mục' : null,
                  );
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _level,
                decoration: const InputDecoration(labelText: 'Cấp độ'),
                items: const ['Beginner', 'Intermediate', 'Advanced']
                    .map(
                      (level) =>
                          DropdownMenuItem(value: level, child: Text(level)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _level = value ?? _level),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  return price == null || price < 0 ? 'Giá không hợp lệ' : null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _description,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mô tả',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Lưu khóa học',
                icon: Icons.save_outlined,
                isLoading: saving,
                onPressed: _categoryId == null ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _categoryId == null) return;
    await ref
        .read(instructorCourseControllerProvider.notifier)
        .createCourse(
          categoryId: _categoryId!,
          title: _title.text.trim(),
          slug: _slug.text.trim(),
          level: _level,
          price: double.parse(_price.text.trim()),
          description: _emptyToNull(_description.text),
          imageUrl: _emptyToNull(_image.text),
        );
    if (!mounted) return;
    final state = ref.read(instructorCourseControllerProvider);
    _showMessage(
      context,
      state.hasError ? state.error.toString() : 'Đã tạo khóa học.',
    );
    if (!state.hasError) Navigator.of(context).pop();
  }
}

class _CreateSectionSheet extends ConsumerStatefulWidget {
  const _CreateSectionSheet({required this.courseId});

  final String courseId;

  @override
  ConsumerState<_CreateSectionSheet> createState() =>
      _CreateSectionSheetState();
}

class _CreateSectionSheetState extends ConsumerState<_CreateSectionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _sort = TextEditingController(text: '0');
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _sort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetPadding(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _SheetHeader(title: 'Thêm chương mục'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tên chương mục'),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _sort,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Thứ tự'),
              validator: _sortValidator,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Lưu chương mục',
              icon: Icons.save_outlined,
              isLoading: _saving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(instructorCourseControllerProvider.notifier)
          .createSection(
            courseId: widget.courseId,
            title: _title.text.trim(),
            sortOrder: int.parse(_sort.text.trim()),
          );
      if (!mounted) return;
      _showMessage(context, 'Đã tạo chương mục.');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CreateLessonSheet extends ConsumerStatefulWidget {
  const _CreateLessonSheet({required this.courseId, required this.sectionId});

  final String courseId;
  final String sectionId;

  @override
  ConsumerState<_CreateLessonSheet> createState() => _CreateLessonSheetState();
}

class _CreateLessonSheetState extends ConsumerState<_CreateLessonSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _sort = TextEditingController(text: '0');
  final _video = TextEditingController();
  final _content = TextEditingController();
  String _type = 'Video';
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _sort.dispose();
    _video.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetPadding(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SheetHeader(title: 'Thêm bài học'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Tên bài học'),
                validator: _required,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sort,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Thứ tự'),
                      validator: _sortValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'Loại'),
                      items: const ['Video', 'Text', 'Quiz']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _type = value ?? _type),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _video,
                decoration: const InputDecoration(labelText: 'Video URL'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _content,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Nội dung'),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Lưu bài học',
                icon: Icons.save_outlined,
                isLoading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(instructorCourseControllerProvider.notifier)
          .createLesson(
            courseId: widget.courseId,
            sectionId: widget.sectionId,
            title: _title.text.trim(),
            sortOrder: int.parse(_sort.text.trim()),
            lessonType: _type,
            videoUrl: _emptyToNull(_video.text),
            content: _emptyToNull(_content.text),
          );
      if (!mounted) return;
      _showMessage(context, 'Đã tạo bài học.');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _CreateQuizSheet extends ConsumerStatefulWidget {
  const _CreateQuizSheet({required this.courseId});

  final String courseId;

  @override
  ConsumerState<_CreateQuizSheet> createState() => _CreateQuizSheetState();
}

class _CreateQuizSheetState extends ConsumerState<_CreateQuizSheet> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _question = TextEditingController();
  final _correct = TextEditingController();
  final _wrong1 = TextEditingController();
  final _wrong2 = TextEditingController();
  final _wrong3 = TextEditingController();
  String? _lessonId;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _question.dispose();
    _correct.dispose();
    _wrong1.dispose();
    _wrong2.dispose();
    _wrong3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(
      instructorCourseDetailProvider(widget.courseId),
    );

    return _SheetPadding(
      child: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text(error.toString()),
        data: (course) {
          final lessons = [
            for (final section in course.sections) ...section.lessons,
          ];
          if (lessons.isEmpty) {
            return const Text('Cần tạo bài học trước khi tạo trắc nghiệm.');
          }
          _lessonId ??= lessons.first.id;
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetHeader(title: 'Tạo trắc nghiệm'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _lessonId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Lesson'),
                    items: lessons
                        .map(
                          (lesson) => DropdownMenuItem(
                            value: lesson.id,
                            child: Text(lesson.title),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _lessonId = value),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Tên trắc nghiệm'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _description,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _question,
                    decoration: const InputDecoration(labelText: 'Câu hỏi'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _correct,
                    decoration: const InputDecoration(labelText: 'Đáp án đúng'),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _wrong1,
                    decoration: const InputDecoration(
                      labelText: 'Đáp án sai 1',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _wrong2,
                    decoration: const InputDecoration(
                      labelText: 'Đáp án sai 2',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _wrong3,
                    decoration: const InputDecoration(
                      labelText: 'Đáp án sai 3',
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Lưu trắc nghiệm',
                    icon: Icons.save_outlined,
                    isLoading: _saving,
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _lessonId == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(instructorCourseControllerProvider.notifier)
          .createQuiz(
            courseId: widget.courseId,
            lessonId: _lessonId!,
            title: _title.text.trim(),
            description: _emptyToNull(_description.text),
            questionText: _question.text.trim(),
            correctAnswer: _correct.text.trim(),
            wrongAnswers: [
              _wrong1.text.trim(),
              _wrong2.text.trim(),
              _wrong3.text.trim(),
            ],
          );
      if (!mounted) return;
      _showMessage(context, 'Đã tạo trắc nghiệm.');
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) _showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SheetPadding extends StatelessWidget {
  const _SheetPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: child,
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        IconButton(
          tooltip: 'Đóng',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.school_outlined,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            const Text('Bạn chưa có khóa học nào.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Tạo khóa học'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

String? _required(String? value) {
  return value == null || value.trim().isEmpty ? 'Bắt buộc nhập' : null;
}

String? _sortValidator(String? value) {
  final sortOrder = int.tryParse(value ?? '');
  return sortOrder == null || sortOrder < 0 ? 'Thứ tự không hợp lệ' : null;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _slugify(String value) {
  return value
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-');
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
