import 'package:drift/drift.dart';

import '../../../app/app_database.dart' hide DailyMemo, MealMenuEntry;
import '../domain/weekly_shopping_models.dart';

class WeeklyShoppingRepository {
  WeeklyShoppingRepository(this._database);

  final AppDatabase _database;

  Future<List<CategoryEntry>> loadCategories() {
    return _loadCategories();
  }

  Future<List<ItemCandidate>> loadItemMasters() {
    return _loadItemMasters();
  }

  Future<DailyMemoEntry?> loadDailyMemo(DateTime referenceDate) async {
    return _loadDailyMemo(referenceDate);
  }

  Future<MealMenuDaySnapshot> loadMealMenuSnapshot(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weekEnd = endOfWeek(referenceDate);
    final dailyMealMenu = await _loadDailyMealMenu(referenceDate);
    final entries = await _loadMealMenuEntries(dailyMealMenu?.id);
    final groupedSections = MealSection.values
        .map(
          (section) => MealMenuSectionEntries(
            section: section,
            entries: entries.where((entry) => entry.section == section).toList(),
          ),
        )
        .toList();

    return MealMenuDaySnapshot(
      weekRange: WeekRange(start: weekStart, end: weekEnd),
      selectedDate: dateOnly(referenceDate),
      sections: groupedSections,
      suggestions: await loadMealMenuSuggestions(),
    );
  }

