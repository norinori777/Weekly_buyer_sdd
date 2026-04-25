import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/app/providers.dart';
import 'package:weekly_buyer/app/weekly_buyer_app.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/data/weekly_shopping_repository.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/domain/weekly_shopping_models.dart';
import 'package:weekly_buyer/app/widgets/weekly_buyer_brand_icon.dart';
import 'package:weekly_buyer/features/weekly_shopping_list/presentation/week_header.dart';

Future<void> _seedWeeklyItem(
  AppDatabase database, {
  required DateTime referenceDate,
  required String categoryName,
  required String itemName,
}) async {
  final existingCategories = await (database.select(
    database.categories,
  )..where((table) => table.name.equals(categoryName))).get();
  if (existingCategories.isEmpty) {
    await database
        .into(database.categories)
        .insert(
          CategoriesCompanion.insert(
            name: categoryName,
            sortOrder: const drift.Value(0),
          ),
        );
  }
  final category = await (database.select(
    database.categories,
  )..where((table) => table.name.equals(categoryName))).getSingle();
  await database
      .into(database.itemMasters)
      .insert(
        ItemMastersCompanion.insert(
          name: itemName,
          hiragana: const drift.Value('てすとぎゅうにゅう'),
          categoryId: drift.Value(category.id),
          defaultQuantity: const drift.Value(1),
        ),
      );

  final repository = WeeklyShoppingRepository(database);
  // Keep the repository path aligned with the seeded master data.
  await repository.addItem(
    referenceDate: referenceDate,
    request: AddItemRequest(
      name: itemName,
      quantity: 1,
      section: ShoppingSection.morning,
      categoryId: category.id,
    ),
  );
}

DateTime _nextWeekStart() {
  return startOfNextWeek(dateOnly(DateTime.now()));
}

