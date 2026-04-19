import 'package:flutter/material.dart';

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
  });

  final List<ItemCandidate> candidates;
  final ItemAddDraft initialValue;
  final ValueChanged<ItemAddDraft>? onChanged;
  final ValueChanged<AddItemRequest> onSubmit;
  final VoidCallback? onCancel;
  final String submitLabel;
  final bool showCancelButton;
  final double maxCandidateListHeight;

  @override
  State<ItemEntryForm> createState() => _ItemEntryFormState();
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
            for (final section in ShoppingSection.values)
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
