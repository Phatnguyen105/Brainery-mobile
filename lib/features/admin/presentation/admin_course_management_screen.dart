import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../courses/data/course_models.dart';
import '../../courses/presentation/course_controller.dart';
import 'admin_course_controller.dart';

class AdminCourseManagementScreen extends ConsumerStatefulWidget {
  const AdminCourseManagementScreen({super.key});

  @override
  ConsumerState<AdminCourseManagementScreen> createState() =>
      _AdminCourseManagementScreenState();
}

class _AdminCourseManagementScreenState
    extends ConsumerState<AdminCourseManagementScreen> {
  String? _status;

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCourseControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quan ly khoa hoc'),
        actions: [
          IconButton(
            tooltip: 'Lam moi',
            onPressed: () =>
                ref.read(adminCourseControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Them khoa hoc'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(adminCourseControllerProvider.notifier).refresh(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              _StatusFilter(
                value: _status,
                onChanged: (value) {
                  setState(() => _status = value);
                  ref
                      .read(adminCourseControllerProvider.notifier)
                      .setStatus(value);
                },
              ),
              const SizedBox(height: 16),
              coursesAsync.when(
                loading: () => const _LoadingList(),
                error: (error, _) => _ErrorState(
                  message: error.toString(),
                  onRetry: () => ref
                      .read(adminCourseControllerProvider.notifier)
                      .refresh(),
                ),
                data: (courses) {
                  if (courses.isEmpty) {
                    return const _EmptyState();
                  }
                  return Column(
                    children: courses
                        .map(
                          (course) => _AdminCourseCard(
                            course: course,
                            onOpen: () => context.push(
                              RouteNames.courseDetail(course.id),
                            ),
                            onPublish: () => _runAction(
                              () => ref
                                  .read(adminCourseControllerProvider.notifier)
                                  .publish(course.id),
                              'Da publish khoa hoc.',
                            ),
                            onArchive: () => _runAction(
                              () => ref
                                  .read(adminCourseControllerProvider.notifier)
                                  .archive(course.id),
                              'Da archive khoa hoc.',
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    await action();
    if (!mounted) return;
    final state = ref.read(adminCourseControllerProvider);
    final message = state.hasError ? state.error.toString() : successMessage;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCreateSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const _CreateCourseSheet(),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    const items = <({String label, String? value})>[
      (label: 'Tat ca', value: null),
      (label: 'Draft', value: 'Draft'),
      (label: 'Published', value: 'Published'),
      (label: 'Archived', value: 'Archived'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(item.label),
                  selected: value == item.value,
                  onSelected: (_) => onChanged(item.value),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AdminCourseCard extends StatelessWidget {
  const _AdminCourseCard({
    required this.course,
    required this.onOpen,
    required this.onPublish,
    required this.onArchive,
  });

  final CourseSummary course;
  final VoidCallback onOpen;
  final VoidCallback onPublish;
  final VoidCallback onArchive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.title, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(
                        '${course.instructorName} - ${course.level}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  course.isFree
                      ? 'Mien phi'
                      : '${course.price.toStringAsFixed(0)} d',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('Xem'),
                ),
                OutlinedButton.icon(
                  onPressed: onPublish,
                  icon: const Icon(Icons.publish_outlined),
                  label: const Text('Publish'),
                ),
                OutlinedButton.icon(
                  onPressed: onArchive,
                  icon: const Icon(Icons.archive_outlined),
                  label: const Text('Archive'),
                ),
              ],
            ),
          ],
        ),
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
  final _titleController = TextEditingController();
  final _slugController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _imageController = TextEditingController();
  String? _categoryId;
  String _level = 'Beginner';
  String _status = 'Draft';
  bool _featured = false;
  bool _slugTouched = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(() {
      if (_slugTouched) return;
      _slugController.text = _slugify(_titleController.text);
    });
    _slugController.addListener(() => _slugTouched = true);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _slugController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isSaving = ref.watch(adminCourseControllerProvider).isLoading;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Them khoa hoc',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Dong',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Ten khoa hoc',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Nhap ten khoa hoc'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'Slug',
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nhap slug' : null,
              ),
              const SizedBox(height: 10),
              categoriesAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, _) => Text(error.toString()),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Text('Chua co category de tao khoa hoc.');
                  }
                  _categoryId ??= categories.first.id;
                  return DropdownButtonFormField<String>(
                    initialValue: _categoryId,
                    decoration: const InputDecoration(
                      labelText: 'Category',
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
                        value == null || value.isEmpty ? 'Chon category' : null,
                  );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _level,
                      decoration: const InputDecoration(labelText: 'Level'),
                      items: const ['Beginner', 'Intermediate', 'Advanced']
                          .map(
                            (level) => DropdownMenuItem(
                              value: level,
                              child: Text(level),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _level = value ?? _level),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const ['Draft', 'Published', 'Archived']
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _status = value ?? _status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Gia',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');
                  if (price == null || price < 0) return 'Gia khong hop le';
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'Image URL',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                minLines: 3,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mo ta',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Khoa hoc noi bat'),
                value: _featured,
                onChanged: (value) => setState(() => _featured = value),
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Luu khoa hoc',
                icon: Icons.save_outlined,
                isLoading: isSaving,
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
        .read(adminCourseControllerProvider.notifier)
        .create(
          categoryId: _categoryId!,
          title: _titleController.text.trim(),
          slug: _slugController.text.trim(),
          level: _level,
          price: double.parse(_priceController.text.trim()),
          status: _status,
          isFeatured: _featured,
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          imageUrl: _imageController.text.trim().isEmpty
              ? null
              : _imageController.text.trim(),
        );

    if (!mounted) return;
    final state = ref.read(adminCourseControllerProvider);
    final message = state.hasError
        ? state.error.toString()
        : 'Da tao khoa hoc.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    if (!state.hasError) Navigator.of(context).pop();
  }

  String _slugify(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
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
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(child: Text('Chua co khoa hoc nao.')),
    );
  }
}
