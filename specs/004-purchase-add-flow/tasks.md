# Tasks: 購入・登録フロー

**Input**: Design artifacts from `specs/004-purchase-add-flow/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Shared Domain and Navigation Foundation

**Purpose**: Reframe the shared weekly snapshot and shell state so the purchase list can become category-based and the item add flow can own weekday switching.

- [ ] T001 [P] Update the weekly shopping domain contract to support category-grouped purchase data and shared week-scoped add context in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
  - Depends on: none
  - Verification: the domain layer can describe category-grouped purchase output, a shared week context, and the add-form payload without UI-specific reshaping.

- [ ] T002 Convert the weekly repository load path to emit category-grouped active items, hidden-purchase counts, undo payloads, and reusable candidates in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
  - Depends on: T001
  - Verification: both screens can read one weekly snapshot from the repository, including category ordering and undo information.

- [ ] T003 [P] Align shared providers and shell state so selected week, selected destination, and previous shopping destination remain separate concerns in `weekly_buyer/lib/app/providers.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T001, T002
  - Verification: destination switching still works, and the shell has one stable source of truth for the active week.

**Checkpoint**: The shared data and shell state are ready for screen-specific work.

---

## Phase 2: User Story 1 - Purchase items from a category-based list (Priority: P1)

**Goal**: Show the current week as a category-grouped purchase list, hide purchased items immediately, and keep undo available without exposing item creation.

**Independent Test**: Open the purchase list, confirm the items are grouped by category, left-swipe an item to hide it, and use undo to restore the latest purchase.

- [ ] T004 [P] Rebuild the purchase list screen to remove week headers, weekday tabs, and section-level add buttons while keeping category-grouped output in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T002, T003
  - Verification: the purchase list is read-only for item creation and shows only the purchase flow the spec requires.

- [ ] T005 [P] Extract or refactor the shared list-row and group widgets so purchase rows can be hidden immediately after a left swipe and the empty state remains clear in `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T004
  - Verification: a swipe marks an item purchased, removes it from the visible list, and keeps the empty-state text understandable.

- [ ] T006 Wire undo feedback and restore behavior so the most recent purchase can be reversed from the purchase list in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T004, T005
  - Verification: the last purchased item returns to the active list after undo.

- [ ] T007 [P] Add widget tests for category grouping, no creation controls, swipe-to-purchase, hidden purchased items, and undo in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T004, T005, T006
  - Verification: the purchase list behavior is covered end to end.

**Checkpoint**: The purchase list behaves as a read-only shopping view with swipe completion and undo.

---

## Phase 3: User Story 2 - Register items by day within a week (Priority: P1)

**Goal**: Make the item registration screen the dedicated add flow, let users switch the week/day context there, and keep item submission tied to the selected context.

**Independent Test**: Open item add from the shell, switch the weekday context, enter an item, and confirm it is saved to the selected week.

- [ ] T008 [P] Extract a reusable week selector or header from `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` so the item add screen can switch weekdays without reintroducing the purchase-list header.
  - Depends on: T001, T003
  - Verification: the add screen has a dedicated week-switching control that is not tied to the purchase list layout.

- [ ] T009 Rework `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` into the dedicated item-registration screen that opens from the bottom add action and owns the add flow.
  - Depends on: T008
  - Verification: tapping the add entry opens the registration screen instead of a purchase-list sheet.

- [ ] T010 Update `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` so submitted items preserve the selected weekday/section context and continue to reuse candidates from the shared weekly snapshot.
  - Depends on: T008, T009, T002
  - Verification: submitted items land in the selected week with the expected context and candidate selection.

- [ ] T011 [P] Add widget tests for opening item add, switching weekdays, and saving an item into the selected week in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T008, T009, T010
  - Verification: the dedicated add flow works independently of the purchase list.

**Checkpoint**: The add screen is the only creation path and keeps the selected week/day context stable while editing.

---

## Phase 4: User Story 3 - Keep weekly context stable while navigating (Priority: P2)

**Goal**: Switch between purchase list and item add without losing the selected week or bouncing the user into a different context.

**Independent Test**: Move from purchase list to item add and back, then confirm the selected week did not change.

- [ ] T012 Keep the shared week provider and destination switching behavior stable so purchase list and item add stay on the same week across navigation in `weekly_buyer/lib/app/providers.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T003, T004, T009
  - Verification: switching between the two destinations does not reset the selected week.

- [ ] T013 Ensure the item add completion path returns users to the purchase list without changing the active week in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T009, T012
  - Verification: save-and-return lands back on the purchase list with the same week selected.

- [ ] T014 [P] Add widget tests for destination switching and week retention across purchase list and item add in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T012, T013
  - Verification: the shell preserves week state while switching destinations.

**Checkpoint**: The shared shell preserves context correctly across navigation.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Finish verification, data-layer coverage, and cleanup after the three user stories are in place.

- [ ] T015 [P] Add repository tests for category grouping, purchase persistence, undo restoration, and candidate reuse in `weekly_buyer/test/repository_test.dart`.
  - Depends on: T001, T002, T006, T010
  - Verification: the data layer matches the corrected screen flow.

- [ ] T016 Run `flutter analyze` and `flutter test`, then fix any issues in touched files.
  - Depends on: T007, T011, T014, T015
  - Verification: static analysis and tests pass for the feature changes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks all later phases.
- **Phase 2**: Depends on Phase 1 and delivers the corrected purchase list MVP.
- **Phase 3**: Depends on Phase 1 and delivers the dedicated item registration flow.
- **Phase 4**: Depends on Phase 1 and ensures navigation preserves week context across destinations.
- **Phase 5**: Depends on the story phases being complete.

### Story Dependencies

- **US1**: Can start after the shared snapshot and shell foundation are in place.
- **US2**: Depends on the shared snapshot foundation and the reusable week selector extracted for the add screen.
- **US3**: Depends on the shared shell and the corrected purchase/add destinations.

### Within Each Story

- Foundation state and domain shape before story-specific UI work.
- Repository behavior before widget wiring that depends on loaded data.
- Story-specific widget tests after the implementation pieces are in place.

### Parallel Opportunities

- T001 and T003 can proceed in parallel once the plan is accepted.
- T004 and T005 can be split across the purchase list UI once the grouped snapshot exists.
- T008 can be worked on independently from T004/T005 because it targets the add screen.
- T007, T011, and T014 can be implemented once their feature slices are complete.

## Implementation Strategy

### MVP First

1. Complete Phase 1.
2. Complete Phase 2 to make the purchase list category-based and swipe-to-complete.
3. Validate the corrected purchase flow before expanding the add screen.

### Incremental Delivery

1. Ship the purchase list correction first.
2. Add the dedicated item registration flow next.
3. Finish with navigation retention and data-layer coverage.

## Notes

- Keep the existing weekly shopping repository intact while the screen responsibilities are corrected.
- Prefer moving presentation and session state before changing data-layer behavior beyond the grouping transformation.
- Do not duplicate week-selection logic across destinations; it should remain shared.