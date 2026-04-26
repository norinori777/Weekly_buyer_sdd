# Data Model: 曜日ボタン簡略化とスワイプ切替

## Purpose

This feature changes UI behavior and label formatting only. It does not add or modify persisted entities.

## Existing Persisted Data

- Weekly lists (week start/end)
- Weekly list items (weekday association, section, item details)
- Item masters / candidates
- Categories

## Updated Behavior

### Weekday Selector Labels

- Weekday selector buttons show weekday-only text.
- No numeric date is included in the button label.

### Weekday Switching

- The selected weekday changes through either tap selection or horizontal swipe.
- Swipes clamp to the current week’s weekday range.

## Session State

- Selected date remains the single source of truth for the active weekday.
- The view updates when the selected date changes.

## Notes

- No migration required.
- No changes to repository queries or item persistence are needed.
