import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';
import 'item_entry_form.dart';
import 'weekly_shopping_page.dart' show ShoppingSectionView, UndoBanner, WeekHeader;

class PurchaseListDestination extends ConsumerWidget {
  const PurchaseListDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekDateProvider);
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(selectedDate));
    final bottomBanner = snapshot.maybeWhen(
      data: (data) {
        if (data.hiddenPurchasedCount == 0 && data.lastPurchasedItem == null) {
          return const SizedBox.shrink();
        }

        return SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: UndoBanner(
            hiddenPurchasedCount: data.hiddenPurchasedCount,
            lastPurchasedItem: data.lastPurchasedItem,
            onUndo: () async {
              await ref.read(weeklyShoppingRepositoryProvider).undoLatestPurchase(selectedDate);
              ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
            },
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('購入リスト'),
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
                selectedDate: selectedDate,
                onDateSelected: (date) {
                  ref.read(selectedWeekDateProvider.notifier).state = dateOnly(date);
                },
              ),
              const SizedBox(height: 16),
              for (final section in data.sections) ...[
                ShoppingSectionView(
                  section: section.section,
                  items: section.items,
                  onAdd: () => _openAddSheet(
                    context: context,
                    ref: ref,
                    initialSection: section.section,
                    candidates: data.candidates,
                  ),
                  onTogglePurchased: (item) async {
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(weeklyShoppingRepositoryProvider).togglePurchased(item.id);
                    ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
                    if (!context.mounted) {
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
                              await ref.read(weeklyShoppingRepositoryProvider).undoLatestPurchase(selectedDate);
                              ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
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
      bottomNavigationBar: bottomBanner,
    );
  }

  Future<void> _openAddSheet({
    required BuildContext context,
    required WidgetRef ref,
    required ShoppingSection initialSection,
    required List<ItemCandidate> candidates,
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
              initialValue: ItemAddDraft(section: initialSection),
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

    final selectedDate = ref.read(selectedWeekDateProvider);
    await ref.read(weeklyShoppingRepositoryProvider).addItem(
          referenceDate: selectedDate,
          request: request,
        );
    ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
  }
}
