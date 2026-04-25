import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_state_providers.dart';
import '../data/weekly_shopping_repository.dart';
import '../domain/weekly_shopping_models.dart';

final categoryItemSettingsProvider =
    AsyncNotifierProvider<CategoryItemSettingsNotifier, CategoryItemSettingsState>(
  CategoryItemSettingsNotifier.new,
);

class CategoryItemSettingsState {
  const CategoryItemSettingsState({
    required this.categories,
    required this.items,
    required this.currentWeekItemIds,
    required this.selectedCategoryId,
    this.isSaving = false,
    this.errorMessage,
  });

  final List<CategoryEntry> categories;
  final List<ItemCandidate> items;
  final Set<int> currentWeekItemIds;
  final int? selectedCategoryId;
  final bool isSaving;
  final String? errorMessage;

  List<ItemCandidate> get visibleItems {
    if (selectedCategoryId == null) {
      return items;
    }

    return items.where((item) => item.categoryId == selectedCategoryId).toList();
  }

  bool isItemInCurrentWeek(int itemId) {
    return currentWeekItemIds.contains(itemId);
  }

  CategoryEntry? get selectedCategory {
    if (selectedCategoryId == null) {
      return null;
    }

    for (final category in categories) {
      if (category.id == selectedCategoryId) {
        return category;
      }
    }

    return null;
  }

  CategoryItemSettingsState copyWith({
    List<CategoryEntry>? categories,
    List<ItemCandidate>? items,
    Set<int>? currentWeekItemIds,
    Object? selectedCategoryId = _unset,
    bool? isSaving,
    Object? errorMessage = _unset,
  }) {
    return CategoryItemSettingsState(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      currentWeekItemIds: currentWeekItemIds ?? this.currentWeekItemIds,
      selectedCategoryId: identical(selectedCategoryId, _unset)
          ? this.selectedCategoryId
          : selectedCategoryId as int?,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: identical(errorMessage, _unset) ? this.errorMessage : errorMessage as String?,
    );
  }
}

const _unset = Object();

class CategoryItemSettingsNotifier extends AsyncNotifier<CategoryItemSettingsState> {
  @override
  Future<CategoryItemSettingsState> build() async {
    return _loadState();
  }

  Future<CategoryItemSettingsState> _loadState({int? selectedCategoryId}) async {
    final repository = ref.read(weeklyShoppingRepositoryProvider);
    final categories = await repository.loadCategories();
    final items = await repository.loadItemMasters();
    final currentWeekItemIds = await repository.loadCurrentWeekItemMasterIds(
      ref.read(selectedWeekDateProvider),
    );
    final effectiveCategoryId = _resolveSelectedCategoryId(
      categories,
      selectedCategoryId ?? state.valueOrNull?.selectedCategoryId,
    );

    return CategoryItemSettingsState(
      categories: List.unmodifiable(categories),
      items: List.unmodifiable(items),
      currentWeekItemIds: currentWeekItemIds,
      selectedCategoryId: effectiveCategoryId,
    );
  }

  int? _resolveSelectedCategoryId(
    List<CategoryEntry> categories,
    int? selectedCategoryId,
  ) {
    if (categories.isEmpty) {
      return null;
    }

    if (selectedCategoryId != null && categories.any((category) => category.id == selectedCategoryId)) {
      return selectedCategoryId;
    }

    return categories.first.id;
  }

  Future<void> selectCategory(int? categoryId) async {
    final current = state.valueOrNull;
    if (current == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        selectedCategoryId: categoryId,
        errorMessage: null,
      ),
    );
  }

  Future<void> reload({int? selectedCategoryId}) async {
    state = const AsyncLoading<CategoryItemSettingsState>();
    state = AsyncData(await _loadState(selectedCategoryId: selectedCategoryId));
  }

  Future<void> addCategory(String name) async {
    await _mutate((repository) async {
      final created = await repository.addCategory(name);
      await _reloadAfterMutation(selectedCategoryId: created.id);
    });
  }

  Future<void> updateCategory(CategoryEntry category, String name) async {
    await _mutate((repository) async {
      await repository.updateCategory(categoryId: category.id, name: name);
      await _reloadAfterMutation();
    });
  }

  Future<void> deleteCategory(CategoryEntry category) async {
    await _mutate((repository) async {
      await repository.deleteCategory(category.id);
      await _reloadAfterMutation();
    });
  }

  Future<void> addItem({
    required String name,
    required String hiragana,
    required int? categoryId,
  }) async {
    await _mutate((repository) async {
      final created = await repository.addItemMaster(
        name: name,
        hiragana: hiragana,
        categoryId: categoryId,
      );
      await _reloadAfterMutation(selectedCategoryId: created.categoryId ?? state.valueOrNull?.selectedCategoryId);
    });
  }

  Future<void> updateItem(
    ItemCandidate item, {
    required String name,
    required String hiragana,
    required int? categoryId,
  }) async {
    await _mutate((repository) async {
      await repository.updateItemMaster(
        itemId: item.id,
        name: name,
        hiragana: hiragana,
        categoryId: categoryId,
      );
      await _reloadAfterMutation(selectedCategoryId: categoryId);
    });
  }

  Future<void> deleteItem(ItemCandidate item) async {
    await _mutate((repository) async {
      await repository.deleteItemMaster(
        item.id,
        referenceDate: ref.read(selectedWeekDateProvider),
      );
      await _reloadAfterMutation();
    });
  }

  Future<void> _mutate(Future<void> Function(WeeklyShoppingRepository repository) action) async {
    final current = state.valueOrNull;
    if (current == null || current.isSaving) {
      return;
    }

    final repository = ref.read(weeklyShoppingRepositoryProvider);
    state = AsyncData(
      current.copyWith(
        isSaving: true,
        errorMessage: null,
      ),
    );

    try {
      await action(repository);
    } catch (error) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          errorMessage: error.toString(),
        ),
      );
      rethrow;
    }
  }

  Future<void> _reloadAfterMutation({int? selectedCategoryId}) async {
    final refreshed = await _loadState(selectedCategoryId: selectedCategoryId);
    state = AsyncData(refreshed.copyWith(isSaving: false, errorMessage: null));
    ref.invalidate(weeklyShoppingSnapshotProvider(ref.read(selectedWeekDateProvider)));
  }
}
