import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../domain/weekly_shopping_models.dart';

final categoryOrderProvider =
    AsyncNotifierProvider<CategoryOrderNotifier, CategoryOrderState>(
  CategoryOrderNotifier.new,
);

class CategoryOrderState {
  const CategoryOrderState({
    required this.items,
    this.isSaving = false,
    this.isDirty = false,
    this.errorMessage,
  });

  final List<CategoryEntry> items;
  final bool isSaving;
  final bool isDirty;
  final String? errorMessage;

  CategoryOrderState copyWith({
    List<CategoryEntry>? items,
    bool? isSaving,
    bool? isDirty,
    String? errorMessage,
  }) {
    return CategoryOrderState(
      items: items ?? this.items,
      isSaving: isSaving ?? this.isSaving,
      isDirty: isDirty ?? this.isDirty,
      errorMessage: errorMessage,
    );
  }
}

class CategoryOrderNotifier extends AsyncNotifier<CategoryOrderState> {
  late List<CategoryEntry> _initialItems;

  @override
  Future<CategoryOrderState> build() async {
    final categories = await ref.read(weeklyShoppingRepositoryProvider).loadCategories();
    _initialItems = List.unmodifiable(categories);
    return CategoryOrderState(items: _initialItems);
  }

  Future<void> move(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null) {
      return;
    }

    final adjustedNewIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final items = [...current.items];
    final moved = items.removeAt(oldIndex);
    items.insert(adjustedNewIndex, moved);

    state = AsyncData(
      current.copyWith(
        items: List.unmodifiable(items),
        isDirty: !_sameOrder(items, _initialItems),
        errorMessage: null,
      ),
    );
  }

  Future<void> reset() async {
    final categories = await ref.read(weeklyShoppingRepositoryProvider).loadCategories();
    _initialItems = List.unmodifiable(categories);
    state = AsyncData(
      CategoryOrderState(items: _initialItems),
    );
  }

  Future<void> save() async {
    final current = state.value;
    if (current == null || current.isSaving || !current.isDirty) {
      return;
    }

    final repository = ref.read(weeklyShoppingRepositoryProvider);
    final selectedDate = ref.read(selectedWeekDateProvider);

    state = AsyncData(
      current.copyWith(
        isSaving: true,
        errorMessage: null,
      ),
    );

    try {
      await repository.updateCategoryOrder(
        [
          for (final entry in current.items.asMap().entries)
            CategoryOrderUpdate(
              categoryId: entry.value.id,
              sortOrder: entry.key,
            ),
        ],
      );
      ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate));

      final refreshed = await repository.loadCategories();
      _initialItems = List.unmodifiable(refreshed);
      state = AsyncData(
        CategoryOrderState(items: _initialItems),
      );
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          isDirty: true,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  bool _sameOrder(List<CategoryEntry> left, List<CategoryEntry> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index].id != right[index].id) {
        return false;
      }
    }
    return true;
  }
}