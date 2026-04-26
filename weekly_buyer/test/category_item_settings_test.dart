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

DateTime _nextWeekStart() {
  return startOfNextWeek(dateOnly(DateTime.now()));
}

Future<void> _openCategoryItemSettings(WidgetTester tester) async {
  await tester.tap(find.text('設定'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('カテゴリと商品'));
  await tester.pumpAndSettle();
}

Future<void> _seedCategoryWithReference(
  AppDatabase database, {
  required String categoryName,
  required String itemName,
}) async {
  final categoryRow = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
          name: categoryName,
          sortOrder: const drift.Value(-1),
        ),
      );
  final repository = WeeklyShoppingRepository(database);
  await repository.addItemMaster(
    name: itemName,
    hiragana: 'てすとぎゅうにゅう',
    categoryId: categoryRow.id,
  );
  await repository.addItem(
    referenceDate: _nextWeekStart(),
    request: AddItemRequest(
      name: itemName,
      quantity: 1,
      section: ShoppingSection.morning,
      categoryId: categoryRow.id,
    ),
  );
}

void main() {
  testWidgets('opens category and item editors without color, description, or quantity fields', (
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

    await _openCategoryItemSettings(tester);

    await tester.tap(find.text('カテゴリを追加'));
    await tester.pumpAndSettle();

    expect(find.text('カテゴリ名'), findsOneWidget);
    expect(find.text('色'), findsNothing);
    expect(find.text('説明'), findsNothing);

    await tester.tap(find.text('キャンセル').last);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, '商品'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('商品を追加'));
    await tester.pumpAndSettle();

    expect(find.text('商品名'), findsOneWidget);
    expect(find.text('ひらがな'), findsOneWidget);
    expect(find.text('数量'), findsNothing);
  });

  testWidgets('preserves item hiragana when editing an existing item', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    final categoryRow = await database.into(database.categories).insertReturning(
          CategoriesCompanion.insert(
            name: '編集カテゴリ',
            sortOrder: const drift.Value(0),
          ),
        );
    final repository = WeeklyShoppingRepository(database);
    await repository.addItemMaster(
      name: '編集商品',
      hiragana: 'へんしゅうしょうひん',
      categoryId: categoryRow.id,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();
    await _openCategoryItemSettings(tester);

    await tester.tap(find.widgetWithText(Tab, '商品'));
    await tester.pumpAndSettle();

    final itemCard = find.ancestor(
      of: find.text('編集商品'),
      matching: find.byType(Card),
    );
    await tester.tap(find.descendant(of: itemCard, matching: find.byIcon(Icons.edit_outlined)));
    await tester.pumpAndSettle();

    final fields = tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields.length, greaterThanOrEqualTo(2));
    expect(fields[0].controller?.text, '編集商品');
    expect(fields[1].controller?.text, 'へんしゅうしょうひん');
  });

  testWidgets('disables delete actions when items exist or are used in the current week', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await _seedCategoryWithReference(
      database,
      categoryName: 'テストカテゴリ',
      itemName: 'テスト牛乳',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await _openCategoryItemSettings(tester);

    expect(find.text('商品が 1 件あるため削除できません'), findsOneWidget);

    final categoryCard = find.ancestor(
      of: find.text('テストカテゴリ'),
      matching: find.byType(Card),
    );
    final categoryButtons = tester
        .widgetList<IconButton>(
          find.descendant(of: categoryCard, matching: find.byType(IconButton)),
        )
        .toList();
    expect(categoryButtons.any((button) => button.onPressed == null), isTrue);

    await tester.tap(find.widgetWithText(Tab, '商品'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int?>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('テストカテゴリ').last);
    await tester.pumpAndSettle();

    expect(
      find.textContaining('現在の購入週に含まれているため削除できません'),
      findsOneWidget,
    );

    final itemCard = find.ancestor(
      of: find.text('テスト牛乳'),
      matching: find.byType(Card),
    );
    final itemButtons = tester
        .widgetList<IconButton>(
          find.descendant(of: itemCard, matching: find.byType(IconButton)),
        )
        .toList();
    expect(itemButtons.any((button) => button.onPressed == null), isTrue);
  });
}
