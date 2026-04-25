import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:weekly_buyer/app/widgets/weekly_buyer_brand_icon.dart';

void main() {
  testWidgets('loads the SVG asset for the shared brand icon', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: WeeklyBuyerBrandIcon(size: 32),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(WeeklyBuyerBrandIcon), findsOneWidget);
  });
}