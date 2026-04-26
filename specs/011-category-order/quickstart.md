# Quickstart: Category Order Settings

## Goal

Verify that category order can be changed in settings and that the purchase list reflects the saved order.

## Suggested Checks

1. Run `flutter analyze`.
2. Run `flutter test`.
3. Launch the app and open the category-order settings screen.
4. Drag a category to a new position and confirm the list updates immediately.
5. Tap `保存` and confirm the purchase list screen reflects the new order.
6. Tap `キャンセル` after changing the order and confirm no database change is applied.
7. Tap `リセット` and confirm the list returns to the default ascending order.

## Expected Result

The category order can be edited safely, persisted consistently, and restored to the default order when needed.