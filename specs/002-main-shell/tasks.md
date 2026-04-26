# Tasks: Main Shell

**Input**: Design artifacts from `specs/002-main-shell/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/`

**Organization**: Tasks are grouped by user story so each destination and navigation flow can be built and tested independently.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story the task belongs to (`US1`, `US2`, `US3`)
- Include exact file paths in descriptions

---

## Phase 1: Shared Shell Foundation

**Purpose**: Introduce the shared navigation state and shell entry point that all destinations will use.

- [x] T001 Define the shared main-shell state and destination model in `weekly_buyer/lib/app/providers.dart`.
  - Depends on: none
  - Verification: the app has a single source of truth for selected destination and shared week context.

- [x] T002 Build the `MainShell` scaffold with a persistent bottom navigation area in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T001
  - Verification: the shell can host purchase list, item add, and settings as three stable destinations.

- [x] T003 Refactor the app root to launch `MainShell` instead of the current weekly page in `weekly_buyer/lib/app/weekly_buyer_app.dart`.
  - Depends on: T001, T002
  - Verification: app startup lands inside the shared shell without the template flow.

- [x] T004 [P] Add a widget test for the default destination and shell launch in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T002, T003
  - Verification: the app opens to the purchase list destination by default.

**Checkpoint**: The app boots into the new shell and exposes destination state that later stories can reuse.

---

## Phase 2: User Story 1 - Switch Between Core Destinations (Priority: P1)

**Goal**: Let users switch between purchase list, item add, and settings from one persistent control while keeping the selected week stable.

**Independent Test**: A tester can open each destination from the bottom navigation and confirm that the selected week does not change during destination switching.

- [x] T005 Extract the existing weekly shopping screen into a purchase-list destination widget in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`.
  - Depends on: T002, T003
  - Verification: the current weekly list UI still renders inside the shell.

- [x] T006 Create the item-add destination scaffold in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T002
  - Verification: the shell can switch to a dedicated item-add destination even before the full add flow is wired.

- [x] T007 Create the settings destination scaffold in `weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart`.
  - Depends on: T002
  - Verification: the shell can switch to a dedicated settings destination even before category controls are added.

- [x] T008 Wire the bottom navigation to switch between purchase list, item add, and settings while preserving the shared week context in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T001, T005, T006, T007
  - Verification: switching destinations does not reset the selected week.

- [x] T009 [P] Add widget tests for destination switching and week retention in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T008
  - Verification: the test suite proves the three top-level destinations switch correctly and keep the same week.

**Checkpoint**: Destination switching works end-to-end and the week stays stable across the shell.

---

## Phase 3: User Story 2 - Add Items Without Losing Context (Priority: P1)

**Goal**: Let users add items from the purchase list quickly, keep draft add state during a session, and return to the purchase list after completion by default.

**Independent Test**: A tester can start from the purchase list, open item entry, enter an item, and return to the purchase list without losing the active week or the quick-add path.

- [x] T010 Add a session-scoped draft add state provider in `weekly_buyer/lib/app/providers.dart` or `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_state.dart`.
  - Depends on: T001
  - Verification: in-progress item entry can survive brief navigation away and back within the same session.

- [x] T011 Refactor the current add-sheet fields into reusable item-entry UI shared by the purchase-list and item-add destinations in `weekly_buyer/lib/features/weekly_shopping_list/presentation/`.
  - Depends on: T005, T006, T010
  - Verification: the same input experience can be launched from the list or the dedicated add destination.

- [x] T012 Preserve the purchase-list fast add action and make add completion return to the purchase list by default in `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T005, T006, T011
  - Verification: a user can add an item from the purchase list and land back on the purchase list after saving.

- [x] T013 [P] Add widget tests for quick add, draft-state retention, and default return behavior in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T010, T011, T012
  - Verification: tests cover add from purchase list, brief navigation away and back, and the default return path.

**Checkpoint**: Item entry can be started quickly, preserved during the session, and returned from in the expected flow.

---

## Phase 4: User Story 3 - Reach Settings Without Disrupting Shopping Flow (Priority: P2)

**Goal**: Let users open settings from the same shell, adjust shopping-related configuration, and return to the previously active shopping destination.

**Independent Test**: A tester can open settings from either shopping destination, navigate back, and confirm the previous shopping destination is restored.

- [x] T014 Implement the settings destination shell with category-order and item-management entry points in `weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart`.
  - Depends on: T007
  - Verification: the settings destination shows the intended shopping configuration surface.

- [x] T015 Preserve and restore the previously active shopping destination when leaving settings in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T008, T014
  - Verification: leaving settings returns the user to the same shopping destination they were using before.

- [x] T016 [P] Add widget tests for settings switching and return-to-previous-destination behavior in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T014, T015
  - Verification: the test suite confirms settings does not break the shopping flow.

**Checkpoint**: Settings behaves like a first-class shell destination and does not interrupt the shopping context.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Confirm the shell, add flow, and settings flow work together and keep the codebase healthy.

- [x] T017 Review and tighten the shared navigation providers and destination widgets for consistency in `weekly_buyer/lib/app/providers.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/`.
  - Depends on: T008, T012, T015
  - Verification: shared state is not duplicated across destinations.

- [x] T018 Run `flutter analyze` and `flutter test`, then fix any issues in the touched files.
  - Depends on: T004, T009, T013, T016, T017
  - Verification: analysis and tests pass for the shell and destination flow changes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks all later phases.
- **Phase 2**: Depends on Phase 1 and delivers the shell-switching MVP.
- **Phase 3**: Depends on Phase 2 and adds the add flow that uses the shared shell.
- **Phase 4**: Depends on Phase 2 and adds settings behavior that restores the previous destination.
- **Phase 5**: Depends on all desired story work being complete.

### Story Dependencies

- **US1**: Can start after the shared shell foundation is in place.
- **US2**: Depends on the purchase-list and item-add destinations from US1, plus shared draft-state providers.
- **US3**: Depends on the shell and settings scaffold from US1.

### Parallel Opportunities

- T004, T009, T013, and T016 can run in parallel with their corresponding implementation tasks once the prerequisite code exists.
- T006 and T007 can be developed in parallel after the shell scaffold exists.
- T011 and T012 can proceed together once the shared item-entry UI is extracted.

## Implementation Strategy

### MVP First

1. Complete Phase 1 and Phase 2.
2. Validate that the shell can switch between purchase list, item add, and settings while keeping the week stable.
3. Stop and demo the shell if the core switching flow is sound.

### Incremental Delivery

1. Ship the shell and destination switching first.
2. Add the quick add and draft-state behavior next.
3. Finish with settings persistence and return behavior.

## Notes

- Keep the existing weekly shopping repository intact while the shell is introduced.
- Prefer moving presentation and session state before changing data-layer behavior.
- Do not duplicate week-selection logic across destinations; it should remain shared.