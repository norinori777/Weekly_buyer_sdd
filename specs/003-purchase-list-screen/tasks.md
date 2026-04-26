# Tasks: 購入リスト画面

**Input**: Design artifacts from `specs/003-purchase-list-screen/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

## Phase 1: Purchase List Foundation

- [ ] T1 Confirm the purchase-list destination loads the current weekly list and shared week context in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: none
  - Verification: the screen opens with the correct week and list source.

- [ ] T2 Add a category-ordered active-items query and progress calculation in `weekly_buyer/lib/features/weekly_shopping_list/` data or state layer.
  - Depends on: T1
  - Verification: the screen can read `購入済み件数 / 総件数` and category-sorted items without UI-side sorting.

- [ ] T3 Define the purchase-list screen state vocabulary for progress, active items, purchased items, and undo payloads in `weekly_buyer/lib/features/weekly_shopping_list/`.
  - Depends on: T1, T2
  - Verification: state names and payloads are consistent across UI and tests.

## Phase 2: Purchase List UI

- [ ] T4 Build the purchase-list header with the progress label and category filter chips in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T2, T3
  - Verification: the header shows progress and category entry points in the intended layout.

- [ ] T5 Build the category-grouped item list and empty-state presentation in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T2, T4
  - Verification: items render under category headings and the empty state appears when no active items remain.

- [ ] T6 Build the purchase item row widget with name, quantity, and purchase affordance in `weekly_buyer/lib/features/weekly_shopping_list/presentation/`.
  - Depends on: T5
  - Verification: each row presents the item consistently and is ready for swipe interaction.

## Phase 3: Shopping Actions

- [ ] T7 Implement left-swipe purchase handling and active-list hiding in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T6
  - Verification: swiping an item marks it purchased and removes it from the active list.

- [ ] T8 Add the bottom action area with delete and undo controls in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T7
  - Verification: the actions stay visible at the bottom of the screen and are reachable without extra navigation.

- [ ] T9 Wire undo so the most recent purchased item can be restored in `weekly_buyer/lib/features/weekly_shopping_list/` state or repository layer.
  - Depends on: T7, T8
  - Verification: the latest purchase action can be reversed and the item returns to the active list.

## Phase 4: Weekly Add Entry

- [ ] T10 Confirm the `商品追加` entry point from the bottom navigation or shell opens the weekly add screen in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart` and `item_add_destination.dart`.
  - Depends on: none
  - Verification: tapping `商品追加` shows the weekly add workspace.

- [ ] T11 Build the weekly add screen layout so it clearly represents week-scoped item entry in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T10
  - Verification: the add screen is visually distinct from the purchase list and clearly scoped to the selected week.

- [ ] T12 Wire the weekly add form to share the selected week with the purchase list and commit new items back to the same week in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` and related state code.
  - Depends on: T10, T11
  - Verification: added items appear in the current week after saving.

## Phase 5: Category Order and Reuse

- [ ] T13 Apply user-defined category order to the purchase list display in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T2, T4, T5
  - Verification: categories appear in the configured order and remain stable across refreshes.

- [ ] T14 Reuse known item candidates when adding weekly items in `weekly_buyer/lib/features/weekly_shopping_list/` data and state code.
  - Depends on: T12
  - Verification: familiar items are selected from candidates instead of being recreated as new names.

## Phase 6: Verification

- [ ] T15 Add widget tests for progress display, category grouping, empty state, swipe purchase, and undo in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T4, T5, T7, T8, T9
  - Verification: the purchase-list behavior is covered end-to-end in widget tests.

- [ ] T16 Add repository/state tests for week loading, category ordering, purchase persistence, undo restoration, and item reuse in `weekly_buyer/test/`.
  - Depends on: T2, T9, T12, T14
  - Verification: the underlying data flow matches the feature expectations.

- [ ] T17 Run formatting, static analysis, and the test suite, then fix any issues in touched files.
  - Depends on: T15, T16
  - Verification: `flutter analyze` and `flutter test` succeed for the feature changes.

## Delivery Order

1. Foundation and state: T1-T3
2. Purchase list UI: T4-T6
3. Purchase and undo actions: T7-T9
4. Weekly add entry: T10-T12
5. Category order and reuse: T13-T14
6. Verification: T15-T17