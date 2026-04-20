# Quickstart: 翌週日付表示と曜日ボタン簡略化

## Goal

Verify that the product registration screen defaults to next calendar week and that weekday selector buttons display weekday-only labels.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and open the item-add / product registration screen.
5. Confirm the week label reflects the next calendar week (Mon–Sun).
6. Confirm the weekday selector buttons display only weekday text ("月".."日") and do not include numbers or date separators.
7. Tap different weekdays and confirm the content switches correctly.
8. Swipe left/right on the header area and confirm the selected weekday changes as before.

## Expected Result

The screen clearly communicates next week as the active planning window, and the weekday selector is visually simplified without changing selection behavior.