  Future<void> saveDailyMemo({
    required DateTime referenceDate,
    required String memoText,
  }) async {
    final weekStart = startOfWeek(referenceDate);
    final weekday = dateOnly(referenceDate).weekday;
    final normalizedText = memoText;

    await _database.transaction(() async {
      final existing = await (_database.select(_database.dailyMemos)
            ..where(
              (table) =>
                  table.weekStartDate.equals(weekStart) &
                  table.weekday.equals(weekday),
            ))
          .getSingleOrNull();

      if (normalizedText.trim().isEmpty) {
        if (existing != null) {
          await (_database.delete(_database.dailyMemos)
                ..where((table) => table.id.equals(existing.id)))
              .go();
        }
        return;
      }

      if (existing == null) {
        await _database.into(_database.dailyMemos).insert(
              DailyMemosCompanion.insert(
                weekStartDate: weekStart,
                weekday: weekday,
                memoText: normalizedText,
              ),
            );
        return;
      }

      await (_database.update(
        _database.dailyMemos,
      )..where((table) => table.id.equals(existing.id))).write(
        DailyMemosCompanion(
          memoText: Value(normalizedText),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> saveMealMenuEntry({
    required DateTime referenceDate,
    required MealSection section,
    required String menuText,
  }) async {
    final normalizedText = menuText.trim();
    if (normalizedText.isEmpty) {
      return;
    }

    final dailyMealMenu = await _ensureDailyMealMenu(referenceDate);
    final nextSortOrder = await _nextMealMenuSortOrder(dailyMealMenu.id, section);

    await _database.into(_database.mealMenuEntries).insert(
          MealMenuEntriesCompanion.insert(
            dailyMealMenuId: dailyMealMenu.id,
            mealSection: section.name,
            menuText: normalizedText,
            sortOrder: Value(nextSortOrder),
          ),
        );
  }

  Future<void> deleteMealMenuEntry(int entryId) async {
    await _database.transaction(() async {
      final row = await (_database.select(_database.mealMenuEntries)
            ..where((table) => table.id.equals(entryId)))
          .getSingleOrNull();
      if (row == null) {
        return;
      }

      await (_database.delete(_database.mealMenuEntries)
            ..where((table) => table.id.equals(entryId)))
          .go();

      final remainingCount = await (_database.selectOnly(_database.mealMenuEntries)
            ..addColumns([_database.mealMenuEntries.id.count()])
            ..where(_database.mealMenuEntries.dailyMealMenuId.equals(row.dailyMealMenuId)))
          .getSingle();
      final remaining = remainingCount.read(_database.mealMenuEntries.id.count()) ?? 0;
      if (remaining == 0) {
        await (_database.delete(_database.dailyMealMenus)
              ..where((table) => table.id.equals(row.dailyMealMenuId)))
            .go();
      }
    });
  }

  Future<List<MealMenuEntry>> loadMealMenuEntries(DateTime referenceDate) async {
    final dailyMealMenu = await _loadDailyMealMenu(referenceDate);
    return _loadMealMenuEntries(dailyMealMenu?.id);
  }

  Future<List<MealMenuSuggestion>> loadMealMenuSuggestions() async {
    final rows = await (_database.select(_database.mealMenuEntries)
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.updatedAt,
                  mode: OrderingMode.desc,
                ),
            (table) => OrderingTerm(
                  expression: table.createdAt,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();

    final normalizedSuggestions = <String, _MealMenuSuggestionAccumulator>{};
    for (final row in rows) {
      final key = row.menuText.trim();
      if (key.isEmpty) {
        continue;
      }

      final current = normalizedSuggestions[key];
      if (current == null) {
        normalizedSuggestions[key] = _MealMenuSuggestionAccumulator(
          text: key,
          usageCount: 1,
          lastUsedAt: row.updatedAt,
        );
      } else {
        normalizedSuggestions[key] = current.copyWith(
          usageCount: current.usageCount + 1,
          lastUsedAt: row.updatedAt.isAfter(current.lastUsedAt)
              ? row.updatedAt
              : current.lastUsedAt,
        );
      }
    }

    final suggestions = normalizedSuggestions.values.toList()
      ..sort((left, right) {
        final countComparison = right.usageCount.compareTo(left.usageCount);
        if (countComparison != 0) {
          return countComparison;
        }

        final lastUsedComparison = right.lastUsedAt.compareTo(left.lastUsedAt);
        if (lastUsedComparison != 0) {
          return lastUsedComparison;
        }

        return left.text.compareTo(right.text);
      });

    return suggestions
        .map(
          (suggestion) => MealMenuSuggestion(
            text: suggestion.text,
            usageCount: suggestion.usageCount,
            lastUsedAt: suggestion.lastUsedAt,
          ),
        )
        .toList();
  }

  Future<CategoryEntry> addCategory(String name) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'カテゴリ名は必須です');
    }

    return _database.transaction(() async {
      final nextSortOrder = await _nextCategorySortOrder();
      final inserted = await _database.into(_database.categories).insertReturning(
            CategoriesCompanion.insert(
              name: normalizedName,
              sortOrder: Value(nextSortOrder),
            ),
          );
      return CategoryEntry(
        id: inserted.id,
        name: inserted.name,
        sortOrder: inserted.sortOrder,
        isActive: inserted.isActive,
      );
    });
  }

  Future<void> updateCategory({
    required int categoryId,
    required String name,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'カテゴリ名は必須です');
    }

    await _database.transaction(() async {
      await (_database.update(
        _database.categories,
      )..where((table) => table.id.equals(categoryId))).write(
        CategoriesCompanion(
          name: Value(normalizedName),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> deleteCategory(int categoryId) async {
    await _database.transaction(() async {
      final itemCount = await countItemsInCategory(categoryId);
      if (itemCount > 0) {
        throw CategoryNotEmptyException(categoryId, itemCount);
      }

      await (_database.update(
        _database.categories,
      )..where((table) => table.id.equals(categoryId))).write(
        CategoriesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<ItemCandidate> addItemMaster({
    required String name,
    int? categoryId,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', '商品名は必須です');
    }

    return _database.transaction(() async {
      final inserted = await _database.into(_database.itemMasters).insertReturning(
            ItemMastersCompanion.insert(
              name: normalizedName,
              categoryId: Value(categoryId),
              defaultQuantity: const Value(1),
            ),
          );
      final categoryNames = await _categoryNamesById();
      return ItemCandidate(
        id: inserted.id,
        name: inserted.name,
        categoryId: inserted.categoryId,
        categoryName: inserted.categoryId == null
            ? null
            : categoryNames[inserted.categoryId!],
        defaultQuantity: inserted.defaultQuantity,
      );
    });
  }

  Future<void> updateItemMaster({
    required int itemId,
    required String name,
    int? categoryId,
  }) async {
    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', '商品名は必須です');
    }

    await _database.transaction(() async {
      await (_database.update(
        _database.itemMasters,
      )..where((table) => table.id.equals(itemId))).write(
        ItemMastersCompanion(
          name: Value(normalizedName),
          categoryId: Value(categoryId),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> deleteItemMaster(
    int itemId, {
    DateTime? referenceDate,
  }) async {
    await _database.transaction(() async {
      final weekStart = startOfWeek(referenceDate ?? DateTime.now());
      final hasCurrentWeekEntries = await hasPurchaseEntries(
        itemId,
        referenceDate: weekStart,
      );
      if (hasCurrentWeekEntries) {
        final referenceCount = await _countWeekReferences(itemId, weekStart);
        throw ItemInPurchaseWeekException(itemId, weekStart, referenceCount);
      }

      await (_database.update(
        _database.itemMasters,
      )..where((table) => table.id.equals(itemId))).write(
        ItemMastersCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> updateCategoryOrder(List<CategoryOrderUpdate> updates) async {
    if (updates.isEmpty) {
      return;
    }

    final now = DateTime.now();
    await _database.transaction(() async {
      for (final update in updates) {
        await (_database.update(
          _database.categories,
        )..where((table) => table.id.equals(update.categoryId))).write(
          CategoriesCompanion(
            sortOrder: Value(update.sortOrder),
            updatedAt: Value(now),
          ),
        );
      }
    });
  }

  Future<WeeklyShoppingSnapshot> loadWeek(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weekEnd = endOfWeek(referenceDate);
    final weeklyList = await _ensureWeeklyList(weekStart, weekEnd);
    final dailyMemo = await _loadDailyMemo(referenceDate);

    final categories = await loadCategories();
    final categoryNames = {
      for (final category in categories) category.id: category.name,
    };
    final itemMasters = await _loadItemMasters();

    final rawItems =
        await (_database.select(_database.weeklyListItems)
              ..where((table) => table.weeklyListId.equals(weeklyList.id))
              ..orderBy([
                (table) => OrderingTerm(expression: table.sortOrder),
                (table) => OrderingTerm(expression: table.createdAt),
              ]))
            .get();

    final entries = rawItems
        .map(
          (item) => ShoppingItemEntry(
            id: item.id,
            weekday: item.weekday,
            section: _sectionFromStoredValue(item.sectionName),
            name: item.itemName,
            quantity: item.quantity,
            isPurchased: item.isPurchased,
            sortOrder: item.sortOrder,
            categoryId: item.categoryId,
            categoryName: item.categoryId == null
                ? null
                : categoryNames[item.categoryId!],
            itemMasterId: item.itemMasterId,
          ),
        )
        .toList();

    final groupedEntries = _groupEntriesByCategory(entries, categoryNames);
    final selectedWeekday = dateOnly(referenceDate).weekday;

    final sections = ShoppingSection.values
        .map(
          (section) => ShoppingSectionItems(
            section: section,
            items: entries
                .where((item) => item.section == section && !item.isPurchased)
                .toList(),
          ),
        )
        .toList();

    final weekdaySections = ShoppingSection.values
        .map(
          (section) => ShoppingSectionItems(
            section: section,
            items: entries
                .where(
                  (item) =>
                      item.weekday == selectedWeekday &&
                      item.section == section &&
                      !item.isPurchased,
                )
                .toList(),
          ),
        )
        .toList();

    final purchasedEntries = entries.where((item) => item.isPurchased).toList()
      ..sort((left, right) => right.sortOrder.compareTo(left.sortOrder));

    return WeeklyShoppingSnapshot(
      weekRange: WeekRange(start: weekStart, end: weekEnd),
      selectedDate: dateOnly(referenceDate),
      dailyMemo: dailyMemo,
      categories: categories,
      categoryGroups: groupedEntries,
      sections: sections,
      weekdaySections: weekdaySections,
      hiddenPurchasedCount: purchasedEntries.length,
      lastPurchasedItem: purchasedEntries.isEmpty
          ? null
          : purchasedEntries.first,
      candidates: itemMasters,
    );
  }

  Future<void> addItem({
    required DateTime referenceDate,
    required AddItemRequest request,
  }) async {
    final weekStart = startOfWeek(referenceDate);
    final weekEnd = endOfWeek(referenceDate);
    final weeklyList = await _ensureWeeklyList(weekStart, weekEnd);
    final normalizedName = request.name.trim();
    if (normalizedName.isEmpty) {
      return;
    }
    final weekday = dateOnly(referenceDate).weekday;

    final candidate = await _findCandidateByName(normalizedName);
    final itemMasterId = request.itemMasterId ?? candidate?.id;
    final categoryId = request.categoryId ?? candidate?.categoryId;
    final nextSortOrder = await _nextItemSortOrder(
      weeklyList.id,
      request.section,
    );

    await _database
        .into(_database.weeklyListItems)
        .insert(
          WeeklyListItemsCompanion.insert(
            weeklyListId: weeklyList.id,
            weekday: Value(weekday),
            sectionName: request.section.name,
            itemMasterId: Value(itemMasterId),
            itemName: normalizedName,
            quantity: Value(request.quantity),
            categoryId: Value(categoryId),
            sortOrder: Value(nextSortOrder),
          ),
        );

    if (candidate == null && itemMasterId == null) {
      await _database
          .into(_database.itemMasters)
          .insert(
            ItemMastersCompanion.insert(
              name: normalizedName,
              categoryId: Value(categoryId),
              defaultQuantity: Value(request.quantity),
            ),
          );
    }
  }

  Future<void> deleteItem(int itemId) async {
    await (_database.delete(
      _database.weeklyListItems,
    )..where((table) => table.id.equals(itemId))).go();
  }

  Future<int> countItemsInCategory(int categoryId) async {
    final rows = await (_database.select(_database.itemMasters)
          ..where(
            (table) => table.categoryId.equals(categoryId) & table.isActive.equals(true),
          ))
        .get();
    return rows.length;
  }

  Future<Set<int>> loadCurrentWeekItemMasterIds(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weeklyList = await (_database.select(
      _database.weeklyLists,
    )..where((table) => table.weekStart.equals(weekStart))).getSingleOrNull();
    if (weeklyList == null) {
      return <int>{};
    }

    final rows = await (_database.select(_database.weeklyListItems)
          ..where((table) => table.weeklyListId.equals(weeklyList.id)))
        .get();

    return {
      for (final row in rows)
        if (row.itemMasterId != null) row.itemMasterId!,
    };
  }

  Future<bool> hasPurchaseEntries(
    int itemId, {
    DateTime? referenceDate,
  }) async {
    final weekStart = startOfWeek(referenceDate ?? DateTime.now());
    final weeklyList = await (_database.select(
      _database.weeklyLists,
    )..where((table) => table.weekStart.equals(weekStart))).getSingleOrNull();
    if (weeklyList == null) {
      return false;
    }

      final references = await _countWeekReferences(itemId, weekStart);
    return references > 0;
  }

  Future<void> togglePurchased(int itemId) async {
    final item = await (_database.select(
      _database.weeklyListItems,
    )..where((table) => table.id.equals(itemId))).getSingleOrNull();
    if (item == null) {
      return;
    }

    await (_database.update(
      _database.weeklyListItems,
    )..where((table) => table.id.equals(itemId))).write(
      WeeklyListItemsCompanion(
        isPurchased: Value(!item.isPurchased),
        purchasedAt: Value(!item.isPurchased ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<ShoppingItemEntry?> undoLatestPurchase(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weeklyList = await (_database.select(
      _database.weeklyLists,
    )..where((table) => table.weekStart.equals(weekStart))).getSingleOrNull();
    if (weeklyList == null) {
      return null;
    }

    final latest =
        await (_database.select(_database.weeklyListItems)
              ..where(
                (table) =>
                    table.weeklyListId.equals(weeklyList.id) &
                    table.isPurchased.equals(true),
              )
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.purchasedAt,
                  mode: OrderingMode.desc,
                ),
                (table) => OrderingTerm(
                  expression: table.sortOrder,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (latest == null) {
      return null;
    }

    await (_database.update(
      _database.weeklyListItems,
    )..where((table) => table.id.equals(latest.id))).write(
      WeeklyListItemsCompanion(
        isPurchased: const Value(false),
        purchasedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return ShoppingItemEntry(
      id: latest.id,
      weekday: latest.weekday,
      section: _sectionFromStoredValue(latest.sectionName),
      name: latest.itemName,
      quantity: latest.quantity,
      isPurchased: false,
      sortOrder: latest.sortOrder,
      categoryId: latest.categoryId,
      categoryName: null,
      itemMasterId: latest.itemMasterId,
    );
  }

  Future<List<ItemCandidate>> searchCandidates(String query) async {
    final allCandidates = await _loadItemMasters();
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return allCandidates;
    }

    return allCandidates
        .where((candidate) => candidate.name.toLowerCase().contains(normalized))
        .toList();
  }

  Future<WeeklyList> _ensureWeeklyList(
    DateTime weekStart,
    DateTime weekEnd,
  ) async {
    final existing = await (_database.select(
      _database.weeklyLists,
    )..where((table) => table.weekStart.equals(weekStart))).getSingleOrNull();
    if (existing != null) {
      return existing;
    }

    return _database
        .into(_database.weeklyLists)
        .insertReturning(
          WeeklyListsCompanion.insert(weekStart: weekStart, weekEnd: weekEnd),
        );
  }

  Future<List<CategoryEntry>> _loadCategories() async {
    final rows =
        await (_database.select(_database.categories)
              ..where((table) => table.isActive.equals(true))
              ..orderBy([
                (table) => OrderingTerm(expression: table.sortOrder),
                (table) => OrderingTerm(expression: table.name),
              ]))
            .get();

    return rows
        .map(
          (row) => CategoryEntry(
            id: row.id,
            name: row.name,
            sortOrder: row.sortOrder,
            isActive: row.isActive,
          ),
        )
        .toList();
  }

  Future<List<ItemCandidate>> _loadItemMasters() async {
    final rows =
        await (_database.select(_database.itemMasters)
              ..where((table) => table.isActive.equals(true))
              ..orderBy([(table) => OrderingTerm(expression: table.name)]))
            .get();

    final categories = await loadCategories();
    final categoryNames = {
      for (final category in categories) category.id: category.name,
    };

    return rows
        .map(
          (row) => ItemCandidate(
            id: row.id,
            name: row.name,
            categoryId: row.categoryId,
            categoryName: row.categoryId == null
                ? null
                : categoryNames[row.categoryId!],
            defaultQuantity: row.defaultQuantity,
          ),
        )
        .toList();
  }

  Future<int> _nextCategorySortOrder() async {
    final latest = await (_database.select(_database.categories)
          ..where((table) => table.isActive.equals(true))
          ..orderBy([
            (table) => OrderingTerm(
              expression: table.sortOrder,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
    return (latest?.sortOrder ?? -1) + 1;
  }

  Future<Map<int, String>> _categoryNamesById() async {
    final categories = await loadCategories();
    return {for (final category in categories) category.id: category.name};
  }

  Future<DailyMealMenusData?> _loadDailyMealMenu(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weekday = dateOnly(referenceDate).weekday;
    return (_database.select(_database.dailyMealMenus)
          ..where(
            (table) =>
                table.weekStartDate.equals(weekStart) & table.weekday.equals(weekday),
          ))
        .getSingleOrNull();
  }

  Future<DailyMealMenusData> _ensureDailyMealMenu(DateTime referenceDate) async {
    final existing = await _loadDailyMealMenu(referenceDate);
    if (existing != null) {
      return existing;
    }

    final weekStart = startOfWeek(referenceDate);
    final weekday = dateOnly(referenceDate).weekday;
    return _database.into(_database.dailyMealMenus).insertReturning(
          DailyMealMenusCompanion.insert(
            weekStartDate: weekStart,
            weekday: weekday,
          ),
        );
  }

  Future<List<MealMenuEntry>> _loadMealMenuEntries(int? dailyMealMenuId) async {
    if (dailyMealMenuId == null) {
      return const [];
    }

    final dailyMealMenu = await _loadDailyMealMenuById(dailyMealMenuId);
    if (dailyMealMenu == null) {
      return const [];
    }

    final rows = await (_database.select(_database.mealMenuEntries)
          ..where((table) => table.dailyMealMenuId.equals(dailyMealMenuId))
          ..orderBy([
            (table) => OrderingTerm(expression: table.sortOrder),
            (table) => OrderingTerm(expression: table.createdAt),
          ]))
        .get();

    return rows
        .map(
          (row) => MealMenuEntry(
            id: row.id,
            weekStartDate: dailyMealMenu.weekStartDate,
            weekday: dailyMealMenu.weekday,
            section: _mealSectionFromStoredValue(row.mealSection),
            menuText: row.menuText,
            sortOrder: row.sortOrder,
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
          ),
        )
        .toList();
  }

  Future<DailyMealMenusData?> _loadDailyMealMenuById(int dailyMealMenuId) async {
    return (_database.select(_database.dailyMealMenus)
          ..where((table) => table.id.equals(dailyMealMenuId)))
        .getSingleOrNull();
  }

  MealSection _mealSectionFromStoredValue(String value) {
    return MealSection.values.firstWhere((section) => section.name == value);
  }

  Future<int> _nextMealMenuSortOrder(int dailyMealMenuId, MealSection section) async {
    final latest = await (_database.select(_database.mealMenuEntries)
          ..where(
            (table) =>
                table.dailyMealMenuId.equals(dailyMealMenuId) &
                table.mealSection.equals(section.name),
          )
          ..orderBy([
            (table) => OrderingTerm(
                  expression: table.sortOrder,
                  mode: OrderingMode.desc,
                ),
          ])
          ..limit(1))
        .getSingleOrNull();

    return (latest?.sortOrder ?? -1) + 1;
  }

  Future<DailyMemoEntry?> _loadDailyMemo(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weekday = dateOnly(referenceDate).weekday;
    final row = await (_database.select(_database.dailyMemos)
          ..where(
            (table) =>
                table.weekStartDate.equals(weekStart) & table.weekday.equals(weekday),
          ))
        .getSingleOrNull();

    if (row == null) {
      return null;
    }

    return DailyMemoEntry(
      id: row.id,
      weekStartDate: row.weekStartDate,
      weekday: row.weekday,
      memoText: row.memoText,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  Future<int> _countWeekReferences(int itemId, DateTime weekStart) async {
    final query = _database.selectOnly(_database.weeklyListItems)
      ..addColumns([_database.weeklyListItems.id.count()])
      ..join([
        innerJoin(
          _database.weeklyLists,
          _database.weeklyLists.id.equalsExp(_database.weeklyListItems.weeklyListId),
        ),
      ])
      ..where(
        _database.weeklyListItems.itemMasterId.equals(itemId) &
            _database.weeklyLists.weekStart.equals(weekStart),
      );

    final row = await query.getSingle();
    return row.read(_database.weeklyListItems.id.count()) ?? 0;
  }

  List<ShoppingCategoryGroup> _groupEntriesByCategory(
    List<ShoppingItemEntry> entries,
    Map<int, String> categoryNames,
  ) {
    final grouped = <int?, List<ShoppingItemEntry>>{};
    for (final entry in entries.where((item) => !item.isPurchased)) {
      grouped
          .putIfAbsent(entry.categoryId, () => <ShoppingItemEntry>[])
          .add(entry);
    }

    final orderedGroups = <ShoppingCategoryGroup>[];
    for (final category in categoryNames.entries) {
      final items = grouped.remove(category.key);
      if (items == null || items.isEmpty) {
        continue;
      }
      orderedGroups.add(
        ShoppingCategoryGroup(
          categoryId: category.key,
          categoryName: category.value,
          items: List.unmodifiable(items),
        ),
      );
    }

    final uncategorizedItems = grouped.remove(null);
    if (uncategorizedItems != null && uncategorizedItems.isNotEmpty) {
      orderedGroups.add(
        ShoppingCategoryGroup(
          categoryId: null,
          categoryName: '未分類',
          items: List.unmodifiable(uncategorizedItems),
        ),
      );
    }

    return List.unmodifiable(orderedGroups);
  }

  Future<ItemCandidate?> _findCandidateByName(String name) async {
    final candidates = await _loadItemMasters();
    for (final candidate in candidates) {
      if (candidate.name.toLowerCase() == name.toLowerCase()) {
        return candidate;
      }
    }
    return null;
  }

  Future<int> _nextItemSortOrder(
    int weeklyListId,
    ShoppingSection section,
  ) async {
    final latestSortOrder =
        await (_database.select(_database.weeklyListItems)
              ..where(
                (table) =>
                    table.weeklyListId.equals(weeklyListId) &
                    table.sectionName.equals(section.name),
              )
              ..orderBy([
                (table) => OrderingTerm(
                  expression: table.sortOrder,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return (latestSortOrder?.sortOrder ?? 0) + 1;
  }

  ShoppingSection _sectionFromStoredValue(String value) {
    return ShoppingSection.values.firstWhere(
      (section) => section.name == value,
      orElse: () => ShoppingSection.other,
    );
  }
}

class _MealMenuSuggestionAccumulator {
  const _MealMenuSuggestionAccumulator({
    required this.text,
    required this.usageCount,
    required this.lastUsedAt,
  });

  final String text;
  final int usageCount;
  final DateTime lastUsedAt;

  _MealMenuSuggestionAccumulator copyWith({
    String? text,
    int? usageCount,
    DateTime? lastUsedAt,
  }) {
    return _MealMenuSuggestionAccumulator(
      text: text ?? this.text,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
    );
  }
}
