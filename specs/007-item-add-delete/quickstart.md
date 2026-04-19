# Quickstart: 商品追加画面の削除機能

## Goal

Verify that each registered item in the add screen can be deleted from the right edge of its row and that the selected weekday view updates immediately.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and open the item-add destination.
5. Register two or more items in the same weekday.
6. Confirm each row shows a recognizable delete icon at the right end.
7. Tap the delete icon on one row.
8. Confirm only the tapped row disappears and the remaining rows stay visible.
9. Switch to another weekday and confirm its rows are unchanged.

## Expected Result

The add screen should support quick per-item removal with a clear delete affordance, without changing the active weekday context or affecting other registered items.
