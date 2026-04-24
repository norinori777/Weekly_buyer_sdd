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
          categoryId: drift.Value(category.id),
          defaultQuantity: const drift.Value(1),
        ),
      );

  final repository = WeeklyShoppingRepository(database);
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

    await tester.enterText(find.byType(TextField).at(0), 'テスト豆腐');
    await tester.enterText(find.byType(TextField).at(1), '2');
    await tester.tap(find.text('登録する'));
    await tester.pumpAndSettle();

    expect(find.text('テスト豆腐'), findsOneWidget);
    expect(find.text('テスト牛乳'), findsNothing);

    await tester.tap(find.byType(ChoiceChip).at(0));
    await tester.pumpAndSettle();

    expect(find.text('テスト豆腐'), findsNothing);
    expect(find.text('テスト牛乳'), findsOneWidget);
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

    await tester.scrollUntilVisible(
      find.text('私用メモ'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.enterText(find.byType(TextField).last, '夫は夕飯いらない');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('購入リスト').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('商品追加'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('私用メモ'),
      400,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('夫は夕飯いらない'), findsWidgets);
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
}
