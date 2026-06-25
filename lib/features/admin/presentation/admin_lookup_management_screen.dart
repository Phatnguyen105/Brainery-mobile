import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../courses/data/course_models.dart';
import 'admin_lookup_controller.dart';

class AdminLookupManagementScreen extends ConsumerStatefulWidget {
  const AdminLookupManagementScreen({super.key});

  @override
  ConsumerState<AdminLookupManagementScreen> createState() =>
      _AdminLookupManagementScreenState();
}

class _AdminLookupManagementScreenState
    extends ConsumerState<AdminLookupManagementScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final lookupAsync = ref.watch(adminLookupControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Category va tag'),
        actions: [
          IconButton(
            tooltip: 'Lam moi',
            onPressed: () =>
                ref.read(adminLookupControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: Text(_tab == 0 ? 'Them category' : 'Them tag'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    icon: Icon(Icons.category_outlined),
                    label: Text('Category'),
                  ),
                  ButtonSegment(
                    value: 1,
                    icon: Icon(Icons.sell_outlined),
                    label: Text('Tag'),
                  ),
                ],
                selected: {_tab},
                onSelectionChanged: (value) =>
                    setState(() => _tab = value.first),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(adminLookupControllerProvider.notifier).refresh(),
                child: lookupAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _ErrorList(
                    message: error.toString(),
                    onRetry: () => ref
                        .read(adminLookupControllerProvider.notifier)
                        .refresh(),
                  ),
                  data: (state) => _LookupList(
                    items: _tab == 0 ? state.categories : state.tags,
                    emptyText: _tab == 0
                        ? 'Chua co category nao.'
                        : 'Chua co tag nao.',
                    onEdit: (item) => _openForm(context, item: item),
                    onDelete: (item) => _delete(item),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {CategoryModel? item}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _LookupFormSheet(
        type: _tab == 0 ? LookupType.category : LookupType.tag,
        item: item,
      ),
    );
  }

  Future<void> _delete(CategoryModel item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xoa muc nay?'),
        content: Text(item.name),
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
    if (confirmed != true) return;

    final controller = ref.read(adminLookupControllerProvider.notifier);
    if (_tab == 0) {
      await controller.deleteCategory(item.id);
    } else {
      await controller.deleteTag(item.id);
    }
    if (!mounted) return;
    final state = ref.read(adminLookupControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : 'Da xoa.'),
      ),
    );
  }
}

class _LookupList extends StatelessWidget {
  const _LookupList({
    required this.items,
    required this.emptyText,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CategoryModel> items;
  final String emptyText;
  final ValueChanged<CategoryModel> onEdit;
  final ValueChanged<CategoryModel> onDelete;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(32),
        children: [Center(child: Text(emptyText))],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.label_outline, color: AppColors.primary),
            title: Text(item.name),
            subtitle: Text(item.slug ?? ''),
            trailing: Wrap(
              spacing: 4,
              children: [
                IconButton(
                  tooltip: 'Sua',
                  onPressed: () => onEdit(item),
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Xoa',
                  onPressed: () => onDelete(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum LookupType { category, tag }

class _LookupFormSheet extends ConsumerStatefulWidget {
  const _LookupFormSheet({required this.type, this.item});

  final LookupType type;
  final CategoryModel? item;

  @override
  ConsumerState<_LookupFormSheet> createState() => _LookupFormSheetState();
}

class _LookupFormSheetState extends ConsumerState<_LookupFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  bool _slugTouched = false;

  bool get _isCategory => widget.type == LookupType.category;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.item?.name ?? '';
    _slugController.text = widget.item?.slug ?? '';
    _nameController.addListener(() {
      if (_slugTouched) return;
      _slugController.text = _slugify(_nameController.text);
    });
    _slugController.addListener(() => _slugTouched = true);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(adminLookupControllerProvider).isLoading;
    final title = widget.item == null
        ? (_isCategory ? 'Them category' : 'Them tag')
        : (_isCategory ? 'Sua category' : 'Sua tag');

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Ten',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Nhap ten' : null,
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
    final controller = ref.read(adminLookupControllerProvider.notifier);
    final id = widget.item?.id;
    final name = _nameController.text.trim();
    final slug = _slugController.text.trim();

    if (_isCategory) {
      await controller.saveCategory(id: id, name: name, slug: slug);
    } else {
      await controller.saveTag(id: id, name: name, slug: slug);
    }

    if (!mounted) return;
    final state = ref.read(adminLookupControllerProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.hasError ? state.error.toString() : 'Da luu.'),
      ),
    );
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
