# Quickstart: 曜日別商品登録

## Goal

Verify that each weekday stores its own shopping items, and switching from one weekday to another does not display the previous weekday's registrations.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and confirm the item-add destination opens from the main shell.
5. Register an item on Monday.
6. Switch to Tuesday and confirm Monday's item is not shown.
7. Switch back to Monday and confirm the Monday item is still present.
8. Add items to two different weekdays and confirm each weekday shows only its own items.

## Expected Result

The add screen should behave like a week-aware workspace where each weekday keeps its own registration list inside the same shared week.