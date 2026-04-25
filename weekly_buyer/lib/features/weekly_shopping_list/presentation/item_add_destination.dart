import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/widgets/weekly_buyer_brand_icon.dart';
import '../domain/weekly_shopping_models.dart';
import 'item_entry_form.dart';
import 'week_header.dart';

class ItemAddDestination extends ConsumerWidget {
  const ItemAddDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weekView = ref.watch(weekViewStateProvider);
    final selectedDate = weekView.selectedDate;
    final isReadOnly = weekView.isReadOnly;
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(selectedDate));
    final mealMenuSnapshot = ref.watch(mealMenuSnapshotProvider(selectedDate));
    final draft = ref.watch(itemAddDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeeklyBuyerBrandIcon(size: 28),
            SizedBox(width: 10),
            Text('商品追加'),
          ],
        ),
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
          return mealMenuSnapshot.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('読み込みに失敗しました: $error'),
              ),
            ),
            data: (menuData) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                children: [
                  WeekHeader(
                    weekRange: data.weekRange,
                    selectedDate: selectedDate,
                    onDateSelected: (date) {
                      selectWeekDate(ref, date);
                    },
                    onPreviousWeek: () => goToPreviousWeek(ref),
                    onReturnToDefaultWeek: isReadOnly ? () => resetSelectedWeekToDefault(ref) : null,
                    isReadOnly: isReadOnly,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '週の曜日を切り替えながら、その曜日に登録する商品をまとめて入力できます。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (isReadOnly) ...[
                    const SizedBox(height: 8),
                    Text(
                      '前の週を表示中のため、表示のみになります。',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 16),
                  for (final section in ShoppingSection.values.where(
                    (section) => !section.isDayIndependent,
                  )) ...[
                    _SectionPreviewCard(
                      key: ValueKey('section-card-${section.name}-$selectedDate'),
                      section: section,
                      isReadOnly: isReadOnly,
                      onDeleteItem: (item) async {
                        if (isReadOnly) {
                          return;
                        }
                        await ref
                            .read(weeklyShoppingRepositoryProvider)
                            .deleteItem(item.id);
                        ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
                      },
                      onAddMealMenuEntry: (mealSection) async {
                        if (isReadOnly) {
                          return;
                        }
                        await _openMealMenuSheet(
                          context: context,
                          ref: ref,
                          selectedDate: selectedDate,
                          section: mealSection,
                        );
                      },
                      onDeleteMealMenuEntry: (entry) async {
                        if (isReadOnly) {
                          return;
                        }
                        await ref
                            .read(weeklyShoppingRepositoryProvider)
                            .deleteMealMenuEntry(entry.id);
                        ref.invalidate(mealMenuSnapshotProvider(selectedDate));
                      },
                      items: data.weekdaySections
                          .firstWhere((entry) => entry.section == section)
                          .items,
                      mealMenuEntries: menuData.sections
                          .firstWhere((entry) => entry.section == section.mealSection)
                          .entries,
                    ),
                    const SizedBox(height: 12),
                  ],
                  DailyMemoEditor(
                    key: ValueKey('daily-memo-$selectedDate'),
                    selectedDate: selectedDate,
                    initialText: data.dailyMemo?.memoText ?? '',
                    enabled: !isReadOnly,
                    onSave: (memoText) async {
                      if (isReadOnly) {
                        return;
                      }
                      await ref.read(weeklyShoppingRepositoryProvider).saveDailyMemo(
                            referenceDate: selectedDate,
                            memoText: memoText,
                          );
                      ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FilledButton.icon(
          onPressed: isReadOnly
              ? null
              : () => _openAddSheet(
                    context: context,
                    ref: ref,
                    selectedDate: selectedDate,
                    candidates: snapshot.maybeWhen(
                      data: (data) => data.candidates,
                      orElse: () => const [],
                    ),
                    draft: draft,
                  ),
          icon: const Icon(Icons.add),
          label: const Text('商品を追加'),
        ),
      ),
    );
  }

  Future<void> _openAddSheet({
    required BuildContext context,
    required WidgetRef ref,
    required DateTime selectedDate,
    required List<ItemCandidate> candidates,
    required ItemAddDraft draft,
  }) async {
    final request = await showModalBottomSheet<AddItemRequest>(
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
          child: SingleChildScrollView(
            child: ItemEntryForm(
              candidates: candidates,
              initialValue: draft,
              sectionOptions: ShoppingSection.values
                  .where((section) => !section.isDayIndependent)
                  .toList(),
              submitLabel: '登録する',
              maxCandidateListHeight: 220,
              onChanged: (nextDraft) {
                ref.read(itemAddDraftProvider.notifier).state = nextDraft;
              },
              onCancel: () => Navigator.of(sheetContext).pop(),
              onSubmit: (request) => Navigator.of(sheetContext).pop(request),
            ),
          ),
        );
      },
    );

    if (request == null) {
      return;
    }

    await ref
        .read(weeklyShoppingRepositoryProvider)
        .addItem(referenceDate: selectedDate, request: request);
    ref.read(itemAddDraftProvider.notifier).state = ItemAddDraft(
      section: request.section,
    );
    ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
  }

  Future<void> _openMealMenuSheet({
    required BuildContext context,
    required WidgetRef ref,
    required DateTime selectedDate,
    required MealSection section,
  }) async {
    final menuText = await showModalBottomSheet<String>(
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
          child: SingleChildScrollView(
            child: MealMenuAddSheet(
              section: section,
              onCancel: () => Navigator.of(sheetContext).pop(),
              onSubmit: (value) => Navigator.of(sheetContext).pop(value),
            ),
          ),
        );
      },
    );

    if (menuText == null) {
      return;
    }

    await ref.read(weeklyShoppingRepositoryProvider).saveMealMenuEntry(
          referenceDate: selectedDate,
          section: section,
          menuText: menuText,
        );
    ref.invalidate(mealMenuSnapshotProvider(selectedDate));
  }
}

