import 'package:drift/drift.dart';

import '../../../app/app_database.dart';
import '../domain/weekly_shopping_models.dart';

class WeeklyShoppingRepository {
  WeeklyShoppingRepository(this._database);

  final AppDatabase _database;

  Future<WeeklyShoppingSnapshot> loadWeek(DateTime referenceDate) async {
    final weekStart = startOfWeek(referenceDate);
    final weekEnd = endOfWeek(referenceDate);
    final weeklyList = await _ensureWeeklyList(weekStart, weekEnd);

    final categories = await _loadCategories();
    final categoryNames = {for (final category in categories) category.id: category.name};

    final itemMasters = await _loadItemMasters();

    final rawItems = await (_database.select(_database.weeklyListItems)
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
            section: _sectionFromStoredValue(item.sectionName),
            name: item.itemName,
            quantity: item.quantity,
            isPurchased: item.isPurchased,
            sortOrder: item.sortOrder,
            categoryId: item.categoryId,
            categoryName: item.categoryId == null ? null : categoryNames[item.categoryId!],
            itemMasterId: item.itemMasterId,
          ),
        )
        .toList();

    final sections = ShoppingSection.values
        .map(
          (section) => ShoppingSectionItems(
            section: section,
            items: entries.where((item) => item.section == section && !item.isPurchased).toList(),
          ),
        )
        .toList();

    final hiddenPurchasedCount = entries.where((item) => item.isPurchased).length;
    final lastPurchasedItem = entries.where((item) => item.isPurchased).toList()
      ..sort((left, right) => right.sortOrder.compareTo(left.sortOrder));

    return WeeklyShoppingSnapshot(
      weekRange: WeekRange(start: weekStart, end: weekEnd),
      selectedDate: dateOnly(referenceDate),
      categories: categories,
      sections: sections,
      hiddenPurchasedCount: hiddenPurchasedCount,
      lastPurchasedItem: lastPurchasedItem.isEmpty ? null : lastPurchasedItem.first,
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

    final candidate = await _findCandidateByName(normalizedName);
    final itemMasterId = request.itemMasterId ?? candidate?.id;
    final categoryId = request.categoryId ?? candidate?.categoryId;

    final nextSortOrder = await _nextItemSortOrder(weeklyList.id, request.section);
    await _database.into(_database.weeklyListItems).insert(
          WeeklyListItemsCompanion.insert(
            weeklyListId: weeklyList.id,
            sectionName: request.section.name,
            itemMasterId: Value(itemMasterId),
            itemName: normalizedName,
            quantity: Value(request.quantity),
            categoryId: Value(categoryId),
            sortOrder: Value(nextSortOrder),
          ),
        );

    if (candidate == null && itemMasterId == null) {
      await _database.into(_database.itemMasters).insert(
            ItemMastersCompanion.insert(
              name: normalizedName,
              categoryId: Value(categoryId),
              defaultQuantity: Value(request.quantity),
            ),
          );
    }
  }

  Future<void> togglePurchased(int itemId) async {
    final item = await (_database.select(_database.weeklyListItems)
          ..where((table) => table.id.equals(itemId)))
        .getSingleOrNull();
    if (item == null) {
      return;
    }

    await (_database.update(_database.weeklyListItems)
          ..where((table) => table.id.equals(itemId)))
        .write(
      WeeklyListItemsCompanion(
        isPurchased: Value(!item.isPurchased),
        purchasedAt: Value(!item.isPurchased ? DateTime.now() : null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<ShoppingItemEntry?> undoLatestPurchase() async {
    final latest = await (_database.select(_database.weeklyListItems)
          ..where((table) => table.isPurchased.equals(true))
          ..orderBy([
            (table) => OrderingTerm(expression: table.purchasedAt, mode: OrderingMode.desc),
            (table) => OrderingTerm(expression: table.sortOrder, mode: OrderingMode.desc),
          ])
          ..limit(1))
        .getSingleOrNull();
    if (latest == null) {
      return null;
    }

    await (_database.update(_database.weeklyListItems)
          ..where((table) => table.id.equals(latest.id)))
        .write(
      WeeklyListItemsCompanion(
        isPurchased: const Value(false),
        purchasedAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );

    return ShoppingItemEntry(
      id: latest.id,
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

  Future<WeeklyList> _ensureWeeklyList(DateTime weekStart, DateTime weekEnd) async {
    final existing = await (_database.select(_database.weeklyLists)
          ..where((table) => table.weekStart.equals(weekStart)))
        .getSingleOrNull();
    if (existing != null) {
      return existing;
    }

    return _database.into(_database.weeklyLists).insertReturning(
          WeeklyListsCompanion.insert(
            weekStart: weekStart,
            weekEnd: weekEnd,
          ),
        );
  }

  Future<List<CategoryEntry>> _loadCategories() async {
    final rows = await (_database.select(_database.categories)
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
    final rows = await (_database.select(_database.itemMasters)
          ..where((table) => table.isActive.equals(true))
          ..orderBy([
            (table) => OrderingTerm(expression: table.name),
          ]))
        .get();

    final categories = await _loadCategories();
    final categoryNames = {for (final category in categories) category.id: category.name};

    return rows
        .map(
          (row) => ItemCandidate(
            id: row.id,
            name: row.name,
            categoryId: row.categoryId,
            categoryName: row.categoryId == null ? null : categoryNames[row.categoryId!],
            defaultQuantity: row.defaultQuantity,
          ),
        )
        .toList();
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

  Future<int> _nextItemSortOrder(int weeklyListId, ShoppingSection section) async {
    final latestSortOrder = await (_database.select(_database.weeklyListItems)
          ..where((table) => table.weeklyListId.equals(weeklyListId) & table.sectionName.equals(section.name))
          ..orderBy([(table) => OrderingTerm(expression: table.sortOrder, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
    return latestSortOrder?.sortOrder ?? 0;
  }

  ShoppingSection _sectionFromStoredValue(String value) {
    return ShoppingSection.values.firstWhere((section) => section.name == value, orElse: () => ShoppingSection.other);
  }
}