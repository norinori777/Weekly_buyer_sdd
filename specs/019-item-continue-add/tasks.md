# Tasks: 商品入力フォームの続けて追加

**Input**: Design artifacts from `specs/019-item-continue-add/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the shared submission contract needed to support both the continue-add and normal-close paths.

- [ ] T001 Define the item-add submit action contract in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) and [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so the form can distinguish a normal save from a continue-add save.

**Checkpoint**: The form and destination share a clear contract for both submission modes.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Lock in the current single-save flow before changing the form layout and continue-add behavior.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 [P] Add baseline widget regression coverage for the existing single-save bottom-sheet flow in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) so the current close-after-save behavior is protected.

**Checkpoint**: The current item-add behavior is covered before the new action is introduced.

---

## Phase 3: User Story 1 - 連続で商品を登録する (Priority: P1) 🎯 MVP

**Goal**: ユーザーが 1 件登録したあともフォームを閉じず、同じ画面で次の商品を続けて登録できる。

**Independent Test**: 商品名と数量を入力して「続けて追加」を押し、商品が保存されてフォームが開いたまま次の入力に戻ることを確認できる。

### Tests for User Story 1

- [ ] T003 [US1] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify repeated continue-add saves keep the form open and clear the name and quantity inputs after each save.

### Implementation for User Story 1

- [ ] T004 [P] [US1] Implement the continue-add button and save-and-reset behavior in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart).
- [ ] T005 [P] [US1] Wire the continue-add save path into [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so each successful continue-add persists the item and refreshes the snapshot without closing the sheet.

**Checkpoint**: The form can save multiple items in a row without closing.

---

## Phase 4: User Story 2 - 1件だけ登録して閉じる (Priority: P1)

**Goal**: ユーザーが通常の登録ボタンを使ったときは、これまでどおり 1 件保存してフォームを閉じられる。

**Independent Test**: 1 件入力して通常の登録を押し、商品が保存されてフォームが閉じることを確認できる。

### Tests for User Story 2

- [ ] T006 [US2] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the existing register action still closes the form after one successful save.

### Implementation for User Story 2

- [ ] T007 [US2] Preserve the normal register button path in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) and [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so the existing close-after-save behavior continues to reset the draft and dismiss the sheet.

**Checkpoint**: The existing single-save flow still works exactly as before.

---

## Phase 5: User Story 3 - 入力しやすい配置で続けて追加する (Priority: P2)

**Goal**: ユーザーが商品名と数量を入力しながら、同じ入力エリア内で「続けて追加」ボタンを見つけて押せる。

**Independent Test**: 商品追加フォームを開き、商品名・数量の入力欄と「続けて追加」ボタンが同時に見えて操作しやすいことを確認できる。

### Tests for User Story 3

- [ ] T008 [US3] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the continue-add button is visible beside the item name and quantity controls in the add form.

### Implementation for User Story 3

- [ ] T009 [US3] Rework the item-name and quantity row layout in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the continue-add button fits in the same input area with narrower text boxes.

**Checkpoint**: The button is visible near the inputs and the layout supports the new action cleanly.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across the updated add flow.

- [ ] T010 Run `flutter analyze` and `flutter test` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart), [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart), and [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart).
- [ ] T011 Verify the manual quickstart in [specs/019-item-continue-add/quickstart.md](specs/019-item-continue-add/quickstart.md) on an emulator or device, including repeated continue-add, normal save, and button placement.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after Foundational; should keep the existing close-after-save behavior independent of the new continue-add path.
- **User Story 3 (P2)**: Can start after Foundational; depends only on the form layout used by the same screen.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The continue-add save path should be validated before tightening the layout around it.
- The normal save path must remain intact while the new button is introduced.

### Parallel Opportunities

- T002 can run in parallel with T001 because it protects the current single-save behavior in the test file while the form contract is being introduced.
- T004 and T005 can be split across two developers after T001 because they touch different presentation files and share only the submit contract.
- T003, T006, and T008 are separate verification slices in the same widget test file and should be scheduled sequentially to avoid merge conflicts.
- T010 and T011 are final validation steps after the code is stable; T011 can be used as the manual confirmation step on a device or emulator.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm repeated continue-add saves keep the sheet open and clear the fields.
5. Deploy/demo if ready.

### Incremental Delivery

1. Add the continue-add save-and-reset path.
2. Confirm the existing single-save close behavior still works.
3. Tighten the layout so the button sits within the input area.
4. Run validation after each story so the screen remains usable throughout.

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together.
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently.

---

## Notes

- `[P]` tasks should modify different files and avoid direct dependency on incomplete work.
- `[Story]` label maps task to a specific user story for traceability.
- Each user story should be independently completable and testable.
- Keep the feature local to the existing item add screen and avoid data-layer changes.
