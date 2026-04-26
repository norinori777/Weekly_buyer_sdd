# Tasks: Weekly Shopping List

**Input**: Design artifacts from `specs/001-weekly-shopping-list/`  
**Prerequisites**: `spec.md`, `plan.md`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

## Phase 1: Project Foundation

- [ ] T1 Confirm the app entry uses `ProviderScope` and the Material 3 app shell from the current Flutter root.
  - Depends on: none
  - Verification: app starts and shows the new root screen without the template counter UI.

- [ ] T2 Establish the feature folder layout for presentation, state, data, and reusable components.
  - Depends on: T1
  - Verification: feature code can be placed under stable folders without mixing UI and persistence concerns.

- [ ] T3 Define the shared domain vocabulary for weekly list, shopping item, category, item master, and other list.
  - Depends on: T2
  - Verification: the same names are used consistently in code and tests.

## Phase 2: Local Persistence Foundation

- [ ] T4 Implement the Drift database scaffold and connect it to the app through a repository entry point.
  - Depends on: T2, T3
  - Verification: the database can be created and opened from the app layer.

- [ ] T5 Add the initial Drift tables for categories, item master, weekly list, weekly list item, and recipe group entities.
  - Depends on: T4
  - Verification: schema generation or compilation succeeds for the data model.

- [ ] T6 Add repository methods for creating and loading weekly lists by Monday-start week key.
  - Depends on: T4, T5
  - Verification: a week can be created, reloaded, and resolved uniquely.

- [ ] T7 Add repository methods for reusable item candidates and category ordering.
  - Depends on: T4, T5
  - Verification: candidate lookup and category reads work without direct SQL in UI code.

## Phase 3: Weekly Screen Shell

- [ ] T8 Build the weekly screen shell with the selected week header and section host area.
  - Depends on: T1, T6
  - Verification: the app shows a week-oriented screen instead of the template counter.

- [ ] T9 Implement the weekday switcher in the header using Monday through Sunday.
  - Depends on: T8
  - Verification: the header displays seven day chips and highlights the active day.

- [ ] T10 Add the day-independent `Other` section to the screen shell as a separate list area.
  - Depends on: T8, T9
  - Verification: `Other` appears as its own section and is not mixed with morning/afternoon/evening.

## Phase 4: Item Add Flow

- [ ] T11 Build the morning, afternoon, and evening section widgets with item counts and add actions.
  - Depends on: T8, T9
  - Verification: each section renders its header, count, and add trigger.

- [ ] T12 Build the item row widget with name, quantity, and purchase state presentation.
  - Depends on: T11
  - Verification: rows render consistently across all sections.

- [ ] T13 Implement the bottom add operation area and modal sheet entry point for creating or selecting items.
  - Depends on: T11, T12
  - Verification: the add action opens a sheet and returns an item payload.

- [ ] T14 Wire the add sheet to support both reusable candidate selection and new item registration.
  - Depends on: T6, T7, T13
  - Verification: known items can be reused and unknown items can be saved as reusable candidates.

- [ ] T15 Wire the add sheet to place items into morning, afternoon, evening, or `Other`.
  - Depends on: T10, T13, T14
  - Verification: an added item is stored in the selected section and appears in the right list.

## Phase 5: Shopping Behavior

- [ ] T16 Implement purchase toggling for list items and persist the purchased state.
  - Depends on: T6, T12
  - Verification: purchased items remain stored with the correct state.

- [ ] T17 Hide purchased items from the active view until restored.
  - Depends on: T16
  - Verification: purchased rows disappear from the visible list but remain recoverable.

- [ ] T18 Implement undo for the most recent purchased item.
  - Depends on: T16, T17
  - Verification: one undo action restores the latest purchased item.

## Phase 6: Category and Candidate Management

- [ ] T19 Add category management support for ordering categories in the shopping view.
  - Depends on: T7, T8
  - Verification: category order can be read and applied consistently.

- [ ] T20 Make category order affect section and item display in the shopping screen.
  - Depends on: T19
  - Verification: items appear in the user-defined category order.

- [ ] T21 Ensure item master reuse paths are exercised when adding familiar items repeatedly.
  - Depends on: T14
  - Verification: a familiar item is selected from candidates instead of duplicated as a new master.

## Phase 7: Testing and Validation

- [ ] T22 Add widget tests for the weekly screen shell, weekday switcher, and `Other` section.
  - Depends on: T8, T9, T10, T11
  - Verification: the add screen structure matches the planned layout.

- [ ] T23 Add repository tests for weekly list creation, week lookup, and candidate reuse.
  - Depends on: T6, T7
  - Verification: database behavior matches the Monday-start week rule and reuse expectations.

- [ ] T24 Add behavior tests for purchase, hide, and undo flows.
  - Depends on: T16, T17, T18
  - Verification: the shopping flow preserves the most recent undo behavior.

- [ ] T25 Run formatting, static analysis, and test commands before merge.
  - Depends on: T22, T23, T24
  - Verification: `flutter format`, `flutter analyze`, and `flutter test` succeed.

## Delivery Order

1. Foundation and data scaffold: T1-T7
2. Weekly screen and add flow: T8-T15
3. Shopping behavior and category logic: T16-T21
4. Verification: T22-T25
