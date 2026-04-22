import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/domain/weekly_shopping_models.dart';

void main() {
  test('computes next calendar week from the current week start', () {
    expect(startOfNextWeek(DateTime(2026, 4, 22)), DateTime(2026, 4, 27));
    expect(startOfNextWeek(DateTime(2026, 12, 31)), DateTime(2027, 1, 4));
  });

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
      final category = await (
        database.select(database.categories)
          ..where((table) => table.name.equals('食品'))
      ).getSingle();
      await database
          .into(database.itemMasters)
          .insert(
            ItemMastersCompanion.insert(
              name: 'テスト牛乳',
              categoryId: drift.Value(category.id),
              defaultQuantity: const drift.Value(1),
            ),
          );
      await database
          .into(database.itemMasters)
          .insert(
            ItemMastersCompanion.insert(
              name: 'テスト卵',
              categoryId: drift.Value(category.id),
              defaultQuantity: const drift.Value(1),
            ),
          );

      await repository.addItem(
        referenceDate: DateTime(2026, 4, 20),
        request: const AddItemRequest(
          name: 'テスト牛乳',
          quantity: 2,
          section: ShoppingSection.morning,
        ),
      );

      await repository.addItem(
        referenceDate: DateTime(2026, 4, 21),
        request: const AddItemRequest(
          name: 'テスト卵',
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
        'テスト牛乳',
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
        'テスト卵',
      );

      final itemMasters = await database.select(database.itemMasters).get();
      expect(
        itemMasters.where((item) => item.name == 'テスト牛乳'),
        isNotEmpty,
      );
      expect(itemMasters.where((item) => item.name == 'テスト卵'), isNotEmpty);
    },
  );

  test(
    'deletes a selected item without affecting the remaining weekday items',
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
      final category = await (
        database.select(database.categories)
          ..where((table) => table.name.equals('食品'))
      ).getSingle();

      await repository.addItem(
        referenceDate: DateTime(2026, 4, 20),
        request: AddItemRequest(
          name: 'テスト削除対象',
          quantity: 1,
          section: ShoppingSection.morning,
          categoryId: category.id,
        ),
      );
      await repository.addItem(
        referenceDate: DateTime(2026, 4, 20),
        request: AddItemRequest(
          name: 'テスト残す',
          quantity: 1,
          section: ShoppingSection.morning,
          categoryId: category.id,
        ),
      );
      await repository.addItem(
        referenceDate: DateTime(2026, 4, 21),
        request: AddItemRequest(
          name: 'テスト別曜日',
          quantity: 1,
          section: ShoppingSection.morning,
          categoryId: category.id,
        ),
      );

      final mondayBeforeDelete = await repository.loadWeek(DateTime(2026, 4, 20));
      final mondayItemsBeforeDelete = mondayBeforeDelete.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items;
      expect(mondayItemsBeforeDelete, hasLength(2));

      await repository.deleteItem(mondayItemsBeforeDelete.first.id);

      final mondayAfterDelete = await repository.loadWeek(DateTime(2026, 4, 20));
      final tuesdayAfterDelete = await repository.loadWeek(DateTime(2026, 4, 21));

      expect(
        mondayAfterDelete.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items,
        hasLength(1),
      );
      expect(
        mondayAfterDelete.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items
            .single
            .name,
        'テスト残す',
      );
      expect(
        tuesdayAfterDelete.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items,
        hasLength(1),
      );
      expect(
        tuesdayAfterDelete.weekdaySections
            .firstWhere((section) => section.section == ShoppingSection.morning)
            .items
            .single
            .name,
        'テスト別曜日',
      );
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

  test('updates category order using the persisted sort order', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);

    await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'テスト食品',
            sortOrder: drift.Value(0),
          ),
        );
    await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'テスト日用品',
            sortOrder: drift.Value(1),
          ),
        );
    await database.into(database.categories).insert(
          CategoriesCompanion.insert(
            name: 'テスト飲料',
            sortOrder: drift.Value(2),
          ),
        );

    final categoriesBefore = await repository.loadCategories();
    expect(
      categoriesBefore
            .where((category) => {'テスト食品', 'テスト日用品', 'テスト飲料'}.contains(category.name))
          .map((category) => category.name)
          .toList(),
            ['テスト食品', 'テスト日用品', 'テスト飲料'],
    );

    final categoryIds = {
      for (final category in categoriesBefore) category.name: category.id,
    };

    await repository.updateCategoryOrder([
      CategoryOrderUpdate(categoryId: categoryIds['テスト日用品']!, sortOrder: 0),
      CategoryOrderUpdate(categoryId: categoryIds['テスト飲料']!, sortOrder: 1),
      CategoryOrderUpdate(categoryId: categoryIds['テスト食品']!, sortOrder: 2),
    ]);

    final categoriesAfter = await repository.loadCategories();
    expect(
      categoriesAfter
            .where((category) => {'テスト食品', 'テスト日用品', 'テスト飲料'}.contains(category.name))
          .map((category) => category.name)
          .toList(),
            ['テスト日用品', 'テスト飲料', 'テスト食品'],
    );
    expect(
      categoriesAfter
            .where((category) => {'テスト食品', 'テスト日用品', 'テスト飲料'}.contains(category.name))
          .map((category) => category.sortOrder)
          .toList(),
      [0, 1, 2],
    );
  });

  test('adds, updates, and deletes categories without items', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);

    final created = await repository.addCategory('テストカテゴリ');
    expect(created.name, 'テストカテゴリ');

    await repository.updateCategory(
      categoryId: created.id,
      name: '更新後カテゴリ',
    );

    final categoriesAfterUpdate = await repository.loadCategories();
    expect(
      categoriesAfterUpdate.firstWhere((category) => category.id == created.id).name,
      '更新後カテゴリ',
    );

    await repository.deleteCategory(created.id);

    final categoriesAfterDelete = await repository.loadCategories();
    expect(categoriesAfterDelete.where((category) => category.id == created.id), isEmpty);
  });

  test('blocks category deletion when active items exist', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final category = await repository.addCategory('削除対象カテゴリ');
    await repository.addItemMaster(name: '削除対象商品', categoryId: category.id);

    expect(
      () => repository.deleteCategory(category.id),
      throwsA(isA<CategoryNotEmptyException>()),
    );
  });

  test('adds, updates, and deletes items outside the current purchase week', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final category = await repository.addCategory('商品カテゴリ');
    final created = await repository.addItemMaster(
      name: 'テスト商品',
      categoryId: category.id,
    );

    await repository.updateItemMaster(
      itemId: created.id,
      name: '更新商品',
      categoryId: category.id,
    );

    final itemsAfterUpdate = await repository.loadItemMasters();
    expect(itemsAfterUpdate.any((item) => item.name == '更新商品'), isTrue);

    await repository.deleteItemMaster(
      created.id,
      referenceDate: DateTime(2026, 4, 27),
    );

    final itemsAfterDelete = await repository.loadItemMasters();
    expect(itemsAfterDelete.where((item) => item.id == created.id), isEmpty);
  });

  test('blocks item deletion when the current purchase week already references it', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final category = await repository.addCategory('商品カテゴリ');
    await repository.addItemMaster(
      name: 'テスト牛乳',
      categoryId: category.id,
    );

    final referenceDate = DateTime(2026, 4, 27);
    await repository.addItem(
      referenceDate: referenceDate,
      request: AddItemRequest(
        name: 'テスト牛乳',
        quantity: 1,
        section: ShoppingSection.morning,
        categoryId: category.id,
      ),
    );

    final item = (await repository.loadItemMasters())
        .firstWhere((candidate) => candidate.name == 'テスト牛乳');

    expect(
      () => repository.deleteItemMaster(item.id, referenceDate: referenceDate),
      throwsA(isA<ItemInPurchaseWeekException>()),
    );
  });
}
