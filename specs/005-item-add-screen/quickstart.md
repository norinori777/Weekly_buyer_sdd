# Quickstart: 商品登録画面

## Goal

Verify that the item registration screen supports weekday switching by tap and swipe, opens a bottom-sheet add form, and refreshes the correct section after save.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and confirm the item-add destination opens from the main shell.
5. Swipe left and right on the weekday selector and confirm the selected day changes.
6. Tap the add action and confirm a bottom-sheet form opens.
7. Enter an item name, quantity, and section, then save it.
8. Confirm the saved item appears in the correct morning, afternoon, or evening section.

## Expected Result

The add screen should feel like a fast week-aware entry workspace where users can switch days quickly and add items without losing context.
