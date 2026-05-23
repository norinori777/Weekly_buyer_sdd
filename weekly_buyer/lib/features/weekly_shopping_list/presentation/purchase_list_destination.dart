import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/widgets/weekly_buyer_brand_icon.dart';
import '../domain/weekly_shopping_models.dart';
import 'item_editor_destination.dart';
import 'weekly_shopping_page.dart' show UndoBanner;

class PurchaseListDestination extends ConsumerWidget {
  const PurchaseListDestination({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedWeekDateProvider);
    final isReadOnly = ref.watch(isPriorWeekViewProvider);
    final snapshot = ref.watch(weeklyShoppingSnapshotProvider(selectedDate));
    final bottomBanner = snapshot.maybeWhen(
      data: (data) {
        if (isReadOnly) {
          return const SizedBox.shrink();
        }
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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WeeklyBuyerBrandIcon(size: 28),
            SizedBox(width: 10),
            Text('購入リスト'),
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
          final showBottomBanner = !isReadOnly && (data.hiddenPurchasedCount > 0 || data.lastPurchasedItem != null);

          return ListView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, showBottomBanner ? 112 : 16),
            children: [
              if (isReadOnly) ...[
                Text(
                  '前の週を表示中のため、購入リストは表示のみです。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
              ],
              for (final group in data.categoryGroups) ...[
                _CategoryGroupCard(
                  group: group,
                  isReadOnly: isReadOnly,
                  onRegisterUncategorized: (item) => _registerUncategorizedItem(
                    context: context,
                    ref: ref,
                    selectedDate: selectedDate,
                    isReadOnly: isReadOnly,
                    categories: data.categories,
                    item: item,
                  ),
                  onTogglePurchased: (item) async {
                    if (isReadOnly) {
                      return;
                    }
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
              if (data.categoryGroups.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 32),
                  child: Center(child: Text('今週の購入リストはまだありません。')),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: bottomBanner,
    );
  }

  Future<void> _registerUncategorizedItem({
    required BuildContext context,
    required WidgetRef ref,
    required DateTime selectedDate,
    required bool isReadOnly,
    required List<CategoryEntry> categories,
    required ShoppingItemEntry item,
  }) async {
    if (isReadOnly) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    if (categories.isEmpty) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(content: Text('先にカテゴリを追加してください。')),
        );
      return;
    }

    final request = await showItemEditorSheet(
      context: context,
      categories: categories,
      title: '商品マスターに登録',
      initialName: item.name,
      initialCategoryId: categories.first.id,
      submitLabel: '登録',
      allowUncategorizedCategory: false,
    );

    if (request == null) {
      return;
    }

    final repository = ref.read(weeklyShoppingRepositoryProvider);
    await repository.registerUncategorizedPurchaseItem(
      weeklyListItemId: item.id,
      name: request.name,
      hiragana: request.hiragana,
      categoryId: request.categoryId!,
    );

    ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));
    if (!context.mounted) {
      return;
    }

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text('${request.name} を商品マスターに登録しました')),
      );
  }
}

class _CategoryGroupCard extends StatelessWidget {
  const _CategoryGroupCard({
    required this.group,
    required this.isReadOnly,
    required this.onRegisterUncategorized,
    required this.onTogglePurchased,
  });

  final ShoppingCategoryGroup group;
  final bool isReadOnly;
  final Future<void> Function(ShoppingItemEntry) onRegisterUncategorized;
  final Future<void> Function(ShoppingItemEntry) onTogglePurchased;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${group.categoryName} ${group.items.length}件',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final item in group.items) ...[
              if (isReadOnly)
                _PurchaseItemTile(
                  item: item,
                  isReadOnly: true,
                  onTogglePurchased: () {},
                )
              else
                Dismissible(
                  key: ValueKey('shopping-item-${item.id}'),
                  direction: DismissDirection.endToStart,
                  secondaryBackground: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.archive_outlined, color: Theme.of(context).colorScheme.onErrorContainer),
                            const SizedBox(width: 8),
                            Text(
                              '購入済み',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  background: const SizedBox.shrink(),
                  confirmDismiss: (_) async {
                    await onTogglePurchased(item);
                    return true;
                  },
                  child: _PurchaseItemTile(
                    item: item,
                    isReadOnly: false,
                    onLongPress: item.categoryId == null ? () => onRegisterUncategorized(item) : null,
                    onTogglePurchased: () => onTogglePurchased(item),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _PurchaseItemTile extends StatelessWidget {
  const _PurchaseItemTile({
    required this.item,
    required this.isReadOnly,
    this.onLongPress,
    required this.onTogglePurchased,
  });

  final ShoppingItemEntry item;
  final bool isReadOnly;
  final VoidCallback? onLongPress;
  final VoidCallback onTogglePurchased;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(item.name),
        subtitle: Text(
          item.purchaseDate != null
              ? '数量 ${item.quantity}\u3000${formatPurchaseDate(item.purchaseDate!)}'
              : '数量 ${item.quantity}',
        ),
        onLongPress: onLongPress,
        trailing: IconButton(
          onPressed: isReadOnly ? null : onTogglePurchased,
          icon: const Icon(Icons.check_circle_outline),
          tooltip: '購入済みにする',
        ),
      ),
    );
  }
}
