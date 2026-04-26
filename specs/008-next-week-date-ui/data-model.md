# Data Model: 翌週日付表示と曜日ボタン簡略化

## Purpose

This feature does not introduce new persisted entities. It changes the default week context used by the product registration screen to “next calendar week” and simplifies weekday button labels.

## Existing Persisted Data

- Weekly shopping list records (keyed by week start/end)
- Weekly list items (with weekday association)
- Item master / candidates
- Categories and ordering

## Updated Behavior

### Active Week

- The active week shown on the product registration screen is computed from a reference date.
- For this feature, the default reference date must fall within the next calendar week (Monday start, Sunday end).

### Weekday Selector Labels

- Weekday selector buttons display weekday-only labels.
- The mapping from weekday selection to the associated date continues to be derived from the active week range.

## Session State

- Selected date remains the single session state used to scope the active week.
- If a “now” abstraction is introduced for testing, it should be treated as session/runtime context, not persisted data.

## Relationships

- The active week defines the set of weekday dates (Mon–Sun).
- Each weekly list item belongs to exactly one weekday inside that week.
- Switching weekday changes the view to the selected weekday’s items within the active week.

## Notes

- No migration is required.
- The change should remain consistent across month/year boundaries.
