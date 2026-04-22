import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/weekly_shopping_models.dart';
import 'category_item_settings_notifier.dart';
import 'item_editor_destination.dart';

class CategoryItemSettingsDestination extends ConsumerWidget {
  const CategoryItemSettingsDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(categoryItemSettingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('カテゴリと商品'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'カテゴリ'),
              Tab(text: '商品'),
            ],
          ),
        ),
        body: settingsState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('読み込みに失敗しました: $error'),
            ),
          ),
          data: (data) {
            return TabBarView(
              children: [
                _CategoryTab(
                  state: data,
                  onAddPressed: () => _showCategoryEditor(
                    context: context,
                    title: 'カテゴリを追加',
                    submitLabel: '追加',
                    onSubmit: (name) => ref.read(categoryItemSettingsProvider.notifier).addCategory(name),
                  ),
                  onEditPressed: (category) => _showCategoryEditor(
                    context: context,
                    title: 'カテゴリを編集',
                    submitLabel: '保存',
                    initialName: category.name,
                    onSubmit: (name) => ref.read(categoryItemSettingsProvider.notifier).updateCategory(category, name),
                  ),
                  onDeletePressed: (category) => ref.read(categoryItemSettingsProvider.notifier).deleteCategory(category),
                ),
                _ItemTab(
                  state: data,
                  currentWeekItemIds: data.currentWeekItemIds,
                  onCategorySelected: (categoryId) => ref.read(categoryItemSettingsProvider.notifier).selectCategory(categoryId),
                  onAddPressed: () => _showItemEditor(
                    context: context,
                    state: data,
                    submitLabel: '追加',
                    onSubmit: (request) => ref.read(categoryItemSettingsProvider.notifier).addItem(
                          name: request.name,
                          categoryId: request.categoryId,
                        ),
                  ),
                  onEditPressed: (item) => _showItemEditor(
                    context: context,
                    state: data,
                    submitLabel: '保存',
                    initialName: item.name,
                    initialCategoryId: item.categoryId,
                    onSubmit: (request) => ref.read(categoryItemSettingsProvider.notifier).updateItem(
                          item,
                          name: request.name,
                          categoryId: request.categoryId,
                        ),
                  ),
                  onDeletePressed: (item) => ref.read(categoryItemSettingsProvider.notifier).deleteItem(item),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCategoryEditor({
    required BuildContext context,
    required String title,
    required String submitLabel,
    String initialName = '',
    required ValueChanged<String> onSubmit,
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CategoryEditorDialog(
          title: title,
          initialName: initialName,
          submitLabel: submitLabel,
          onCancel: () => Navigator.of(dialogContext).pop(),
          onSubmit: (name) => Navigator.of(dialogContext).pop(name),
        );
      },
    );

    if (result == null) {
      return;
    }

    onSubmit(result);
  }

  Future<void> _showItemEditor({
    required BuildContext context,
    required CategoryItemSettingsState state,
    required String submitLabel,
    String initialName = '',
    int? initialCategoryId,
    required ValueChanged<ItemEditorRequest> onSubmit,
  }) async {
    final request = await showItemEditorSheet(
      context: context,
      categories: state.categories,
      initialName: initialName,
      initialCategoryId: initialCategoryId ?? state.selectedCategoryId,
      submitLabel: submitLabel,
    );

    if (request == null) {
      return;
    }

    onSubmit(request);
  }
}

class _CategoryTab extends StatelessWidget {
  const _CategoryTab({
    required this.state,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final CategoryItemSettingsState state;
  final VoidCallback onAddPressed;
  final ValueChanged<CategoryEntry> onEditPressed;
  final ValueChanged<CategoryEntry> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          'カテゴリを追加・編集・削除できます。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('カテゴリを追加'),
        ),
        const SizedBox(height: 16),
        for (final category in state.categories) ...[
          Card(
            child: ListTile(
              title: Text(category.name),
              subtitle: Text(
                _categorySubtitle(state.items.where((item) => item.categoryId == category.id).length),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '編集',
                    onPressed: () => onEditPressed(category),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: _categoryDeleteTooltip(
                      state.items.where((item) => item.categoryId == category.id).length,
                    ),
                    child: IconButton(
                      tooltip: '削除',
                      onPressed: state.items.any((item) => item.categoryId == category.id)
                          ? null
                          : () => onDeletePressed(category),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.categories.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text('カテゴリがまだありません。')),
          ),
      ],
    );
  }

  String _categorySubtitle(int itemCount) {
    if (itemCount == 0) {
      return '商品がありません';
    }

    return '商品が $itemCount 件あるため削除できません';
  }

  String _categoryDeleteTooltip(int itemCount) {
    if (itemCount == 0) {
      return '削除';
    }

    return '商品があるため削除できません';
  }
}

class _ItemTab extends StatelessWidget {
  const _ItemTab({
    required this.state,
    required this.currentWeekItemIds,
    required this.onCategorySelected,
    required this.onAddPressed,
    required this.onEditPressed,
    required this.onDeletePressed,
  });

  final CategoryItemSettingsState state;
  final Set<int> currentWeekItemIds;
  final ValueChanged<int?> onCategorySelected;
  final VoidCallback onAddPressed;
  final ValueChanged<ItemCandidate> onEditPressed;
  final ValueChanged<ItemCandidate> onDeletePressed;

  @override
  Widget build(BuildContext context) {
    final selectedCategory = state.selectedCategory;
    final visibleItems = state.visibleItems;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          '商品を追加・編集・削除できます。',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        if (state.categories.isNotEmpty)
          DropdownButtonFormField<int?>(
            initialValue: selectedCategory?.id,
            decoration: const InputDecoration(labelText: 'カテゴリで絞り込み'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('すべて'),
              ),
              for (final category in state.categories)
                DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: onCategorySelected,
          )
        else
          const Text('先にカテゴリを追加してください。'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: state.categories.isEmpty ? null : onAddPressed,
          icon: const Icon(Icons.add),
          label: const Text('商品を追加'),
        ),
        const SizedBox(height: 16),
        for (final item in visibleItems) ...[
          Card(
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(_itemSubtitle(item)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '編集',
                    onPressed: () => onEditPressed(item),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  const SizedBox(width: 4),
                  Tooltip(
                    message: _deleteTooltip(item),
                    child: IconButton(
                      tooltip: '削除',
                      onPressed: currentWeekItemIds.contains(item.id)
                          ? null
                          : () => onDeletePressed(item),
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (state.categories.isNotEmpty && visibleItems.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: Text('このカテゴリの商品はまだありません。')),
          ),
      ],
    );
  }

  String _itemSubtitle(ItemCandidate item) {
    final categoryName = item.categoryName ?? '未分類';
    if (currentWeekItemIds.contains(item.id)) {
      return '$categoryName / 現在の購入週に含まれているため削除できません';
    }

    return categoryName;
  }

  String _deleteTooltip(ItemCandidate item) {
    if (currentWeekItemIds.contains(item.id)) {
      return 'この商品は現在の購入週に含まれているため削除できません';
    }

    return '削除';
  }
}

class _CategoryEditorDialog extends StatefulWidget {
  const _CategoryEditorDialog({
    required this.title,
    required this.initialName,
    required this.submitLabel,
    required this.onSubmit,
    this.onCancel,
  });

  final String title;
  final String initialName;
  final String submitLabel;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<_CategoryEditorDialog> createState() => _CategoryEditorDialogState();
}

class _CategoryEditorDialogState extends State<_CategoryEditorDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'カテゴリ名'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) {
              return;
            }
            widget.onSubmit(name);
          },
          child: Text(widget.submitLabel),
        ),
      ],
    );
  }
}
