import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/domain/weekly_shopping_models.dart';

void main() {
  test(
    'creates a Monday-start weekly list and separates items by weekday within the same week',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final repository = WeeklyShoppingRepository(database);
      await database
          .into(database.categories)
          .insert(
            CategoriesCompanion.insert(
              name: '食品',
              sortOrder: const drift.Value(0),
            ),
          );
      final category = await database.select(database.categories).getSingle();
      await database
          .into(database.itemMasters)
          .insert(
            ItemMastersCompanion.insert(
              name: '牛乳',
              categoryId: drift.Value(category.id),
              defaultQuantity: const drift.Value(1),
            ),
          );
      await database
          .into(database.itemMasters)
          .insert(
            ItemMastersCompanion.insert(
              name: '卵',
              categoryId: drift.Value(category.id),
              defaultQuantity: const drift.Value(1),
            ),
          );

      await repository.addItem(
        referenceDate: DateTime(2026, 4, 20),
        request: const AddItemRequest(
          name: '牛乳',
          quantity: 2,
          section: ShoppingSection.morning,
        ),
      );

      await repository.addItem(
        referenceDate: DateTime(2026, 4, 21),
        request: const AddItemRequest(
          name: '卵',
          quantity: 1,
          section: ShoppingSection.morning,
        ),
      );

      final mondaySnapshot = await repository.loadWeek(DateTime(2026, 4, 20));
      final tuesdaySnapshot = await repository.loadWeek(DateTime(2026, 4, 21));

      expect(mondaySnapshot.weekRange.start, DateTime(2026, 4, 20));
      expect(mondaySnapshot.weekRange.end, DateTime(2026, 4, 26));
      expect(mondaySnapshot.categoryGroups, hasLength(1));
      expect(mondaySnapshot.categoryGroups.single.categoryName, '食品');
      expect(mondaySnapshot.categoryGroups.single.items, hasLength(2));
      expect(
        mondaySnapshot.sections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items,
        hasLength(2),
      );
      expect(
        mondaySnapshot.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items,
        hasLength(1),
      );
      expect(
        mondaySnapshot.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items
            .single
            .name,
        '牛乳',
      );

      expect(
        tuesdaySnapshot.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items,
        hasLength(1),
      );
      expect(
        tuesdaySnapshot.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items
            .single
            .name,
        '卵',
      );

      final itemMasters = await database.select(database.itemMasters).get();
      expect(itemMasters, hasLength(2));
      expect(itemMasters.map((item) => item.name), containsAll(['牛乳', '卵']));
    },
  );

  test(
    'toggles purchase state and supports undo of the latest purchase',
    () async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final repository = WeeklyShoppingRepository(database);
      await repository.addItem(
        referenceDate: DateTime(2026, 4, 22),
        request: const AddItemRequest(
          name: '卵',
          quantity: 1,
          section: ShoppingSection.other,
        ),
      );

      final item = await database.select(database.weeklyListItems).getSingle();
      await repository.togglePurchased(item.id);

      var snapshot = await repository.loadWeek(DateTime(2026, 4, 22));
      expect(snapshot.hiddenPurchasedCount, 1);
      expect(
        snapshot.sections
            .firstWhere((section) => section.section == ShoppingSection.other)
            .items,
        isEmpty,
      );

      final reverted = await repository.undoLatestPurchase(
        DateTime(2026, 4, 22),
      );
      expect(reverted, isNotNull);

      snapshot = await repository.loadWeek(DateTime(2026, 4, 22));
      expect(snapshot.hiddenPurchasedCount, 0);
      expect(
        snapshot.sections
            .firstWhere((section) => section.section == ShoppingSection.other)
            .items,
        hasLength(1),
      );
      expect(snapshot.categoryGroups.single.items, hasLength(1));
    },
  );
}
