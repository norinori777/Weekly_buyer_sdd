import 'package:flutter/material.dart';

import '../domain/weekly_shopping_models.dart';

class ItemEditorRequest {
  const ItemEditorRequest({
    required this.name,
    required this.hiragana,
    required this.categoryId,
  });

  final String name;
  final String hiragana;
  final int? categoryId;
}

Future<ItemEditorRequest?> showItemEditorSheet({
  required BuildContext context,
  required List<CategoryEntry> categories,
  String title = '商品を編集',
  String initialName = '',
  String initialHiragana = '',
  int? initialCategoryId,
  String submitLabel = '保存',
  bool allowUncategorizedCategory = true,
}) {
  return showModalBottomSheet<ItemEditorRequest>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          top: 8,
        ),
        child: ItemEditorSheet(
          categories: categories,
          title: title,
          initialName: initialName,
          initialHiragana: initialHiragana,
          initialCategoryId: initialCategoryId,
          submitLabel: submitLabel,
          allowUncategorizedCategory: allowUncategorizedCategory,
          onCancel: () => Navigator.of(sheetContext).pop(),
          onSubmit: (request) => Navigator.of(sheetContext).pop(request),
        ),
      );
    },
  );
}

class ItemEditorSheet extends StatefulWidget {
  const ItemEditorSheet({
    super.key,
    required this.categories,
    required this.onSubmit,
    required this.title,
    this.onCancel,
    this.initialName = '',
    this.initialHiragana = '',
    this.initialCategoryId,
    this.submitLabel = '保存',
    this.allowUncategorizedCategory = true,
  });

  final List<CategoryEntry> categories;
  final String title;
  final String initialName;
  final String initialHiragana;
  final int? initialCategoryId;
  final ValueChanged<ItemEditorRequest> onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final bool allowUncategorizedCategory;

  @override
  State<ItemEditorSheet> createState() => _ItemEditorSheetState();
}

class _ItemEditorSheetState extends State<ItemEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _hiraganaController;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _hiraganaController = TextEditingController(text: widget.initialHiragana);
    _selectedCategoryId = _resolveInitialCategoryId();
  }

  @override
  void didUpdateWidget(covariant ItemEditorSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialName != widget.initialName) {
      _nameController.text = widget.initialName;
    }
    if (oldWidget.initialHiragana != widget.initialHiragana) {
      _hiraganaController.text = widget.initialHiragana;
    }
    if (oldWidget.initialCategoryId != widget.initialCategoryId ||
        oldWidget.categories != widget.categories) {
      _selectedCategoryId = _resolveInitialCategoryId();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hiraganaController.dispose();
    super.dispose();
  }

  int? _resolveInitialCategoryId() {
    if (widget.initialCategoryId != null &&
        widget.categories.any((category) => category.id == widget.initialCategoryId)) {
      return widget.initialCategoryId;
    }

    if (widget.categories.isEmpty) {
      return null;
    }

    return widget.categories.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '商品名'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _hiraganaController,
          decoration: const InputDecoration(labelText: 'ひらがな'),
        ),
        const SizedBox(height: 12),
        if (!widget.allowUncategorizedCategory && widget.categories.isEmpty)
          const Text('先にカテゴリを追加してください。')
        else
          DropdownButtonFormField<int?>(
            initialValue: _selectedCategoryId,
            decoration: const InputDecoration(labelText: 'カテゴリ'),
            items: [
              if (widget.allowUncategorizedCategory)
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('未分類'),
                ),
              for (final category in widget.categories)
                DropdownMenuItem<int?>(
                  value: category.id,
                  child: Text(category.name),
                ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
        const SizedBox(height: 16),
        Row(
          children: [
            if (widget.onCancel != null) ...[
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: FilledButton(
                onPressed: (!widget.allowUncategorizedCategory &&
                        (_selectedCategoryId == null || widget.categories.isEmpty))
                    ? null
                    : () {
                  final name = _nameController.text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  final hiragana = _hiraganaController.text.trim();
                  if (hiragana.isEmpty) {
                    return;
                  }

                  widget.onSubmit(
                    ItemEditorRequest(
                      name: name,
                      hiragana: hiragana,
                      categoryId: _selectedCategoryId,
                    ),
                  );
                },
                child: Text(widget.submitLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
