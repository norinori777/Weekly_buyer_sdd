# Tasks: 曜日別商品登録

**Input**: Design artifacts from `specs/006-weekday-item-registration/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Weekday Persistence Foundation

**Purpose**: Add weekday-specific storage and keep the existing week-wide purchase flow intact.

- [X] T001 [P] Extend the weekly shopping domain model so item entries and snapshots can carry a weekday association inside the active week in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
  - Depends on: none
  - Verification: the domain layer can describe one item set per weekday without removing the existing week scope.

- [X] T002 Update the persisted shopping item schema and migration path so each saved item stores its weekday within the week in `weekly_buyer/lib/app/app_database.dart` and the generated database layer.
  - Depends on: T001
  - Verification: the database can persist weekday-specific registrations and older rows still load safely.

- [X] T003 Update the weekly shopping repository so it writes new items against the selected weekday and can load weekday-scoped items for the add screen while keeping the purchase list's week-wide view intact in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
  - Depends on: T001, T002
  - Verification: saving an item on Monday does not make it appear when Tuesday is loaded in the add screen, while the week-wide snapshot still remains available where needed.

- [X] T004 [P] Align the item-add screen state with the shared week context and the selected weekday so the active day can be passed consistently into the repository in `weekly_buyer/lib/app/providers.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T003
  - Verification: the add screen always knows which weekday is currently active when saving or reloading.

**Checkpoint**: The data layer can store and reload weekday-specific registrations.

---

## Phase 2: User Story 1 - Register items to the selected weekday (Priority: P1)

**Goal**: Saving an item on one weekday keeps it tied to that weekday only.

**Independent Test**: Register an item on Monday, switch to Tuesday, and confirm the Monday item does not appear.

- [X] T005 Rebuild the item-add screen so it renders only the currently selected weekday's items and empty state in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T003, T004
  - Verification: the screen shows only the active weekday's registrations.

- [X] T006 [P] Keep the bottom-sheet add flow writing to the active weekday and refreshing only the active weekday view after save in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T005
  - Verification: submitting the form saves the item under the selected weekday and the same weekday reloads immediately.

- [X] T007 [P] Add widget tests for Monday/Tuesday isolation, same-week reloading, and weekday-specific empty states in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T005, T006
  - Verification: widget tests prove items stay on their selected weekday and do not leak to other days.

**Checkpoint**: Each weekday keeps its own registrations inside the same week.

---

## Phase 3: User Story 2 - Keep weekday-specific views stable while switching (Priority: P1)

**Goal**: Switching weekdays never mixes registrations from other days into the current view.

**Independent Test**: Add items on multiple weekdays and confirm each weekday shows only its own registrations when selected.

- [X] T008 Ensure weekday switching continues to update the same selected weekday state used by the add screen, including tap and swipe behavior in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T004, T005
  - Verification: changing the weekday updates the same active-day state everywhere the add screen reads it.

- [X] T009 [P] Add repository tests for weekday-specific persistence, filtering, and existing-row fallback behavior in `weekly_buyer/test/repository_test.dart`.
  - Depends on: T002, T003
  - Verification: the repository stores weekday-separated items and returns only the selected weekday's items when queried for the add screen.

**Checkpoint**: Switching weekdays stays isolated and stable.

---

## Phase 4: User Story 3 - Preserve weekly context across weekday registrations (Priority: P2)

**Goal**: Keep the same week while moving between weekdays and destination views.

**Independent Test**: Move between weekdays and return to the add screen without losing the active week context.

- [X] T010 Keep the shared shell and destination switching behavior stable so the active week remains unchanged while the weekday-specific add view changes in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart` and `weekly_buyer/lib/app/providers.dart`.
  - Depends on: T004, T005, T006
  - Verification: switching destinations does not reset the active week or the current weekday selection.

- [X] T011 [P] Add widget tests for returning to the add screen and confirming the same week and weekday remain active in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T008, T010
  - Verification: navigation does not break the shared week context or the weekday-specific view.

**Checkpoint**: The shared week context remains stable while weekday registrations stay separated.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Finish verification and fix any regressions after weekday-specific storage and filtering are in place.

- [X] T012 [P] Run `flutter analyze` and `flutter test`, then fix any issues in touched files.
  - Depends on: T007, T009, T011
  - Verification: static analysis and tests pass for the weekday-registration changes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks all later phases.
- **Phase 2**: Depends on Phase 1 and delivers weekday-specific saving and rendering.
- **Phase 3**: Depends on Phase 1 and ensures weekday switching stays isolated.
- **Phase 4**: Depends on Phase 1 and preserves the shared week context during navigation.
- **Phase 5**: Depends on the story phases being complete.

### Story Dependencies

- **US1**: Depends on the weekday-aware data model, repository writes, and weekday-scoped rendering.
- **US2**: Depends on the same weekday-scoped rendering and the selector state staying consistent.
- **US3**: Depends on the shared shell and weekday state surviving navigation.

### Within Each Story

- Data model and repository changes before UI wiring.
- UI wiring before widget tests.
- Repository tests before cross-cutting validation.

### Parallel Opportunities

- T001 and T004 can proceed in parallel once the plan is accepted.
- T005 and T008 can be split between screen rendering and selector state.
- T007 and T009 can proceed in parallel after repository behavior is defined.
- T011 can be implemented once T010 is complete.

## Implementation Strategy

### MVP First

1. Complete Phase 1.
2. Complete Phase 2 so each weekday stores and displays its own registrations.
3. Validate the Monday/Tuesday isolation before expanding navigation coverage.

### Incremental Delivery

1. Add weekday-specific persistence first.
2. Wire the add screen to the active weekday next.
3. Finish with navigation retention and regression testing.

## Notes

- Keep the existing week-wide purchase list behavior intact while adding weekday-specific add-screen filtering.
- Prefer enforcing weekday separation in the repository instead of only in the UI.
- Existing rows should remain readable after the weekday association is added.