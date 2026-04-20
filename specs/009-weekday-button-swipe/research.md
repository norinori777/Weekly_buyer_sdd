# Research: 曜日ボタン簡略化とスワイプ切替

## Decision 1: Keep weekday switching in the existing header widget

Weekday switching is a presentation concern and already centralized in the header component. Keeping changes in the header avoids touching repository or database logic.

## Decision 2: Remove numeric dates from weekday button labels only

The request is to simplify the weekday selector buttons. The week-range label can remain to preserve context while removing clutter from the chips.

## Decision 3: Use the same selected-date state for both tap and swipe

The app already uses a selected date to drive weekday-scoped content. Tap and swipe should both update the same state to prevent divergence.

## Decision 4: Clamp swipe navigation within week bounds

Swiping at the first/last weekday should not move outside the current week. This matches the spec’s edge cases and prevents confusing “week jump” behavior.
