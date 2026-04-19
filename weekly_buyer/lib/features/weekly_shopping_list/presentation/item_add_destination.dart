import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';
import 'item_entry_form.dart';

class ItemAddDestination extends ConsumerWidget {
  const ItemAddDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekDateProvider);
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(selectedDate));
    final draft = ref.watch(itemAddDraftProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('商品追加'),
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
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '選択中の週: ${formatWeekLabel(data.weekRange)}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'この画面では、候補から選んでそのまま商品を追加できます。',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ItemEntryForm(
                    candidates: data.candidates,
                    initialValue: draft,
                    submitLabel: '保存して購入リストへ戻る',
                    showCancelButton: false,
                    maxCandidateListHeight: 220,
                    onChanged: (nextDraft) {
                      ref.read(itemAddDraftProvider.notifier).state = nextDraft;
                    },
                    onSubmit: (request) async {
                      await ref.read(weeklyShoppingRepositoryProvider).addItem(
                            referenceDate: selectedDate,
                            request: request,
                          );
                      ref.read(itemAddDraftProvider.notifier).state = ItemAddDraft(section: request.section);
                      ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
                      ref.read(previousShoppingDestinationProvider.notifier).state = MainShellDestination.purchaseList;
                      ref.read(mainShellDestinationProvider.notifier).state = MainShellDestination.purchaseList;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.read(mainShellDestinationProvider.notifier).state = MainShellDestination.purchaseList;
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('購入リストへ戻る'),
              ),
            ],
          );
        },
      ),
    );
  }
}
