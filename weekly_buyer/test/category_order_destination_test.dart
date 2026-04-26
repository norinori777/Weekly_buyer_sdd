import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
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

Future<void> _seedCategoryWithItem(
  AppDatabase database, {
  required String categoryName,
  required int sortOrder,
  required String itemName,
}) async {
  final category = await database.into(database.categories).insertReturning(
        CategoriesCompanion.insert(
          name: categoryName,
          sortOrder: drift.Value(sortOrder),
        ),
      );

  await database.into(database.itemMasters).insert(
        ItemMastersCompanion.insert(
          name: itemName,
          categoryId: drift.Value(category.id),
          defaultQuantity: const drift.Value(1),
        ),
      );

  await WeeklyShoppingRepository(database).addItem(
    referenceDate: _nextWeekStart(),
    request: AddItemRequest(
      name: itemName,
      quantity: 1,
      section: ShoppingSection.morning,
      categoryId: category.id,
    ),
  );
}

void main() {
  testWidgets('reorders categories from settings and updates purchase list order', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await _seedCategoryWithItem(
      database,
      categoryName: '食品',
      sortOrder: 0,
      itemName: 'テスト牛乳',
    );
    await _seedCategoryWithItem(
      database,
      categoryName: '日用品',
      sortOrder: 1,
      itemName: 'テスト洗剤',
    );
    await _seedCategoryWithItem(
      database,
      categoryName: '飲料',
      sortOrder: 2,
      itemName: 'テストお茶',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('カテゴリの並び順'));
    await tester.pumpAndSettle();

    expect(find.text('食品'), findsOneWidget);
    expect(find.text('日用品'), findsOneWidget);
    expect(find.text('飲料'), findsOneWidget);
    expect(find.text('保存'), findsOneWidget);
    expect(find.text('リセット'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);

    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.text('カテゴリの並び順'), findsOneWidget);
    expect(find.text('買い物の見やすさを調整する設定画面です。'), findsOneWidget);
  });
}