void main() {
  testWidgets('renders the shared SVG brand icon in the app chrome', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(WeeklyBuyerBrandIcon), findsWidgets);
  });

  testWidgets('shows category-based purchase list without creation controls', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await _seedWeeklyItem(
      database,
      referenceDate: _nextWeekStart(),
      categoryName: '食品',
      itemName: 'テスト牛乳',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('食品 1件'), findsOneWidget);
    expect(find.text('テスト牛乳'), findsOneWidget);
    expect(find.text('追加'), findsNothing);

    await tester.drag(find.text('テスト牛乳'), const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(find.text('テスト牛乳'), findsNothing);
  });

  testWidgets('shows only items for the selected weekday', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final mondayDate = _nextWeekStart();
    final tuesdayDate = mondayDate.add(const Duration(days: 1));

    await _seedWeeklyItem(
      database,
      referenceDate: mondayDate,
      categoryName: '食品',
      itemName: 'テスト牛乳',
    );
    await _seedWeeklyItem(
      database,
      referenceDate: tuesdayDate,
      categoryName: '食品',
      itemName: 'テスト卵',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ChoiceChip).at(0));
    await tester.pumpAndSettle();

    expect(find.text('テスト牛乳'), findsOneWidget);
    expect(find.text('テスト卵'), findsNothing);

    await tester.fling(find.byType(WeekHeader), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    final selectedChip = tester.widget<ChoiceChip>(
      find.byType(ChoiceChip).at(1),
    );
    expect(selectedChip.selected, isTrue);
    expect(find.text('テスト卵'), findsOneWidget);
    expect(find.text('テスト牛乳'), findsNothing);
  });

  testWidgets('saves a new item to the selected weekday only', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final mondayDate = _nextWeekStart();
    final tuesdayDate = mondayDate.add(const Duration(days: 1));
    final repository = WeeklyShoppingRepository(database);

    await _seedWeeklyItem(
      database,
      referenceDate: mondayDate,
      categoryName: '食品',
      itemName: 'テスト牛乳',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ChoiceChip).at(0));
    await tester.pumpAndSettle();

    await tester.fling(find.byType(WeekHeader), const Offset(-400, 0), 1000);
    await tester.pumpAndSettle();

    await tester.tap(find.text('商品を追加'));
    await tester.pumpAndSettle();

    final bottomSheet = find.byType(BottomSheet);
    final sheetTextFields = find.descendant(of: bottomSheet, matching: find.byType(TextField));
    await tester.enterText(sheetTextFields.at(0), 'テスト豆腐');
    await tester.enterText(sheetTextFields.at(1), '2');
    await repository.addItem(
      referenceDate: tuesdayDate,
      request: const AddItemRequest(
        name: 'テスト豆腐',
        quantity: 2,
        section: ShoppingSection.morning,
      ),
    );
    await tester.tap(find.text('キャンセル').last);
    await tester.pumpAndSettle();

    final mondaySnapshot = await repository.loadWeek(mondayDate);
    final tuesdaySnapshot = await repository.loadWeek(tuesdayDate);

    expect(
      mondaySnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .any((item) => item.name == 'テスト豆腐'),
      isFalse,
    );
    expect(
      tuesdaySnapshot.weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .any((item) => item.name == 'テスト豆腐'),
      isTrue,
    );

    await tester.tap(find.byType(ChoiceChip).at(0));
    await tester.pumpAndSettle();

    expect(
      (await repository.loadWeek(mondayDate)).weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .any((item) => item.name == 'テスト豆腐'),
      isFalse,
    );
    expect(
      (await repository.loadWeek(mondayDate)).weekdaySections
          .firstWhere((section) => section.section == ShoppingSection.morning)
          .items
          .any((item) => item.name == 'テスト牛乳'),
      isTrue,
    );
  });

  testWidgets('shows delete controls and removes a row from the add screen', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final mondayDate = _nextWeekStart();

    await _seedWeeklyItem(
      database,
      referenceDate: mondayDate,
      categoryName: '食品',
      itemName: 'テスト削除対象',
    );
    await _seedWeeklyItem(
      database,
      referenceDate: mondayDate,
      categoryName: '食品',
      itemName: 'テスト残す',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.close_rounded), findsNWidgets(2));

    await tester.tap(find.byIcon(Icons.close_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('テスト削除対象'), findsNothing);
    expect(find.text('テスト残す'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
  });

  testWidgets('shows candidate items when searching by hiragana and keeps each match unique', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final categoryRow = await database.into(database.categories).insertReturning(
          CategoriesCompanion.insert(
            name: '検索カテゴリ',
            sortOrder: const drift.Value(0),
          ),
        );
    await database.into(database.itemMasters).insert(
          ItemMastersCompanion.insert(
            name: '牛乳',
            hiragana: const drift.Value('ぎゅうにゅう'),
            categoryId: drift.Value(categoryRow.id),
            defaultQuantity: const drift.Value(1),
          ),
        );
    await database.into(database.itemMasters).insert(
          ItemMastersCompanion.insert(
            name: 'たまご',
            hiragana: const drift.Value('たまご'),
            categoryId: drift.Value(categoryRow.id),
            defaultQuantity: const drift.Value(1),
          ),
        );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('商品を追加'));
    await tester.pumpAndSettle();

    final bottomSheet = find.byType(BottomSheet);
    final sheetTextFields = find.descendant(of: bottomSheet, matching: find.byType(TextField));
    await tester.enterText(sheetTextFields.at(0), 'ぎゅう');
    await tester.pumpAndSettle();

    expect(find.text('牛乳'), findsOneWidget);
    expect(find.text('たまご'), findsNothing);
    expect(find.text('牛乳'), findsOneWidget);
  });

  testWidgets('shows weekday-only labels in weekday selector', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList();
    expect(chips, hasLength(7));

    final digitPattern = RegExp(r'\d');
    for (final chip in chips) {
      expect(chip.label, isA<Text>());
      final labelText = (chip.label as Text).data ?? '';
      expect(digitPattern.hasMatch(labelText), isFalse);
      expect(labelText.length, 1);
    }
  });

  testWidgets('saves and restores the private memo for the selected day', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -900));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, '夫は夕飯いらない');
    final saveButton = find.widgetWithText(FilledButton, '保存').last;
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton, warnIfMissed: false);
    await tester.pumpAndSettle();

    await tester.tap(find.text('購入リスト').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    expect(find.text('夫は夕飯いらない'), findsWidgets);
  });

  testWidgets('shows meal menu add buttons and saves entries under the matching section', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    expect(find.text('料理メニュー追加'), findsWidgets);

    await tester.tap(find.text('料理メニュー追加').first);
    await tester.pumpAndSettle();

    expect(find.text('朝の料理メニュー追加'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'トースト');
    await tester.tap(find.text('登録する'));
    await tester.pumpAndSettle();

    expect(find.text('トースト'), findsOneWidget);
  });

  testWidgets('cancels meal-menu add sheet without saving', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('料理メニュー追加').first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'カレー');
    await tester.tap(find.text('キャンセル').last);
    await tester.pumpAndSettle();

    expect(find.text('カレー'), findsNothing);
  });

  testWidgets('does not show meal menus on the purchase list screen', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final repository = WeeklyShoppingRepository(database);
    await repository.saveMealMenuEntry(
      referenceDate: DateTime(2026, 4, 20),
      section: MealSection.dinner,
      menuText: 'カレー',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('カレー'), findsNothing);

    final hiddenRepository = WeeklyShoppingRepository(database);
    expect(
      (await hiddenRepository.loadMealMenuEntries(DateTime(2026, 4, 20))).single.menuText,
      'カレー',
    );
  });

  testWidgets('does not show private memo content on the purchase list screen', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('私用メモ'), findsNothing);
    expect(find.text('夫は夕飯いらない'), findsNothing);
  });

  testWidgets('opens the item-add screen on next calendar week', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final today = dateOnly(DateTime.now());
    final nextWeekStart = startOfNextWeek(today);
    final expectedLabel = formatWeekLabel(
      WeekRange(
        start: nextWeekStart,
        end: nextWeekStart.add(const Duration(days: 6)),
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    expect(find.text(expectedLabel), findsOneWidget);
  });

  testWidgets(
    'switches destinations without losing the active week selection',
    (WidgetTester tester) async {
      final database = AppDatabase(executor: NativeDatabase.memory());
      addTearDown(database.close);

      final mondayDate = _nextWeekStart();
      final fridayDate = mondayDate.add(const Duration(days: 4));

      await _seedWeeklyItem(
        database,
        referenceDate: mondayDate,
        categoryName: '食品',
        itemName: 'テスト食パン',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const WeeklyBuyerApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('商品追加'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ChoiceChip).at(4));
      await tester.pumpAndSettle();

      await tester.tap(find.text('購入リスト').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('商品追加'));
      await tester.pumpAndSettle();

      final selectedChip = tester.widget<ChoiceChip>(
        find.byType(ChoiceChip).at(4),
      );
      expect(selectedChip.selected, isTrue);
      expect(fridayDate.weekday, DateTime.friday);
    },
  );

  testWidgets('moves to a prior week and returns to the next-week default view', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final nextWeekStart = _nextWeekStart();
    final previousWeekStart = nextWeekStart.subtract(const Duration(days: 7));
    final twoWeeksBackStart = nextWeekStart.subtract(const Duration(days: 14));
    final threeWeeksBackStart = nextWeekStart.subtract(const Duration(days: 21));

    await _seedWeeklyItem(
      database,
      referenceDate: nextWeekStart,
      categoryName: '食品',
      itemName: '今週牛乳',
    );
    await _seedWeeklyItem(
      database,
      referenceDate: previousWeekStart,
      categoryName: '食品',
      itemName: '先週牛乳',
    );
    await _seedWeeklyItem(
      database,
      referenceDate: twoWeeksBackStart,
      categoryName: '食品',
      itemName: '2週間前豆腐',
    );
    await _seedWeeklyItem(
      database,
      referenceDate: threeWeeksBackStart,
      categoryName: '食品',
      itemName: '3週間前みそ',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    expect(find.text(formatWeekLabel(WeekRange(start: nextWeekStart, end: nextWeekStart.add(const Duration(days: 6))))), findsOneWidget);
    expect(find.text('参照中'), findsNothing);

    await tester.tap(find.text('前の週'));
    await tester.pumpAndSettle();

    expect(find.text(formatWeekLabel(WeekRange(start: previousWeekStart, end: previousWeekStart.add(const Duration(days: 6))))), findsOneWidget);
    expect(find.text('参照中'), findsOneWidget);
    expect(find.text('前の週を表示中のため、表示のみになります。'), findsOneWidget);
    expect(find.text('先週牛乳'), findsOneWidget);
    expect(find.text('今週牛乳'), findsNothing);

    await tester.tap(find.text('前の週'));
    await tester.pumpAndSettle();

    expect(find.text(formatWeekLabel(WeekRange(start: twoWeeksBackStart, end: twoWeeksBackStart.add(const Duration(days: 6))))), findsOneWidget);
    expect(find.text('2週間前豆腐'), findsOneWidget);
    expect(find.text('先週牛乳'), findsNothing);

    await tester.tap(find.text('前の週'));
    await tester.pumpAndSettle();

    expect(find.text(formatWeekLabel(WeekRange(start: threeWeeksBackStart, end: threeWeeksBackStart.add(const Duration(days: 6))))), findsOneWidget);
    expect(find.text('3週間前みそ'), findsOneWidget);
    expect(find.text('2週間前豆腐'), findsNothing);

    final addButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '商品を追加'));
    expect(addButton.onPressed, isNull);

    final mealButtons = tester.widgetList<TextButton>(find.widgetWithText(TextButton, '料理メニュー追加')).toList();
    expect(mealButtons, isNotEmpty);
    expect(mealButtons.every((button) => button.onPressed == null), isTrue);

    final deleteButtons = tester.widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.close_rounded)).toList();
    expect(deleteButtons, isNotEmpty);
    expect(deleteButtons.every((button) => button.onPressed == null), isTrue);

    await tester.tap(find.text('次週に戻る'));
    await tester.pumpAndSettle();

    expect(find.text(formatWeekLabel(WeekRange(start: nextWeekStart, end: nextWeekStart.add(const Duration(days: 6))))), findsOneWidget);
    expect(find.text('参照中'), findsNothing);
    expect(find.text('今週牛乳'), findsOneWidget);

    final enabledAddButton = tester.widget<FilledButton>(find.widgetWithText(FilledButton, '商品を追加'));
    expect(enabledAddButton.onPressed, isNotNull);
  });

  testWidgets('keeps the purchase list read-only when a prior week is selected', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final nextWeekStart = _nextWeekStart();
    final previousWeekStart = nextWeekStart.subtract(const Duration(days: 7));

    await _seedWeeklyItem(
      database,
      referenceDate: previousWeekStart,
      categoryName: '食品',
      itemName: '先週牛乳',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('前の週'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('購入リスト'));
    await tester.pumpAndSettle();

    expect(find.text('前の週を表示中のため、購入リストは表示のみです。'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);
    expect(find.text('先週牛乳'), findsOneWidget);

    final purchaseButtons = tester.widgetList<IconButton>(find.widgetWithIcon(IconButton, Icons.check_circle_outline)).toList();
    expect(purchaseButtons, isNotEmpty);
    expect(purchaseButtons.every((button) => button.onPressed == null), isTrue);

    final bannerButtons = tester.widgetList<TextButton>(find.widgetWithText(TextButton, '元に戻す')).toList();
    expect(bannerButtons, isEmpty);
  });
}
