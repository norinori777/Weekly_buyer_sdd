# Tasks: 商品追加画面の削除機能

**Input**: Design artifacts from `specs/007-item-add-delete/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Data and Repository Foundation

**Purpose**: Add the deletion path for registered items without changing the reusable item catalog or weekday context.

- [X] T001 [P] Extend the weekly shopping domain so the add screen can describe a deleteable registered item row and the snapshot can still represent the selected weekday in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
  - Depends on: none
  - Verification: the domain layer can express the row target for deletion without changing the existing week/weekday model.

- [X] T002 Add a repository delete method that removes one weekly list item by id and leaves the item master catalog untouched in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
  - Depends on: T001
  - Verification: deleting a row removes only that weekly shopping item and does not affect reusable candidates.

- [X] T003 [P] Align the item-add snapshot refresh path so deleting a row can invalidate and reload the currently selected weekday in `weekly_buyer/lib/app/providers.dart` and `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
  - Depends on: T002
  - Verification: the active weekday snapshot can be refreshed immediately after delete.

**Checkpoint**: The data layer can delete one selected shopping row and reload the active weekday.

---

## Phase 2: User Story 1 - Remove an added item from the add screen (Priority: P1)

**Goal**: Add a per-row delete action so tapping it removes the selected item from the current weekday list.

**Independent Test**: Open the item-add screen, tap the delete action on one row, and confirm that only that row disappears.

- [X] T004 Rebuild the item-add screen row layout so each registered item shows a right-end delete control and the row can call into the repository delete path in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T002, T003
  - Verification: tapping the row delete control removes the selected item from the visible list.

- [X] T005 [P] Preserve the current weekday selection and trigger a snapshot refresh after deletion so the active weekday stays visible in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T004
  - Verification: deleting an item keeps the same weekday selected and updates the list immediately.

- [X] T006 [P] Add widget tests for deleting one registered item, preserving the remaining rows, and keeping the active weekday unchanged in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T004, T005
  - Verification: widget tests prove one row can be removed without disturbing the rest of the list.

**Checkpoint**: The add screen can remove a single row and immediately refresh the current weekday view.

---

## Phase 3: User Story 2 - See a clear delete affordance for each item (Priority: P1)

**Goal**: Make the delete action obvious and recognizable on each registered item row.

**Independent Test**: Open the item-add screen and confirm that each visible item row has a recognizable delete icon on the right edge.

- [X] T007 [P] Update the row presentation so the delete control reads as a removal action rather than a navigation affordance in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T004
  - Verification: each row shows a clear, recognizable delete icon treatment at the right edge.

- [X] T008 [P] Hide delete controls when there are no registered items and keep the empty state readable after the last row is removed in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T005, T007
  - Verification: empty weeks do not show delete affordances and the empty state is shown after the final deletion.

- [X] T009 Add widget tests for the delete affordance, the no-items case, and the empty state after the last deletion in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T007, T008
  - Verification: the UI clearly exposes deletion and hides it when there is nothing to delete.

**Checkpoint**: The delete action is visually clear and disappears when no rows remain.

---

## Phase 4: User Story 3 - Keep the active weekday context intact after deletion (Priority: P2)

**Goal**: Ensure deleting a row on one weekday does not affect another weekday's registrations.

**Independent Test**: Delete an item on Monday, switch to Tuesday, and confirm Tuesday's rows remain unchanged.

- [X] T010 [P] Keep the delete path scoped to the currently selected weekday by using the row id from the active weekday snapshot in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T002, T005
  - Verification: the selected weekday is the only context affected by deletion.

- [X] T011 [P] Add repository tests for deleting one weekday's row, preserving other weekday rows, and leaving the reusable item catalog unchanged in `weekly_buyer/test/repository_test.dart`.
  - Depends on: T002, T010
  - Verification: the repository removes only the targeted weekly row and keeps other weekday registrations intact.

**Checkpoint**: Deletion stays limited to the active weekday and does not spill into other days.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Finish verification, regression coverage, and cleanup after the delete flow is in place.

- [X] T012 [P] Run `flutter analyze` and `flutter test`, then fix any issues in touched files.
  - Depends on: T006, T009, T011
  - Verification: static analysis and tests pass for the delete feature changes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks all later phases.
- **Phase 2**: Depends on Phase 1 and delivers the core delete interaction.
- **Phase 3**: Depends on Phase 1 and sharpens the delete affordance and empty-state behavior.
- **Phase 4**: Depends on Phase 1 and validates weekday isolation.
- **Phase 5**: Depends on the story phases being complete.

### Story Dependencies

- **US1**: Depends on the repository delete method and the add screen row action.
- **US2**: Depends on the delete row UI being present.
- **US3**: Depends on the delete path remaining scoped to the active weekday and on repository coverage.

### Within Each Story

- Data/repository work before UI wiring.
- UI wiring before widget tests.
- Repository coverage before cross-cutting validation.

### Parallel Opportunities

- T001 and T003 can proceed in parallel once the plan is accepted.
- T005 and T007 can be split between behavior wiring and row affordance styling.
- T006 and T009 can proceed in parallel after the row behavior is stable.
- T011 can be worked on once the repository delete path is locked in.

## Implementation Strategy

### MVP First

1. Complete Phase 1.
2. Complete Phase 2 so one row can be deleted from the add screen.
3. Validate the delete behavior before polishing the visual affordance.

### Incremental Delivery

1. Add repository delete support first.
2. Wire the row-level delete action next.
3. Finish with affordance polish, empty-state handling, and regression tests.

## Notes

- Keep the reusable item catalog intact while removing only the selected weekly registration row.
- Prefer deleting by persisted row id rather than by item name to avoid duplicate-row ambiguity.
- Do not change the weekday selector or add-sheet flow beyond what is needed to support row deletion.
