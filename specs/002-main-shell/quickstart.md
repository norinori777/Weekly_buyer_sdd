# Quickstart: Main Shell

## Goal

Verify that the app opens into the shared shell and that purchase list, item add, and settings can be switched without losing the selected week.

## Suggested Checks

1. Run `flutter pub get`.
2. Run `flutter analyze`.
3. Run `flutter test`.
4. Launch the app and confirm the default destination is the purchase list.
5. Switch between purchase list, item add, and settings and confirm the selected week stays the same.
6. Open item add from the purchase list and confirm the quick add path still works.

## Expected Result

The app should feel like one shared shopping workspace with three top-level destinations rather than three disconnected screens.
