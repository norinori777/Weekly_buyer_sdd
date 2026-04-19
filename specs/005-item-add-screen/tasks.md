# Tasks: 商品登録画面

**Input**: Design artifacts from `specs/005-item-add-screen/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Shared Weekday Selection Foundation

**Purpose**: Make the item-add screen able to switch weekdays by both tapping and swiping while keeping the shared week context intact.

- [X] T001 [P] Extend the weekday selector widget in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart` to handle left/right swipe gestures in addition to tap selection.
  - Depends on: none
  - Verification: the selector can move to the previous or next weekday by swiping and still highlight the tapped day.

- [X] T002 [P] Align the item-add screen state with the shared week context and selected weekday in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` and `weekly_buyer/lib/app/providers.dart`.
  - Depends on: T001
  - Verification: switching weekdays updates the same shared state used by the purchase list screen.

- [X] T003 [P] Keep the reusable item-entry draft state synchronized with the selected weekday and section in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` and `weekly_buyer/lib/app/providers.dart`.
  - Depends on: T002
  - Verification: the form remembers the current draft values while the user switches weekdays or reopens the add flow.

**Checkpoint**: The add screen can move across weekdays and preserve the active week context.

---

## Phase 2: User Story 1 - Switch the active weekday context (Priority: P1)

**Goal**: Let users switch the item registration view across Monday through Sunday and Other by tap or swipe.

**Independent Test**: Open the item-add screen, switch weekdays by tapping and swiping, and verify the selected weekday changes correctly.

- [X] T004 Rebuild the item-add screen shell in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` so the weekday selector sits above the section views and reflects the currently selected day.
  - Depends on: T001, T002
  - Verification: the screen shows a clear weekday selector and the visible registration content follows the selected day.

- [X] T005 [P] Add the weekday-tab state refresh logic so changing the selected day updates the displayed registration content without leaving the screen in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T004
  - Verification: choosing a different weekday immediately changes the visible registration content.

- [X] T006 [P] Add widget tests for weekday tab selection and left/right swipe navigation in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T004, T005
  - Verification: tests prove the weekday selector works by tap and swipe and keeps the selected day highlighted.

**Checkpoint**: Users can move between weekdays in the add screen without breaking the active week context.

---

## Phase 3: User Story 2 - Add items through a bottom sheet (Priority: P1)

**Goal**: Open a bottom-sheet item form from the add action and let users enter name, quantity, and time-of-day section.

**Independent Test**: Tap the add action, see a slide-up form, enter item data, and submit it successfully.

- [X] T007 Rework the add action in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` to open a bottom-sheet form instead of keeping the full form inline.
  - Depends on: T004, T005
  - Verification: tapping the add action presents a slide-up input sheet.

- [X] T008 Update `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` so the form works cleanly as bottom-sheet content with item name, quantity, and section selection.
  - Depends on: T007
  - Verification: the form can be entered and submitted from inside the bottom sheet.

- [X] T009 Wire the submit path in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` to save the new item to the selected week and clear or preserve draft state as defined by the session rules.
  - Depends on: T007, T008, T003
  - Verification: submitting the form saves the item and keeps the add flow usable for the next entry.

- [X] T010 [P] Add widget tests for opening the bottom sheet, entering item data, and submitting from the add action in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T007, T008, T009
  - Verification: tests cover the slide-up form and a successful submit path.

**Checkpoint**: The add action opens a bottom-sheet form and can submit a new item.

---

## Phase 4: User Story 3 - Show newly added items in the selected section (Priority: P2)

**Goal**: After save, show the new item in the correct morning, afternoon, or evening section for the currently selected weekday.

**Independent Test**: Add an item to a section and confirm it appears immediately in the matching section on the screen.

- [X] T011 Update the item-add screen refresh behavior in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` so saved items are reloaded into the visible morning, afternoon, or evening section.
  - Depends on: T009
  - Verification: saving a new item updates the section list without requiring a full app restart.

- [X] T012 [P] Add repository/state tests for week reload and section placement after add in `weekly_buyer/test/repository_test.dart`.
  - Depends on: T009, T011
  - Verification: the repository returns the saved item in the expected section for the selected week.

- [X] T013 [P] Add widget tests for section refresh after save in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T011, T012
  - Verification: the screen shows the newly added item in the correct section after submission.

**Checkpoint**: Newly registered items appear in the correct section immediately after save.

---

## Phase 5: Polish & Cross-Cutting Validation

**Purpose**: Finish integration checks and ensure the add screen behaves consistently with the shared shell and data layer.

- [X] T014 Verify the shared shell still routes to item add and preserves the active week while switching destinations in `weekly_buyer/lib/features/weekly_shopping_list/presentation/main_shell.dart`.
  - Depends on: T002, T004, T007
  - Verification: destination switching does not reset the selected week.

- [X] T015 Run `flutter analyze` and `flutter test`, then fix any issues in touched files.
  - Depends on: T006, T010, T013, T014
  - Verification: static analysis and tests pass for the feature changes.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks all later phases.
- **Phase 2**: Depends on Phase 1 and delivers the weekday switching foundation.
- **Phase 3**: Depends on Phase 1 and delivers the bottom-sheet add flow.
- **Phase 4**: Depends on Phase 1 and ensures saved items appear in the correct section.
- **Phase 5**: Depends on the story phases being complete.

### Story Dependencies

- **US1**: Can start after the weekday selector and shared state foundation are in place.
- **US2**: Depends on the selector foundation and the reusable form being ready for bottom-sheet use.
- **US3**: Depends on the save path from US2 and the repository refresh behavior.

### Within Each Story

- Shared state and UI foundation before story-specific interaction logic.
- Screen behavior before widget tests.
- Repository refresh behavior before section-display verification.

### Parallel Opportunities

- T001 and T003 can proceed in parallel once the task list is accepted.
- T005 and T006 can be split between UI behavior and test coverage.
- T008 and T009 can proceed together once the bottom-sheet entry point is defined.
- T012 and T013 can be worked on in parallel after the save behavior is stable.

## Implementation Strategy

### MVP First

1. Complete Phase 1 and Phase 2.
2. Validate that weekday switching works by tap and swipe.
3. Stop and demo the add screen if the selector behavior is correct.

### Incremental Delivery

1. Ship weekday switching first.
2. Add the bottom-sheet entry flow next.
3. Finish by refreshing the section views after save.

## Notes

- Keep the existing shared week context intact while changing only the item-add presentation layer.
- Prefer reusing the current item-entry form inside the bottom sheet instead of creating a duplicate form.
- Do not add new persisted state for weekday tabs; keep it in session state and shared providers.