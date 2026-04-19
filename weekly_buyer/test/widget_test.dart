import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weekly_buyer/app/app_database.dart';
import 'package:weekly_buyer/app/providers.dart';
import 'package:weekly_buyer/app/weekly_buyer_app.dart';

void main() {
  testWidgets('shows the weekly shopping shell', (WidgetTester tester) async {
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

    expect(find.text('Weekly Buyer'), findsOneWidget);
    expect(find.text('商品を追加'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(3));
    expect(find.byType(ChoiceChip), findsNWidgets(7));
  });
}
