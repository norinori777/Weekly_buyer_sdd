import 'package:flutter_test/flutter_test.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/domain/weekly_shopping_models.dart';

void main() {
  group('購入リストの日付表示', () {
    final weekRange = WeekRange(
      start: DateTime(2026, 10, 26),
      end: DateTime(2026, 11, 1),
    );

    test('購入日と使用日を曜日付き・ゼロ埋めで表示する', () {
      final item = ShoppingItemEntry(
        id: 1,
        weekday: DateTime.monday,
        section: ShoppingSection.morning,
        name: '牛乳',
        quantity: 1,
        isPurchased: false,
        sortOrder: 0,
        categoryId: 1,
        categoryName: '食品',
        itemMasterId: 1,
        purchaseDate: DateTime(2026, 10, 25),
      );

      expect(usageDateForShoppingItem(item, weekRange), DateTime(2026, 10, 26));
      expect(
        formatPurchaseListDateLabels(item, weekRange),
        '購入日:10/25(日) 使用日:10/26(月)',
      );
    });

    test('月またぎ週の日曜日を正しい曜日とゼロ埋めで表示する', () {
      final item = ShoppingItemEntry(
        id: 2,
        weekday: DateTime.sunday,
        section: ShoppingSection.evening,
        name: '豆腐',
        quantity: 1,
        isPurchased: false,
        sortOrder: 0,
        categoryId: 1,
        categoryName: '食品',
        itemMasterId: 2,
      );

      expect(usageDateForShoppingItem(item, weekRange), DateTime(2026, 11, 1));
      expect(formatPurchaseListDateLabels(item, weekRange), '使用日:11/01(日)');
    });

    test('購入日なしでは使用日だけを表示する', () {
      final item = ShoppingItemEntry(
        id: 3,
        weekday: DateTime.monday,
        section: ShoppingSection.morning,
        name: '牛乳',
        quantity: 1,
        isPurchased: false,
        sortOrder: 0,
        categoryId: 1,
        categoryName: '食品',
        itemMasterId: 3,
      );

      expect(formatPurchaseListDateLabels(item, weekRange), '使用日:10/26(月)');
    });

    test('曜日が範囲外の場合は使用日を表示しない', () {
      final item = ShoppingItemEntry(
        id: 4,
        weekday: 8,
        section: ShoppingSection.morning,
        name: '牛乳',
        quantity: 1,
        isPurchased: false,
        sortOrder: 0,
        categoryId: 1,
        categoryName: '食品',
        itemMasterId: 4,
      );

      expect(usageDateForShoppingItem(item, weekRange), isNull);
      expect(formatPurchaseListDateLabels(item, weekRange), isEmpty);
    });

    test('曜日に依存しない項目には使用日を表示しない', () {
      final item = ShoppingItemEntry(
        id: 5,
        weekday: DateTime.monday,
        section: ShoppingSection.other,
        name: 'その他',
        quantity: 1,
        isPurchased: false,
        sortOrder: 0,
        categoryId: 1,
        categoryName: '食品',
        itemMasterId: 5,
      );

      expect(usageDateForShoppingItem(item, weekRange), isNull);
      expect(formatPurchaseListDateLabels(item, weekRange), isEmpty);
    });
  });
}
