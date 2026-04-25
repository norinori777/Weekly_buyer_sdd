import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/domain/weekly_shopping_models.dart';

const _seededCategoryNames = [
  '野菜',
  '果物',
  '肉',
  '魚介',
  '卵・乳製品',
  '穀類・主食',
  '飲料',
  'お菓子',
  '冷凍食品',
  '調味料',
  'ベーカリー',
  '大豆製品・発酵食品',
];

const _seededItemCounts = {
  '野菜': 25,
  '果物': 10,
  '肉': 11,
  '魚介': 10,
  '卵・乳製品': 9,
  '穀類・主食': 8,
  '飲料': 8,
  'お菓子': 8,
  '冷凍食品': 7,
  '調味料': 9,
  'ベーカリー': 10,
  '大豆製品・発酵食品': 3,
};

Future<AppDatabase> _openSeedDatabase(String path) async {
  return AppDatabase(executor: NativeDatabase(File(path)));
}

void main() {
  test('computes next calendar week from the current week start', () {
    expect(startOfNextWeek(DateTime(2026, 4, 22)), DateTime(2026, 4, 27));
    expect(startOfNextWeek(DateTime(2026, 12, 31)), DateTime(2027, 1, 4));
  });

  test('seeds the initial catalog with the expected categories and item counts', () async {
    final tempDir = await Directory.systemTemp.createTemp('weekly-buyer-seed-clean');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final databasePath = '${tempDir.path}${Platform.pathSeparator}weekly_buyer.db';
    final database = await _openSeedDatabase(databasePath);
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);

    final categories = await repository.loadCategories();
    expect(categories.map((category) => category.name).toList(), _seededCategoryNames);

    final itemMasters = await repository.loadItemMasters();
    expect(itemMasters.every((item) => item.hiragana != null && item.hiragana!.trim().isNotEmpty), isTrue);
    expect(
      {
        for (final categoryName in _seededCategoryNames)
          categoryName: itemMasters.where((item) => item.categoryName == categoryName).length,
      },
      _seededItemCounts,
    );
  });

  test('does not duplicate seeded data when startup runs again on an existing database', () async {
    final tempDir = await Directory.systemTemp.createTemp('weekly-buyer-seed-repeat');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final databasePath = '${tempDir.path}${Platform.pathSeparator}weekly_buyer.db';

    final firstDatabase = await _openSeedDatabase(databasePath);
    final firstRepository = WeeklyShoppingRepository(firstDatabase);
    final initialCategories = await firstRepository.loadCategories();
    final initialItems = await firstRepository.loadItemMasters();
    await firstDatabase.close();

    final secondDatabase = await _openSeedDatabase(databasePath);
    addTearDown(secondDatabase.close);
    final secondRepository = WeeklyShoppingRepository(secondDatabase);

    final categoriesAfterRestart = await secondRepository.loadCategories();
    final itemsAfterRestart = await secondRepository.loadItemMasters();

    expect(categoriesAfterRestart.map((category) => category.name).toList(), initialCategories.map((category) => category.name).toList());
    expect(itemsAfterRestart.length, initialItems.length);
    expect(itemsAfterRestart.map((item) => item.name).toSet(), initialItems.map((item) => item.name).toSet());
    expect(itemsAfterRestart.map((item) => item.hiragana).toSet(), initialItems.map((item) => item.hiragana).toSet());
  });

  test('backfills missing hiragana values without duplicating seeded item masters', () async {
    final tempDir = await Directory.systemTemp.createTemp('weekly-buyer-seed-backfill');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final databasePath = '${tempDir.path}${Platform.pathSeparator}weekly_buyer.db';

    final firstDatabase = await _openSeedDatabase(databasePath);
    final repository = WeeklyShoppingRepository(firstDatabase);
    final seededItems = await repository.loadItemMasters();
    final targetItem = seededItems.firstWhere((item) => item.name == '牛乳');

    await (firstDatabase.update(firstDatabase.itemMasters)
          ..where((table) => table.id.equals(targetItem.id)))
        .write(
      ItemMastersCompanion(
        hiragana: const drift.Value(null),
        updatedAt: drift.Value(DateTime.now()),
      ),
    );
    await firstDatabase.close();

    final secondDatabase = await _openSeedDatabase(databasePath);
    addTearDown(secondDatabase.close);
    final secondRepository = WeeklyShoppingRepository(secondDatabase);

    final reloadedItems = await secondRepository.loadItemMasters();
    final reloadedTarget = reloadedItems.firstWhere((item) => item.id == targetItem.id);

    expect(reloadedTarget.hiragana, 'ぎゅうにゅう');
    expect(reloadedItems.where((item) => item.name == '牛乳'), hasLength(1));
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

  test('loads distinct snapshots for the next week and the previous week', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final nextWeekStart = DateTime(2026, 4, 27);
    final previousWeekStart = nextWeekStart.subtract(const Duration(days: 7));
    final twoWeeksBackStart = nextWeekStart.subtract(const Duration(days: 14));
    final threeWeeksBackStart = nextWeekStart.subtract(const Duration(days: 21));

    await database.into(database.categories).insert(
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
      referenceDate: previousWeekStart,
      request: AddItemRequest(
        name: '先週牛乳',
        quantity: 1,
        section: ShoppingSection.morning,
        categoryId: category.id,
      ),
    );
    await repository.addItem(
      referenceDate: nextWeekStart,
      request: AddItemRequest(
        name: '今週卵',
        quantity: 2,
        section: ShoppingSection.morning,
        categoryId: category.id,
      ),
    );
    await repository.addItem(
      referenceDate: twoWeeksBackStart,
      request: AddItemRequest(
        name: '2週間前豆腐',
        quantity: 1,
        section: ShoppingSection.morning,
        categoryId: category.id,
      ),
    );
    await repository.addItem(
      referenceDate: threeWeeksBackStart,
      request: AddItemRequest(
        name: '3週間前みそ',
        quantity: 1,
        section: ShoppingSection.morning,
        categoryId: category.id,
      ),
    );

    final previousSnapshot = await repository.loadWeek(previousWeekStart);
    final nextSnapshot = await repository.loadWeek(nextWeekStart);
    final twoWeeksBackSnapshot = await repository.loadWeek(twoWeeksBackStart);
    final threeWeeksBackSnapshot = await repository.loadWeek(threeWeeksBackStart);

    expect(previousSnapshot.weekRange.start, previousWeekStart);
    expect(previousSnapshot.weekRange.end, previousWeekStart.add(const Duration(days: 6)));
    expect(nextSnapshot.weekRange.start, nextWeekStart);
    expect(nextSnapshot.weekRange.end, nextWeekStart.add(const Duration(days: 6)));

    expect(
      previousSnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .single
          .name,
      '先週牛乳',
    );
    expect(
      nextSnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .single
          .name,
      '今週卵',
    );
    expect(
      twoWeeksBackSnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .single
          .name,
      '2週間前豆腐',
    );
    expect(
      threeWeeksBackSnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .single
          .name,
      '3週間前みそ',
    );
  });

  test('saves and reloads a private memo for the selected day', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);

    await repository.saveDailyMemo(
      referenceDate: monday,
      memoText: '夫は夕飯いらない',
    );

    final memo = await repository.loadDailyMemo(monday);
    expect(memo, isNotNull);
    expect(memo!.memoText, '夫は夕飯いらない');
    expect(memo.weekday, DateTime.monday);

    final snapshot = await repository.loadWeek(monday);
    expect(snapshot.dailyMemo?.memoText, '夫は夕飯いらない');
  });

  test('clears a memo when the saved text becomes blank', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);

    await repository.saveDailyMemo(
      referenceDate: monday,
      memoText: '休み',
    );
    await repository.saveDailyMemo(
      referenceDate: monday,
      memoText: '   ',
    );

    expect(await repository.loadDailyMemo(monday), isNull);
    final snapshot = await repository.loadWeek(monday);
    expect(snapshot.dailyMemo, isNull);
  });

  test('keeps private memos isolated by day within the active week', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);
    final tuesday = DateTime(2026, 4, 21);

    await repository.saveDailyMemo(
      referenceDate: monday,
      memoText: '休み',
    );
    await repository.saveDailyMemo(
      referenceDate: tuesday,
      memoText: '夫が夕飯不要',
    );

    expect((await repository.loadDailyMemo(monday))?.memoText, '休み');
    expect((await repository.loadDailyMemo(tuesday))?.memoText, '夫が夕飯不要');

    final mondaySnapshot = await repository.loadWeek(monday);
    final tuesdaySnapshot = await repository.loadWeek(tuesday);
    expect(mondaySnapshot.dailyMemo?.memoText, '休み');
    expect(tuesdaySnapshot.dailyMemo?.memoText, '夫が夕飯不要');
  });

  test('saves and reloads meal menus by section for the selected day', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);

    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.morning,
      menuText: 'トースト',
    );
    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.morning,
      menuText: 'ヨーグルト',
    );
    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.dinner,
      menuText: 'カレー',
    );

    final entries = await repository.loadMealMenuEntries(monday);
    expect(entries, hasLength(3));
    expect(entries.where((entry) => entry.section == MealSection.morning), hasLength(2));
    expect(entries.where((entry) => entry.section == MealSection.dinner), hasLength(1));

    final snapshot = await repository.loadMealMenuSnapshot(monday);
    expect(snapshot.selectedDate, DateTime(2026, 4, 20));
    expect(
      snapshot.sections.firstWhere((section) => section.section == MealSection.morning).entries,
      hasLength(2),
    );
    expect(
      snapshot.sections.firstWhere((section) => section.section == MealSection.dinner).entries.single.menuText,
      'カレー',
    );
  });

  test('ignores blank meal menu text and keeps saved entries', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);

    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.morning,
      menuText: 'トースト',
    );
    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.morning,
      menuText: 'トースト',
    );
    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.lunch,
      menuText: 'パスタ',
    );
    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.lunch,
      menuText: '   ',
    );

    final entries = await repository.loadMealMenuEntries(monday);
    expect(entries.where((entry) => entry.menuText == 'トースト'), hasLength(2));
    expect(entries.where((entry) => entry.menuText == 'パスタ'), hasLength(1));
  });

  test('keeps meal menus isolated by day within the active week', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final monday = DateTime(2026, 4, 20);
    final tuesday = DateTime(2026, 4, 21);

    await repository.saveMealMenuEntry(
      referenceDate: monday,
      section: MealSection.morning,
      menuText: 'トースト',
    );
    await repository.saveMealMenuEntry(
      referenceDate: tuesday,
      section: MealSection.morning,
      menuText: 'おにぎり',
    );

    expect(
      await repository.loadMealMenuEntries(monday),
      hasLength(1),
    );
    expect(
      await repository.loadMealMenuEntries(tuesday),
      hasLength(1),
    );
    expect(
      (await repository.loadMealMenuEntries(monday)).single.menuText,
      'トースト',
    );
    expect(
      (await repository.loadMealMenuEntries(tuesday)).single.menuText,
      'おにぎり',
    );
  });

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
    await repository.addItemMaster(
      name: '削除対象商品',
      hiragana: 'さくじょたいしょうしょうひん',
      categoryId: category.id,
    );

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
      hiragana: 'てすとしょうひん',
      categoryId: category.id,
    );

    await repository.updateItemMaster(
      itemId: created.id,
      name: '更新商品',
      hiragana: 'こうしんしょうひん',
      categoryId: category.id,
    );

    final itemsAfterUpdate = await repository.loadItemMasters();
    expect(itemsAfterUpdate.any((item) => item.name == '更新商品'), isTrue);
    expect(itemsAfterUpdate.any((item) => item.hiragana == 'こうしんしょうひん'), isTrue);

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
      hiragana: 'てすとぎゅうにゅう',
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

  test('saves item master hiragana and searches by name or hiragana', () async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    final category = await repository.addCategory('検索カテゴリ');

    final created = await repository.addItemMaster(
      name: '検索牛乳',
      hiragana: 'けんさくぎゅうにゅう',
      categoryId: category.id,
    );

    final loaded = await repository.loadItemMasters();
    expect(loaded.singleWhere((item) => item.id == created.id).hiragana, 'けんさくぎゅうにゅう');

    expect((await repository.searchCandidates('検索牛乳')).single.id, created.id);
    expect((await repository.searchCandidates('けんさくぎゅうにゅう')).single.id, created.id);
    expect(await repository.searchCandidates('けんさくぎゅうにゅう'), hasLength(1));
  });
}
