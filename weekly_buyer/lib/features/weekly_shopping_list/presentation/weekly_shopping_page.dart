import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';

class WeeklyShoppingPage extends ConsumerStatefulWidget {
  const WeeklyShoppingPage({super.key});

  @override
  ConsumerState<WeeklyShoppingPage> createState() => _WeeklyShoppingPageState();
}

class _WeeklyShoppingPageState extends ConsumerState<WeeklyShoppingPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = dateOnly(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(_selectedDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Buyer'),
      ),
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('読み込みに失敗しました: $error'),
          ),
        ),
        data: (data) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              WeekHeader(
                weekRange: data.weekRange,
                selectedDate: _selectedDate,
                onDateSelected: (date) {
                  setState(() {
                    _selectedDate = dateOnly(date);
                  });
                },
              ),
              if (data.hiddenPurchasedCount > 0 || data.lastPurchasedItem != null) ...[
                const SizedBox(height: 16),
                UndoBanner(
                  hiddenPurchasedCount: data.hiddenPurchasedCount,
                  lastPurchasedItem: data.lastPurchasedItem,
                  onUndo: () async {
                    await ref.read(weeklyShoppingRepositoryProvider).undoLatestPurchase();
                    ref.invalidate(weeklyShoppingSnapshotProvider(_selectedDate));
                  },
                ),
              ],
              const SizedBox(height: 16),
              for (final section in data.sections) ...[
                ShoppingSectionView(
                  section: section.section,
                  items: section.items,
                  onAdd: () => _openAddSheet(section.section, data.candidates),
                  onTogglePurchased: (item) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(weeklyShoppingRepositoryProvider).togglePurchased(item.id);
                    ref.invalidate(weeklyShoppingSnapshotProvider(_selectedDate));
                    if (!mounted) {
                      return;
                    }
                    messenger
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${item.name} を購入済みにしました'),
                          action: SnackBarAction(
                            label: '元に戻す',
                            onPressed: () async {
                              await ref.read(weeklyShoppingRepositoryProvider).undoLatestPurchase();
                              ref.invalidate(weeklyShoppingSnapshotProvider(_selectedDate));
                            },
                          ),
                        ),
                      );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () async {
            final snapshotData = await ref.read(weeklyShoppingSnapshotProvider(_selectedDate).future);
            if (!mounted) {
              return;
            }
            await _openAddSheet(ShoppingSection.morning, snapshotData.candidates);
          },
          icon: const Icon(Icons.add),
          label: const Text('商品を追加'),
        ),
      ),
    );
  }

  Future<void> _openAddSheet(
    ShoppingSection initialSection,
    List<ItemCandidate> candidates,
  ) async {
    final request = await showModalBottomSheet<AddItemRequest>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return AddItemSheet(
          initialSection: initialSection,
          candidates: candidates,
        );
      },
    );

    if (request == null) {
      return;
    }

    await ref.read(weeklyShoppingRepositoryProvider).addItem(
          referenceDate: _selectedDate,
          request: request,
        );
    ref.invalidate(weeklyShoppingSnapshotProvider(_selectedDate));
  }
}

class WeekHeader extends StatelessWidget {
  const WeekHeader({
    super.key,
    required this.weekRange,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final WeekRange weekRange;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final weekDays = List.generate(7, (index) => weekRange.start.add(Duration(days: index)));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatWeekLabel(weekRange),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final day in weekDays) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        selected: dateOnly(day) == dateOnly(selectedDate),
                        label: Text(_weekdayLabel(day)),
                        onSelected: (_) => onDateSelected(day),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const weekdays = ['月', '火', '水', '木', '金', '土', '日'];
    return '${weekdays[date.weekday - 1]} ${date.month}/${date.day}';
  }
}

class UndoBanner extends StatelessWidget {
  const UndoBanner({
    super.key,
    required this.hiddenPurchasedCount,
    required this.lastPurchasedItem,
    required this.onUndo,
  });

  final int hiddenPurchasedCount;
  final ShoppingItemEntry? lastPurchasedItem;
  final Future<void> Function() onUndo;

  @override
  Widget build(BuildContext context) {
    final label = lastPurchasedItem == null ? '購入済みの商品があります' : '${lastPurchasedItem!.name} を購入済みにしました';

    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Text('$label ($hiddenPurchasedCount)', style: Theme.of(context).textTheme.bodyMedium),
            ),
            const SizedBox(width: 12),
            TextButton(onPressed: onUndo, child: const Text('元に戻す')),
          ],
        ),
      ),
    );
  }
}

class ShoppingSectionView extends StatelessWidget {
  const ShoppingSectionView({
    super.key,
    required this.section,
    required this.items,
    required this.onAdd,
    required this.onTogglePurchased,
  });

  final ShoppingSection section;
  final List<ShoppingItemEntry> items;
  final VoidCallback onAdd;
  final ValueChanged<ShoppingItemEntry> onTogglePurchased;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${section.label} ${items.length}件',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text('追加'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                section.isDayIndependent ? 'その他のリストはまだ空です。' : '${section.label}の買い物はまだありません。',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final item in items) ...[
                ShoppingItemTile(
                  item: item,
                  onTogglePurchased: () => onTogglePurchased(item),
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onTogglePurchased,
  });

  final ShoppingItemEntry item;
  final VoidCallback onTogglePurchased;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: sectionColor(context, item.section),
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(item.name),
        subtitle: Text('数量 ${item.quantity}'),
        trailing: IconButton(
          onPressed: onTogglePurchased,
          icon: const Icon(Icons.check_circle_outline),
          tooltip: '購入済みにする',
        ),
      ),
    );
  }
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({
    super.key,
    required this.initialSection,
    required this.candidates,
  });

  final ShoppingSection initialSection;
  final List<ItemCandidate> candidates;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late ShoppingSection _selectedSection;
  ItemCandidate? _selectedCandidate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _selectedSection = widget.initialSection;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    super.dispose();
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

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('商品を追加', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '商品名'),
            onChanged: (_) => setState(() {
              _selectedCandidate = null;
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '数量'),
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
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (filteredCandidates.isNotEmpty) ...[
            Text('候補', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final candidate = filteredCandidates[index];
                  return ListTile(
                    title: Text(candidate.name),
                    subtitle: Text(candidate.categoryName ?? 'カテゴリ未設定'),
                    selected: _selectedCandidate?.id == candidate.id,
                    onTap: () {
                      setState(() {
                        _selectedCandidate = candidate;
                        _nameController.text = candidate.name;
                        _quantityController.text = candidate.defaultQuantity.toString();
                      });
                    },
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
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    final name = _selectedCandidate?.name ?? _nameController.text.trim();
                    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
                    Navigator.of(context).pop(
                      AddItemRequest(
                        name: name,
                        quantity: quantity,
                        section: _selectedSection,
                        itemMasterId: _selectedCandidate?.id,
                        categoryId: _selectedCandidate?.categoryId,
                      ),
                    );
                  },
                  child: const Text('追加'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color sectionColor(BuildContext context, ShoppingSection section) {
  final colors = Theme.of(context).colorScheme;
  return switch (section) {
    ShoppingSection.morning => colors.primaryContainer,
    ShoppingSection.afternoon => colors.secondaryContainer,
    ShoppingSection.evening => colors.tertiaryContainer,
    ShoppingSection.other => colors.surfaceContainerHighest,
  };
}