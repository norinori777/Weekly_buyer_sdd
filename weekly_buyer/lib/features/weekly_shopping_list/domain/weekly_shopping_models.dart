enum ShoppingSection { morning, afternoon, evening, other }

extension ShoppingSectionLabel on ShoppingSection {
  String get label => switch (this) {
    ShoppingSection.morning => '朝',
    ShoppingSection.afternoon => '昼',
    ShoppingSection.evening => '夜',
    ShoppingSection.other => 'その他',
  };

  bool get isDayIndependent => this == ShoppingSection.other;
}

class WeekRange {
  const WeekRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

enum MealSection { morning, lunch, dinner }

extension MealSectionLabel on MealSection {
  String get label => switch (this) {
        MealSection.morning => '朝',
        MealSection.lunch => '昼',
        MealSection.dinner => '夜',
      };
}

extension ShoppingSectionMealSection on ShoppingSection {
  MealSection? get mealSection => switch (this) {
        ShoppingSection.morning => MealSection.morning,
        ShoppingSection.afternoon => MealSection.lunch,
        ShoppingSection.evening => MealSection.dinner,
        ShoppingSection.other => null,
      };
}

class DailyMemoEntry {
  const DailyMemoEntry({
    required this.id,
    required this.weekStartDate,
    required this.weekday,
    required this.memoText,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final DateTime weekStartDate;
  final int weekday;
  final String memoText;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class MealMenuEntry {
  const MealMenuEntry({
    required this.id,
    required this.weekStartDate,
    required this.weekday,
    required this.section,
    required this.menuText,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final DateTime weekStartDate;
  final int weekday;
  final MealSection section;
  final String menuText;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class MealMenuSuggestion {
  const MealMenuSuggestion({
    required this.text,
    required this.usageCount,
    required this.lastUsedAt,
  });

  final String text;
  final int usageCount;
  final DateTime lastUsedAt;
}

class MealMenuSectionEntries {
  const MealMenuSectionEntries({required this.section, required this.entries});

  final MealSection section;
  final List<MealMenuEntry> entries;
}

class MealMenuDaySnapshot {
  const MealMenuDaySnapshot({
    required this.weekRange,
    required this.selectedDate,
    required this.sections,
    required this.suggestions,
  });

  final WeekRange weekRange;
  final DateTime selectedDate;
  final List<MealMenuSectionEntries> sections;
  final List<MealMenuSuggestion> suggestions;
}

class CategoryEntry {
  const CategoryEntry({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final int id;
  final String name;
  final int sortOrder;
  final bool isActive;
}

class CategoryOrderUpdate {
  const CategoryOrderUpdate({
    required this.categoryId,
    required this.sortOrder,
  });

  final int categoryId;
  final int sortOrder;
}

class CategoryNotEmptyException implements Exception {
  const CategoryNotEmptyException(this.categoryId, this.itemCount);

  final int categoryId;
  final int itemCount;

  @override
  String toString() {
    return 'CategoryNotEmptyException(categoryId: $categoryId, itemCount: $itemCount)';
  }
}

class ItemInPurchaseWeekException implements Exception {
  const ItemInPurchaseWeekException(this.itemId, this.weekStart, this.referenceCount);

  final int itemId;
  final DateTime weekStart;
  final int referenceCount;

  @override
  String toString() {
    return 'ItemInPurchaseWeekException(itemId: $itemId, weekStart: $weekStart, referenceCount: $referenceCount)';
  }
}

class ShoppingCategoryGroup {
  const ShoppingCategoryGroup({
    required this.categoryId,
    required this.categoryName,
    required this.items,
  });

  final int? categoryId;
  final String categoryName;
  final List<ShoppingItemEntry> items;
}

class ItemCandidate {
  const ItemCandidate({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.defaultQuantity,
  });

  final int id;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final int defaultQuantity;
}

class ShoppingItemEntry {
  const ShoppingItemEntry({
    required this.id,
    required this.weekday,
    required this.section,
    required this.name,
    required this.quantity,
    required this.isPurchased,
    required this.sortOrder,
    required this.categoryId,
    required this.categoryName,
    required this.itemMasterId,
  });

  final int id;
  final int weekday;
  final ShoppingSection section;
  final String name;
  final int quantity;
  final bool isPurchased;
  final int sortOrder;
  final int? categoryId;
  final String? categoryName;
  final int? itemMasterId;

  ShoppingItemEntry copyWith({bool? isPurchased, int? quantity}) {
    return ShoppingItemEntry(
      id: id,
      weekday: weekday,
      section: section,
      name: name,
      quantity: quantity ?? this.quantity,
      isPurchased: isPurchased ?? this.isPurchased,
      sortOrder: sortOrder,
      categoryId: categoryId,
      categoryName: categoryName,
      itemMasterId: itemMasterId,
    );
  }
}

class ShoppingSectionItems {
  const ShoppingSectionItems({required this.section, required this.items});

  final ShoppingSection section;
  final List<ShoppingItemEntry> items;
}

class WeeklyShoppingSnapshot {
  const WeeklyShoppingSnapshot({
    required this.weekRange,
    required this.selectedDate,
    required this.dailyMemo,
    required this.categories,
    required this.categoryGroups,
    required this.sections,
    required this.weekdaySections,
    required this.hiddenPurchasedCount,
    required this.lastPurchasedItem,
    required this.candidates,
  });

  final WeekRange weekRange;
  final DateTime selectedDate;
  final DailyMemoEntry? dailyMemo;
  final List<CategoryEntry> categories;
  final List<ShoppingCategoryGroup> categoryGroups;
  final List<ShoppingSectionItems> sections;
  final List<ShoppingSectionItems> weekdaySections;
  final int hiddenPurchasedCount;
  final ShoppingItemEntry? lastPurchasedItem;
  final List<ItemCandidate> candidates;
}

class AddItemRequest {
  const AddItemRequest({
    required this.name,
    required this.quantity,
    required this.section,
    this.itemMasterId,
    this.categoryId,
  });

  final String name;
  final int quantity;
  final ShoppingSection section;
  final int? itemMasterId;
  final int? categoryId;
}

DateTime dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime startOfWeek(DateTime value) {
  final normalized = dateOnly(value);
  return normalized.subtract(
    Duration(days: normalized.weekday - DateTime.monday),
  );
}

DateTime endOfWeek(DateTime value) {
  return startOfWeek(value).add(const Duration(days: 6));
}

DateTime startOfNextWeek(DateTime value) {
  return startOfWeek(value).add(const Duration(days: 7));
}

String formatWeekLabel(WeekRange range) {
  final start = _shortDate(range.start);
  final end = _shortDate(range.end);
  return '$start - $end';
}

String _shortDate(DateTime value) => '${value.month}/${value.day}';
