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
  final ShoppingSection section;
  final String name;
  final int quantity;
  final bool isPurchased;
  final int sortOrder;
  final int? categoryId;
  final String? categoryName;
  final int? itemMasterId;

  ShoppingItemEntry copyWith({
    bool? isPurchased,
    int? quantity,
  }) {
    return ShoppingItemEntry(
      id: id,
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
  const ShoppingSectionItems({
    required this.section,
    required this.items,
  });

  final ShoppingSection section;
  final List<ShoppingItemEntry> items;
}

class WeeklyShoppingSnapshot {
  const WeeklyShoppingSnapshot({
    required this.weekRange,
    required this.selectedDate,
    required this.categories,
    required this.sections,
    required this.hiddenPurchasedCount,
    required this.lastPurchasedItem,
    required this.candidates,
  });

  final WeekRange weekRange;
  final DateTime selectedDate;
  final List<CategoryEntry> categories;
  final List<ShoppingSectionItems> sections;
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
  return normalized.subtract(Duration(days: normalized.weekday - DateTime.monday));
}

DateTime endOfWeek(DateTime value) {
  return startOfWeek(value).add(const Duration(days: 6));
}

String formatWeekLabel(WeekRange range) {
  final start = _shortDate(range.start);
  final end = _shortDate(range.end);
  return '$start - $end';
}

String _shortDate(DateTime value) => '${value.month}/${value.day}';