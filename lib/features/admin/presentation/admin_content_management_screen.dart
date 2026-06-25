import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../courses/data/course_models.dart';
import 'admin_content_controller.dart';
import 'admin_course_controller.dart';

class AdminContentManagementScreen extends ConsumerStatefulWidget {
  const AdminContentManagementScreen({super.key});

  @override
  ConsumerState<AdminContentManagementScreen> createState() =>
      _AdminContentManagementScreenState();
}

class _AdminContentManagementScreenState
    extends ConsumerState<AdminContentManagementScreen> {
  String? _courseId;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCourseControllerProvider);
    final courseId = _courseId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Section va lesson'),
        actions: [
          if (courseId != null)
            IconButton(
              tooltip: 'Lam moi',
              onPressed: () => ref
                  .read(adminContentControllerProvider(courseId).notifier)
                  .refresh(),
              icon: const Icon(Icons.refresh),
            ),
        ],
      ),
      floatingActionButton: courseId == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openSectionSheet(courseId),
              icon: const Icon(Icons.add),
              label: const Text('Them section'),
            ),
      body: SafeArea(
        child: coursesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _ErrorList(
            message: error.toString(),
            onRetry: () =>
                ref.read(adminCourseControllerProvider.notifier).refresh(),
          ),
          data: (courses) {
            if (courses.isEmpty) {
              return const Center(child: Text('Chua co khoa hoc nao.'));
            }
            final selectedId = _courseId ?? courses.first.id;
            _courseId = selectedId;
            return _ContentBody(
              courses: courses,
              selectedCourseId: selectedId,
              onCourseChanged: (value) => setState(() => _courseId = value),
              onAddSection: () => _openSectionSheet(selectedId),
              onEditSection: (section) =>
                  _openSectionSheet(selectedId, section: section),
              onDeleteSection: (section) => _deleteSection(selectedId, section),
              onAddLesson: (section) =>
                  _openLessonSheet(selectedId, section.id),
              onEditLesson: (section, lesson) =>
                  _openLessonSheet(selectedId, section.id, lesson: lesson),
              onDeleteLesson: (lesson) => _deleteLesson(selectedId, lesson),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openSectionSheet(
    String courseId, {
    CourseSectionModel? section,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _SectionFormSheet(courseId: courseId, section: section),
    );
  }

  Future<void> _openLessonSheet(
    String courseId,
    String sectionId, {
    LessonModel? lesson,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _LessonFormSheet(
        courseId: courseId,
        sectionId: sectionId,
        lesson: lesson,
      ),
    );
  }

  Future<void> _deleteSection(
    String courseId,
    CourseSectionModel section,
  ) async {
    final confirmed = await _confirmDelete('Xoa section?', section.title);
    if (confirmed != true) return;
    await ref
        .read(adminContentControllerProvider(courseId).notifier)
        .deleteSection(section.id);
    _showMutationMessage(courseId, 'Da xoa section.');
  }

  Future<void> _deleteLesson(String courseId, LessonModel lesson) async {
    final confirmed = await _confirmDelete('Xoa lesson?', lesson.title);
    if (confirmed != true) return;
    await ref
        .read(adminContentControllerProvider(courseId).notifier)
        .deleteLesson(lesson.id);
    _showMutationMessage(courseId, 'Da xoa lesson.');
  }

  Future<bool?> _confirmDelete(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Huy'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xoa'),
          ),
        ],
      ),
    );
  }

  void _showMutationMessage(String courseId, String success) {
    if (!mounted) return;
    final state = ref.read(adminContentControllerProvider(courseId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : success),
      ),
    );
  }
}

class _ContentBody extends ConsumerWidget {
  const _ContentBody({
    required this.courses,
    required this.selectedCourseId,
    required this.onCourseChanged,
    required this.onAddSection,
    required this.onEditSection,
    required this.onDeleteSection,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.onDeleteLesson,
  });

