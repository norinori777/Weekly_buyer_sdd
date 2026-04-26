# Quickstart: 購入・登録フロー

## Goal

Verify that the corrected shopping workspace behaves as two distinct screens: a read-only category-based purchase list and a dedicated item registration flow.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and confirm it opens to the purchase list destination.
5. Confirm the purchase list shows categories and no item-creation controls on the main list view.
6. Open item add from the bottom add action and confirm the add screen preserves the selected week context.
7. Switch back to the purchase list and confirm the selected week is unchanged.
8. Swipe a purchase item left and confirm it disappears from the active list and can be restored with undo.

## Expected Result

The app should feel like a single shared weekly shopping workspace with a clear separation between browsing the purchase list and entering new items.
