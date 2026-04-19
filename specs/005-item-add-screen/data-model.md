# Data Model: 商品登録画面

## Purpose

This feature does not add a new persisted business entity set. It changes how the existing weekly shopping data is entered and how the add-screen session state is managed.

## Existing Persisted Data

- Weekly shopping list records
- Weekly shopping items
- Categories and category ordering
- Item master / reusable candidates

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

### Section Panels

- Morning section items
- Afternoon section items
- Evening section items

### Bottom Sheet Form

- Form visibility
- Draft values while the sheet is open
- Submit state during save

## Relationships

- The active weekday selection drives which section content the screen shows.
- The bottom-sheet form writes new items to the selected weekday and section.
- Draft form values are transient and should not be written directly to the shopping database until submission.
- The shared week context should remain aligned with the purchase list screen so both destinations reflect the same shopping week.

## Notes

- If swipe navigation and tab selection both change the selected weekday, they should update the same shared state.
- The Other tab is treated as part of the weekday selector, while the display sections remain morning, afternoon, and evening.
