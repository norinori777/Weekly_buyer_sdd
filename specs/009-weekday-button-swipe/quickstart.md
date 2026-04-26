# Quickstart: 曜日ボタン簡略化とスワイプ切替

## Goal

Verify weekday chip labels show weekday-only text and that left/right swipes switch weekdays within the current week bounds.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and open the item-add / product registration screen.
5. Confirm the weekday selector chips show only “月..日” and contain no digits.
6. Swipe left/right on the header/weekday selector area and confirm the selected weekday changes to the adjacent day.
7. Swipe right on the first weekday and confirm it does not move outside the week.
8. Swipe left on the last weekday and confirm it does not move outside the week.

## Expected Result

Weekday switching is fast via swipe, and the weekday selector is visually simplified without losing selection clarity.
