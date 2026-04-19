import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/app/providers.dart';
import 'package:weekly_buyer/app/weekly_buyer_app.dart';

void main() {
  testWidgets('shows the main shell and switches destinations', (WidgetTester tester) async {
    final database = AppDatabase(executor: NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const WeeklyBuyerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('購入リスト'), findsWidgets);
    expect(find.text('商品を追加'), findsOneWidget);

    await tester.tap(find.text('商品追加').first);
    await tester.pumpAndSettle();

    expect(find.text('保存して購入リストへ戻る'), findsOneWidget);

    await tester.tap(find.text('購入リスト').first);
    await tester.pumpAndSettle();

    expect(find.text('商品を追加'), findsOneWidget);
  });
}
