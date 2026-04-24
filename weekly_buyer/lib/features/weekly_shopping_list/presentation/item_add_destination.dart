import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';
import 'item_entry_form.dart';
import 'week_header.dart';

class ItemAddDestination extends ConsumerWidget {
  const ItemAddDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekDateProvider);
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(selectedDate));
    final mealMenuSnapshot = ref.watch(mealMenuSnapshotProvider(selectedDate));
    final draft = ref.watch(itemAddDraftProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('商品追加')),
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
                      ref.read(selectedWeekDateProvider.notifier).state = dateOnly(
                        date,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '週の曜日を切り替えながら、その曜日に登録する商品をまとめて入力できます。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  for (final section in ShoppingSection.values.where(
                    (section) => !section.isDayIndependent,
                  )) ...[
                    _SectionPreviewCard(
                      key: ValueKey('section-card-${section.name}-$selectedDate'),
                      section: section,
                      selectedDate: selectedDate,
                      onDeleteItem: (item) async {
                        await ref
                            .read(weeklyShoppingRepositoryProvider)
                            .deleteItem(item.id);
                        ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
                      },
                      onDeleteMealMenuEntry: (entry) async {
                        await ref.read(weeklyShoppingRepositoryProvider).deleteMealMenuEntry(entry);
                        ref.invalidate(mealMenuSnapshotProvider(selectedDate));
                      },
                      onSaveMealMenuEntry: (entryText, mealSection) async {
                        await ref.read(weeklyShoppingRepositoryProvider).saveMealMenuEntry(
                              referenceDate: selectedDate,
                              section: mealSection,
                              menuText: entryText,
                            );
                        ref.invalidate(mealMenuSnapshotProvider(selectedDate));
                      },
                      items: data.weekdaySections
                          .firstWhere((entry) => entry.section == section)
                          .items,
                      mealMenuEntries: menuData.sections
                          .firstWhere((entry) => entry.section == section.mealSection)
                          .entries,
                      suggestions: menuData.suggestions,
                    ),
                    const SizedBox(height: 12),
                  ],
                  DailyMemoEditor(
                    key: ValueKey('daily-memo-$selectedDate'),
                    selectedDate: selectedDate,
                    initialText: data.dailyMemo?.memoText ?? '',
                    onSave: (memoText) async {
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
          onPressed: () => _openAddSheet(
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
}

class _SectionPreviewCard extends StatelessWidget {
  const _SectionPreviewCard({
    super.key,
    required this.section,
    required this.selectedDate,
    required this.items,
    required this.mealMenuEntries,
    required this.suggestions,
    required this.onDeleteItem,
    required this.onDeleteMealMenuEntry,
    required this.onSaveMealMenuEntry,
  });

  final ShoppingSection section;
  final DateTime selectedDate;
  final List<ShoppingItemEntry> items;
  final List<MealMenuEntry> mealMenuEntries;
  final List<MealMenuSuggestion> suggestions;
  final Future<void> Function(ShoppingItemEntry item) onDeleteItem;
  final Future<void> Function(int entryId) onDeleteMealMenuEntry;
  final Future<void> Function(String entryText, MealSection section) onSaveMealMenuEntry;

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
                    onPressed: () => onDeleteItem(item),
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
            MealMenuSectionEditor(
              key: ValueKey('meal-menu-editor-${section.name}-$selectedDate'),
              selectedDate: selectedDate,
              section: section.mealSection!,
              entries: mealMenuEntries,
              suggestions: suggestions,
              onSave: (menuText) => onSaveMealMenuEntry(menuText, section.mealSection!),
              onDelete: onDeleteMealMenuEntry,
            ),
          ],
        ),
      ),
    );
  }
}