  final List<CourseSummary> courses;
  final String selectedCourseId;
  final ValueChanged<String?> onCourseChanged;
  final VoidCallback onAddSection;
  final ValueChanged<CourseSectionModel> onEditSection;
  final ValueChanged<CourseSectionModel> onDeleteSection;
  final ValueChanged<CourseSectionModel> onAddLesson;
  final void Function(CourseSectionModel section, LessonModel lesson)
  onEditLesson;
  final ValueChanged<LessonModel> onDeleteLesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contentAsync = ref.watch(
      adminContentControllerProvider(selectedCourseId),
    );

    return RefreshIndicator(
      onRefresh: () => ref
          .read(adminContentControllerProvider(selectedCourseId).notifier)
          .refresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedCourseId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Khoa hoc',
              prefixIcon: Icon(Icons.menu_book_outlined),
            ),
            selectedItemBuilder: (context) => courses
                .map(
                  (course) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      course.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            items: courses
                .map(
                  (course) => DropdownMenuItem(
                    value: course.id,
                    child: Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: onCourseChanged,
          ),
          const SizedBox(height: 16),
          contentAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => _ErrorList(
              message: error.toString(),
              onRetry: () => ref
                  .read(
                    adminContentControllerProvider(selectedCourseId).notifier,
                  )
                  .refresh(),
            ),
            data: (course) {
              if (course.sections.isEmpty) {
                return _EmptyContent(onAddSection: onAddSection);
              }
              final sections = [...course.sections]
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
              return Column(
                children: sections
                    .map(
                      (section) => _SectionCard(
                        section: section,
                        onEdit: () => onEditSection(section),
                        onDelete: () => onDeleteSection(section),
                        onAddLesson: () => onAddLesson(section),
                        onEditLesson: (lesson) => onEditLesson(section, lesson),
                        onDeleteLesson: onDeleteLesson,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.onEdit,
    required this.onDelete,
    required this.onAddLesson,
    required this.onEditLesson,
    required this.onDeleteLesson,
  });

  final CourseSectionModel section;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddLesson;
  final ValueChanged<LessonModel> onEditLesson;
  final ValueChanged<LessonModel> onDeleteLesson;

  @override
  Widget build(BuildContext context) {
    final lessons = [...section.lessons]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(
          Icons.view_agenda_outlined,
          color: AppColors.primary,
        ),
        title: Text(section.title),
        subtitle: Text('${lessons.length} bai hoc'),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Sua'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onAddLesson,
                icon: const Icon(Icons.add),
                label: const Text('Lesson'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Xoa section',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          if (lessons.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('Chua co lesson nao.'),
            )
          else
            ...lessons.map(
              (lesson) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  lesson.isPreview
                      ? Icons.visibility_outlined
                      : Icons.lock_outline,
                  color: AppColors.primary,
                ),
                title: Text(lesson.title),
                subtitle: Text(lesson.lessonType ?? 'Lesson'),
                trailing: Wrap(
                  spacing: 2,
                  children: [
                    IconButton(
                      tooltip: 'Sua lesson',
                      onPressed: () => onEditLesson(lesson),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Xoa lesson',
                      onPressed: () => onDeleteLesson(lesson),
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionFormSheet extends ConsumerStatefulWidget {
  const _SectionFormSheet({required this.courseId, this.section});

  final String courseId;
  final CourseSectionModel? section;

  @override
  ConsumerState<_SectionFormSheet> createState() => _SectionFormSheetState();
}

class _SectionFormSheetState extends ConsumerState<_SectionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sortController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.section?.title ?? '';
    _sortController.text = (widget.section?.sortOrder ?? 0).toString();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sortController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref
        .watch(adminContentControllerProvider(widget.courseId))
        .isLoading;

    return _SheetPadding(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(
              title: widget.section == null ? 'Them section' : 'Sua section',
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Ten section',
                prefixIcon: Icon(Icons.view_agenda_outlined),
              ),
              validator: _required,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _sortController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Thu tu',
                prefixIcon: Icon(Icons.sort_outlined),
              ),
              validator: _sortValidator,
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Luu',
              icon: Icons.save_outlined,
              isLoading: isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(adminContentControllerProvider(widget.courseId).notifier)
        .saveSection(
          id: widget.section?.id,
          title: _titleController.text.trim(),
          sortOrder: int.parse(_sortController.text.trim()),
        );
    if (!mounted) return;
    final state = ref.read(adminContentControllerProvider(widget.courseId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : 'Da luu.'),
      ),
    );
    if (!state.hasError) Navigator.of(context).pop();
  }
}

class _LessonFormSheet extends ConsumerStatefulWidget {
  const _LessonFormSheet({
    required this.courseId,
    required this.sectionId,
    this.lesson,
  });

  final String courseId;
  final String sectionId;
  final LessonModel? lesson;

  @override
  ConsumerState<_LessonFormSheet> createState() => _LessonFormSheetState();
}

class _LessonFormSheetState extends ConsumerState<_LessonFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _sortController = TextEditingController();
  final _videoController = TextEditingController();
  final _contentController = TextEditingController();
  String _lessonType = 'Video';
  bool _isPreview = false;

  @override
  void initState() {
    super.initState();
    final lesson = widget.lesson;
    _titleController.text = lesson?.title ?? '';
    _sortController.text = (lesson?.sortOrder ?? 0).toString();
    _videoController.text = lesson?.videoUrl ?? '';
    _contentController.text = lesson?.content ?? '';
    _lessonType = lesson?.lessonType ?? 'Video';
    _isPreview = lesson?.isPreview ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sortController.dispose();
    _videoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref
        .watch(adminContentControllerProvider(widget.courseId))
        .isLoading;

    return _SheetPadding(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetHeader(
                title: widget.lesson == null ? 'Them lesson' : 'Sua lesson',
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ten lesson',
                  prefixIcon: Icon(Icons.play_lesson_outlined),
                ),
                validator: _required,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sortController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Thu tu'),
                      validator: _sortValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _lessonType,
                      decoration: const InputDecoration(labelText: 'Loai'),
                      items: const ['Video', 'Text', 'Quiz']
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _lessonType = value ?? _lessonType),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _videoController,
                decoration: const InputDecoration(
                  labelText: 'Video URL',
                  prefixIcon: Icon(Icons.video_library_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contentController,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Noi dung',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cho xem preview'),
                value: _isPreview,
                onChanged: (value) => setState(() => _isPreview = value),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Luu lesson',
                icon: Icons.save_outlined,
                isLoading: isSaving,
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
    await ref
        .read(adminContentControllerProvider(widget.courseId).notifier)
        .saveLesson(
          id: widget.lesson?.id,
          sectionId: widget.sectionId,
          title: _titleController.text.trim(),
          sortOrder: int.parse(_sortController.text.trim()),
          lessonType: _lessonType,
          isPreview: _isPreview,
          videoUrl: _emptyToNull(_videoController.text),
          content: _emptyToNull(_contentController.text),
        );
    if (!mounted) return;
    final state = ref.read(adminContentControllerProvider(widget.courseId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : 'Da luu.'),
      ),
    );
    if (!state.hasError) Navigator.of(context).pop();
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
          tooltip: 'Dong',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent({required this.onAddSection});

  final VoidCallback onAddSection;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.play_lesson_outlined, color: AppColors.primary),
          const SizedBox(height: 10),
          const Text('Khoa hoc nay chua co section.'),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onAddSection,
            icon: const Icon(Icons.add),
            label: const Text('Them section'),
          ),
        ],
      ),
    );
  }
}

class _ErrorList extends StatelessWidget {
  const _ErrorList({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.error_outline, color: Colors.red),
        const SizedBox(height: 10),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thu lai'),
        ),
      ],
    );
  }
}

String? _required(String? value) {
  return value == null || value.trim().isEmpty ? 'Bat buoc nhap' : null;
}

String? _sortValidator(String? value) {
  final sortOrder = int.tryParse(value ?? '');
  if (sortOrder == null || sortOrder < 0) return 'Thu tu khong hop le';
  return null;
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
