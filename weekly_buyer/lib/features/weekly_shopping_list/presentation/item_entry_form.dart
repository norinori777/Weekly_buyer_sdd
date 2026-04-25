import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';

class ItemEntryForm extends StatefulWidget {
  const ItemEntryForm({
    super.key,
    required this.candidates,
    required this.initialValue,
    required this.onSubmit,
    this.onChanged,
    this.onCancel,
    this.submitLabel = '追加',
    this.showCancelButton = true,
    this.maxCandidateListHeight = 160,
    this.sectionOptions = ShoppingSection.values,
  });

  final List<ItemCandidate> candidates;
  final ItemAddDraft initialValue;
  final ValueChanged<ItemAddDraft>? onChanged;
  final ValueChanged<AddItemRequest> onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final bool showCancelButton;
  final double maxCandidateListHeight;
  final List<ShoppingSection> sectionOptions;

  @override
  State<ItemEntryForm> createState() => _ItemEntryFormState();
}

class MealMenuAddSheet extends StatefulWidget {
  const MealMenuAddSheet({
    super.key,
    required this.section,
    required this.onSubmit,
    this.onCancel,
  });

  final MealSection section;
  final ValueChanged<String> onSubmit;
  final VoidCallback? onCancel;

  @override
  State<MealMenuAddSheet> createState() => _MealMenuAddSheetState();
}

class _MealMenuAddSheetState extends State<MealMenuAddSheet> {
  late final TextEditingController _menuController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _menuController = TextEditingController();
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSaving) {
      return;
    }

    final normalized = _menuController.text.trim();
    if (normalized.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      widget.onSubmit(normalized);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_isSaving && _menuController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${widget.section.label}の料理メニュー追加',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      widget.onCancel?.call();
                    },
              child: const Text('キャンセル'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _menuController,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'メニュー',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: canSubmit ? _submit : null,
            child: Text(_isSaving ? '登録中...' : '登録する'),
          ),
        ),
      ],
    );
  }
}

class DailyMemoEditor extends StatefulWidget {
  const DailyMemoEditor({
    super.key,
    required this.selectedDate,
    required this.initialText,
    required this.onSave,
    this.enabled = true,
  });

  final DateTime selectedDate;
  final String initialText;
  final Future<void> Function(String memoText) onSave;
  final bool enabled;

  @override
  State<DailyMemoEditor> createState() => _DailyMemoEditorState();
}

class _DailyMemoEditorState extends State<DailyMemoEditor> {
  late final TextEditingController _memoController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(String memoText) async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.onSave(memoText);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = '${widget.selectedDate.month}/${widget.selectedDate.day}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('私用メモ', style: Theme.of(context).textTheme.titleMedium),
                ),
                Text(dateLabel, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '休みや夕飯不要など、その日の私用情報を残せます。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _memoController,
              minLines: 3,
              maxLines: 6,
              enabled: widget.enabled,
              decoration: const InputDecoration(
                labelText: 'メモ',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!widget.enabled)
              Text(
                '前の週では編集できません。',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              _memoController.clear();
                              await _handleSave('');
                            },
                      child: const Text('クリア'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              await _handleSave(_memoController.text);
                            },
                      child: Text(_isSaving ? '保存中...' : '保存'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class MealMenuSectionEditor extends ConsumerStatefulWidget {
  const MealMenuSectionEditor({
    super.key,
    required this.selectedDate,
    required this.section,
    required this.entries,
    required this.suggestions,
    required this.onSave,
    required this.onDelete,
  });

  final DateTime selectedDate;
  final MealSection section;
  final List<MealMenuEntry> entries;
  final List<MealMenuSuggestion> suggestions;
  final Future<void> Function(String menuText) onSave;
  final Future<void> Function(int entryId) onDelete;

  @override
  ConsumerState<MealMenuSectionEditor> createState() => _MealMenuSectionEditorState();
}

class _MealMenuSectionEditorState extends ConsumerState<MealMenuSectionEditor> {
  late final TextEditingController _menuController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _menuController = TextEditingController(
      text: ref.read(mealMenuDraftProvider(widget.selectedDate)).textFor(widget.section),
    );
  }

  @override
  void dispose() {
    _menuController.dispose();
    super.dispose();
  }

  void _updateDraft(String text) {
    ref.read(mealMenuDraftProvider(widget.selectedDate).notifier).state =
        ref.read(mealMenuDraftProvider(widget.selectedDate)).copyWithText(widget.section, text);
  }

  Future<void> _saveMenu(String menuText) async {
    if (_isSaving) {
      return;
    }

    final normalized = menuText.trim();
    if (normalized.isEmpty) {
      return;
    }

    setState(() {
      _isSaving = true;
    });
    try {
      await widget.onSave(normalized);
      if (!mounted) {
        return;
      }
      _menuController.clear();
      _updateDraft('');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  List<MealMenuSuggestion> _filteredSuggestions() {
    final query = _menuController.text.trim().toLowerCase();
    final suggestions = widget.suggestions.where((suggestion) {
      if (query.isEmpty) {
        return true;
      }
      return suggestion.text.toLowerCase().contains(query);
    }).toList();

    return suggestions.take(6).toList();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _filteredSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.section.label}の料理メニュー', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _menuController,
          decoration: const InputDecoration(
            labelText: 'メニューを追加',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateDraft(value);
            setState(() {});
          },
          onSubmitted: _saveMenu,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving
                    ? null
                    : () {
                        _menuController.clear();
                        _updateDraft('');
                        setState(() {});
                      },
                child: const Text('クリア'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : () => _saveMenu(_menuController.text),
                child: Text(_isSaving ? '保存中...' : '保存'),
              ),
            ),
          ],
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('候補', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final suggestion in suggestions)
                ActionChip(
                  label: Text(suggestion.text),
                  onPressed: _isSaving
                      ? null
                      : () async {
                          _menuController.text = suggestion.text;
                          _menuController.selection = TextSelection.fromPosition(
                            TextPosition(offset: suggestion.text.length),
                          );
                          _updateDraft(suggestion.text);
                          await _saveMenu(suggestion.text);
                        },
                ),
            ],
          ),
        ],
        if (widget.entries.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('登録済み', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final entry in widget.entries) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: IconButton(
                onPressed: _isSaving ? null : () => widget.onDelete(entry.id),
                icon: Icon(
                  Icons.close_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                tooltip: '削除',
                visualDensity: VisualDensity.compact,
              ),
              title: Text(entry.menuText),
            ),
            if (entry != widget.entries.last) const Divider(height: 1),
          ],
        ],
      ],
    );
  }
}

