# Data Model: 商品追加画面の削除機能

## Purpose

This feature does not introduce a new persisted business entity set. It removes individual registered shopping rows from the current weekday view in the item-add screen.

## Existing Persisted Data

- Weekly shopping list records
- Weekly shopping items
- Categories and category ordering
- Item master / reusable candidates
- Weekday association for each shopping row

## Updated Behavior

### Registered Item Row

- Persisted item id
- Weekday association within the active week
- Section name
- Item name
- Quantity
- Purchase state
- Category association
- Item master association
- Sort order and timestamps

## New Session State

### Item Add State

- Selected weekday tab: Monday through Sunday or Other
- Selected section: morning, afternoon, or evening
- Current draft item name
- Current draft quantity
- Selected candidate, if any

### Week Context

- Shared active week selection already used by the purchase list screen
- Selected date within that week for the current add session

## Presentation State

### Item List Row

- The row content for each registered item
- The delete control on the right end of the row
- Empty state when no items remain

### Bottom Sheet Form

- Form visibility
- Draft values while the sheet is open
- Submit state during save

## Relationships

- The active week contains several weekday registrations.
- Each displayed row belongs to exactly one weekday inside that active week.
- The delete action removes only the selected registered row.
- The add screen reloads the selected weekday after deletion so the visible list stays accurate.

## Notes

- The reusable item catalog should remain unchanged when a weekly row is deleted.
- Duplicate item names are allowed, so row identity should remain the deletion target.