class _SectionPreviewCard extends StatelessWidget {
  const _SectionPreviewCard({
    super.key,
    required this.section,
    required this.items,
    required this.mealMenuEntries,
    required this.isReadOnly,
    required this.onDeleteItem,
    required this.onAddMealMenuEntry,
    required this.onDeleteMealMenuEntry,
  });

  final ShoppingSection section;
  final List<ShoppingItemEntry> items;
  final List<MealMenuEntry> mealMenuEntries;
  final bool isReadOnly;
  final Future<void> Function(ShoppingItemEntry item) onDeleteItem;
  final Future<void> Function(MealSection section) onAddMealMenuEntry;
  final Future<void> Function(MealMenuEntry entry) onDeleteMealMenuEntry;

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
                  onPressed: isReadOnly || section.mealSection == null
                      ? null
                      : () => onAddMealMenuEntry(section.mealSection!),
                  icon: const Icon(Icons.add),
                  label: const Text('料理メニュー追加'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(
                section.isDayIndependent
                    ? 'その他の登録はまだありません。'
                    : '${section.label}の登録はまだありません。',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final item in items) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  title: Text(item.name),
                  subtitle: Text('数量 ${item.quantity}'),
                  trailing: IconButton(
                    tooltip: '削除',
                    onPressed: isReadOnly ? null : () => onDeleteItem(item),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const Divider(height: 1),
              ],
            const SizedBox(height: 16),
            Text(
              '${section.label}の料理メニュー',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (isReadOnly) ...[
              Text(
                '前の週では編集できません。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
            ],
            if (mealMenuEntries.isEmpty)
              Text(
                'まだ登録されていません。',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final entry in mealMenuEntries) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: Text(entry.menuText)),
                      IconButton(
                        tooltip: '削除',
                        onPressed: isReadOnly
                            ? null
                            : () => onDeleteMealMenuEntry(entry),
                        icon: Icon(
                          Icons.close_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}
