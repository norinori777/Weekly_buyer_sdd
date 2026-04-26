# Data Model: 曜日別商品登録

## Purpose

This feature keeps the active week as the outer scope but adds weekday-specific storage and filtering so items saved on one weekday do not appear on another weekday.

## Existing Persisted Data

- Weekly shopping list records
- Weekly shopping items
- Categories and category ordering
- Item master / reusable candidates

## Updated Persisted Data

### Weekly List Item

- Active week identifier
- Weekday association within the week
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

### Weekday Selector

- The highlighted weekday tab
- Swipe navigation state for moving to the previous or next weekday

### Weekday View

- Items for the selected weekday only
- Empty state when no items exist for that weekday
- Registration summary for the active weekday

### Bottom Sheet Form

- Form visibility
- Draft values while the sheet is open
- Submit state during save

## Relationships

- The active week contains several weekday registrations.
- Each saved item belongs to exactly one weekday inside that active week.
- The add screen reads only the items for the selected weekday.
- The bottom-sheet form writes new items to the selected weekday, not to the week as a whole.

## Notes

- Existing rows should remain readable after the weekday association is introduced.
- If the app currently treats "Other" as a weekday selector value, it should continue to be supported as a selectable registration bucket.