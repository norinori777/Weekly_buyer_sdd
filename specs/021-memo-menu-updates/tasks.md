# Tasks: 商品追加画面のメモ自動保存と料理メニュー削除

**Input**: Design artifacts from `specs/021-memo-menu-updates/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Locate the presentation points where memo auto-save and meal-menu deletion will be wired.

- [ ] T001 Identify the private memo and meal-menu entry UI anchors in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) and [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so the existing save/delete APIs can be reused without changing the data model.

**Checkpoint**: The implementation scope is limited to the existing item-add presentation layer and repository calls.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Lock in the current memo and meal-menu behavior before changing the visible controls.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 [P] Add widget regression coverage in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) for the existing item add screen so the current memo and meal-menu flows remain stable before controls are removed or added.

**Checkpoint**: The current screen behavior is covered before the UI is refactored.

---

## Phase 3: User Story 1 - 私用メモをその場で保存する (Priority: P1) 🎯 MVP

**Goal**: ユーザーが私用メモを入力した内容を、その場で自動保存できる。

**Independent Test**: 商品追加画面で私用メモを入力し、クリア/保存ボタンを使わなくても内容が保持され、画面を開き直したときに同じメモを確認できる。

### Tests for User Story 1

- [ ] T003 [P] [US1] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the private memo saves as the user types and that the clear/save buttons are no longer shown.

### Implementation for User Story 1

- [ ] T004 [US1] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the private memo section auto-saves on input changes and removes the separate clear/save buttons from the UI.
- [ ] T005 [US1] Wire the auto-save callback from [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) to persist the private memo as the user edits it and refresh the selected-day snapshot.

**Checkpoint**: The private memo is saved without explicit memo action buttons.

---

## Phase 4: User Story 2 - 追加した料理メニューを削除する (Priority: P1)

**Goal**: ユーザーが追加した料理メニューを、各行の右側の✖ボタンから個別に削除できる。

**Independent Test**: 商品追加画面で料理メニューを追加し、各メニューの右側の✖ボタンを押して、その 1 件だけが削除されることを確認できる。

### Tests for User Story 2

- [ ] T006 [P] [US2] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify each saved meal menu entry shows a delete button and that deleting one entry leaves the other entries intact.

### Implementation for User Story 2

- [ ] T007 [US2] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so each rendered meal menu entry includes a right-aligned ✖ delete control and deletion refreshes the section list immediately.
- [ ] T008 [US2] Connect the meal-menu delete control to [weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart](weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart) so only the selected meal menu entry is removed and the remaining entries stay visible.

**Checkpoint**: Meal menu entries can be deleted individually from the add screen.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the updated screen behavior end to end and catch regressions.

- [ ] T009 Run `flutter analyze` and `flutter test` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart), [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart), [weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart](weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart), and [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart).
- [ ] T010 Verify the manual quickstart in [specs/021-memo-menu-updates/quickstart.md](specs/021-memo-menu-updates/quickstart.md) on an emulator or device, including auto-saving memo edits, displaying delete buttons, and removing a single meal menu entry.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after Foundational; may reuse the same add-screen snapshot refresh path but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The private memo auto-save should be validated before removing the memo action buttons.
- The meal-menu delete control should be validated before tightening the section layout.

### Parallel Opportunities

- T002 can run in parallel with T001 because it only adds regression coverage while the implementation scope is being confirmed.
- T004 and T005 can be split across two developers after T001 because they touch different presentation files.
- T006 can run after T002 and before T007/T008 because it focuses on meal-menu deletion behavior in the same widget file.
- T009 and T010 are final validation steps and should be done after the UI changes are stable.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm private memo edits are saved without action buttons.
5. Deploy/demo if ready.

### Incremental Delivery

1. Convert private memo to auto-save and remove its action buttons.
2. Add the meal-menu delete control and verify single-entry deletion.
3. Run validation after each story so the add screen remains usable throughout.

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together.
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
3. Stories complete and integrate independently.

---

## Notes

- `[P]` tasks should modify different files and avoid direct dependency on incomplete work.
- `[Story]` label maps task to a specific user story for traceability.
- Each user story should be independently completable and testable.
- Keep the feature local to the existing item add screen and avoid data-layer changes beyond reusing the existing repository APIs.
