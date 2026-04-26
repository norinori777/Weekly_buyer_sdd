import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/widgets/weekly_buyer_brand_icon.dart';
import '../domain/weekly_shopping_models.dart';
import 'category_order_notifier.dart';

class CategoryOrderDestination extends ConsumerWidget {
  const CategoryOrderDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryOrderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeeklyBuyerBrandIcon(size: 28),
            SizedBox(width: 10),
            Text('カテゴリの並び順'),
          ],
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('読み込みに失敗しました: $error'),
          ),
        ),
        data: (data) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '購入リストで表示されるカテゴリの順序を並べ替えます。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              if (data.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      data.errorMessage!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  buildDefaultDragHandles: false,
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      elevation: 4,
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: child,
                    );
                  },
                  itemCount: data.items.length,
                  onReorder: (oldIndex, newIndex) {
                    ref.read(categoryOrderProvider.notifier).move(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final category = data.items[index];
                    return _CategoryOrderTile(
                      key: ValueKey(category.id),
                      category: category,
                      index: index,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: state.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (data) {
            return Row(
              children: [
                TextButton(
                  onPressed: data.isSaving
                      ? null
                      : () => ref.read(categoryOrderProvider.notifier).reset(),
                  child: const Text('リセット'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: data.isSaving ? null : () => Navigator.of(context).pop(),
                  child: const Text('キャンセル'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: data.isSaving || !data.isDirty
                      ? null
                      : () async {
                          await ref.read(categoryOrderProvider.notifier).save();
                          if (!context.mounted) {
                            return;
                          }
                          final savedState = ref.read(categoryOrderProvider).valueOrNull;
                          if (savedState != null &&
                              !savedState.isSaving &&
                              !savedState.isDirty &&
                              savedState.errorMessage == null) {
                            Navigator.of(context).pop();
                          }
                        },
                  child: data.isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('保存'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryOrderTile extends StatelessWidget {
  const _CategoryOrderTile({
    super.key,
    required this.category,
    required this.index,
  });

  final CategoryEntry category;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Semantics(
          label: '並べ替えハンドル ${category.name}',
          button: true,
          child: ReorderableDragStartListener(
            index: index,
            child: const Icon(Icons.drag_handle),
          ),
        ),
        title: Text(category.name),
        subtitle: Text('現在の表示順 ${category.sortOrder + 1}'),
      ),
    );
  }
}