class _ItemEntryFormState extends State<ItemEntryForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late ShoppingSection _selectedSection;
  ItemCandidate? _selectedCandidate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue.name);
    _quantityController = TextEditingController(text: widget.initialValue.quantityText);
    _selectedSection = widget.initialValue.section;
    _selectedCandidate = _candidateById(widget.initialValue.selectedCandidateId);
  }

  @override
  void didUpdateWidget(covariant ItemEntryForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _syncFromInitialValue();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _syncFromInitialValue() {
    _nameController.text = widget.initialValue.name;
    _quantityController.text = widget.initialValue.quantityText;
    _selectedSection = widget.initialValue.section;
    _selectedCandidate = _candidateById(widget.initialValue.selectedCandidateId);
  }

  ItemCandidate? _candidateById(int? candidateId) {
    if (candidateId == null) {
      return null;
    }

    for (final candidate in widget.candidates) {
      if (candidate.id == candidateId) {
        return candidate;
      }
    }

    return null;
  }

  void _notifyChanged() {
    widget.onChanged?.call(_currentDraft());
  }

  ItemAddDraft _currentDraft() {
    return ItemAddDraft(
      name: _nameController.text,
      quantityText: _quantityController.text,
      section: _selectedSection,
      selectedCandidateId: _selectedCandidate?.id,
      categoryId: _selectedCandidate?.categoryId,
    );
  }

  void _selectCandidate(ItemCandidate candidate) {
    setState(() {
      _selectedCandidate = candidate;
      _nameController.text = candidate.name;
      _quantityController.text = candidate.defaultQuantity.toString();
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCandidates = widget.candidates.where((candidate) {
      final query = _nameController.text.trim().toLowerCase();
      if (query.isEmpty) {
        return true;
      }
      return candidate.name.toLowerCase().contains(query);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('商品を追加', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: '商品名'),
          onChanged: (_) {
            setState(() {
              _selectedCandidate = null;
            });
            _notifyChanged();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _quantityController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: '数量'),
          onChanged: (_) => _notifyChanged(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final section in widget.sectionOptions)
              ChoiceChip(
                selected: _selectedSection == section,
                label: Text(section.label),
                onSelected: (_) {
                  setState(() {
                    _selectedSection = section;
                  });
                  _notifyChanged();
                },
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredCandidates.isNotEmpty) ...[
          Text('候補', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: widget.maxCandidateListHeight,
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final candidate = filteredCandidates[index];
                return ListTile(
                  title: Text(candidate.name),
                  subtitle: Text(candidate.categoryName ?? 'カテゴリ未設定'),
                  selected: _selectedCandidate?.id == candidate.id,
                  onTap: () => _selectCandidate(candidate),
                );
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemCount: filteredCandidates.length,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            if (widget.showCancelButton) ...[
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
                onPressed: () {
                  final draft = _currentDraft();
                  final name = draft.name.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  final quantity = int.tryParse(draft.quantityText.trim()) ?? 1;
                  widget.onSubmit(
                    AddItemRequest(
                      name: name,
                      quantity: quantity,
                      section: draft.section,
                      itemMasterId: draft.selectedCandidateId,
                      categoryId: draft.categoryId,
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
