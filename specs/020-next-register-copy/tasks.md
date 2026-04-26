# Tasks: 「次も登録」ボタンと補足文の改善

**Input**: Design artifacts from `specs/020-next-register-copy/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the shared copy targets used by the item add form.

- [ ] T001 Identify the continue-add label and helper-text insertion points in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the button copy and supporting text can be updated without touching persistence or domain code.

**Checkpoint**: The copy update scope is limited to the item add form presentation layer.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Lock in the current add flow before changing the visible wording.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T002 [P] Add widget regression coverage in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) for the existing item add flow so the current continue-add behavior remains stable before the label changes.

**Checkpoint**: The existing item add flow is covered before the copy refresh is introduced.

---

## Phase 3: User Story 1 - 連続登録の意図をすぐ理解する (Priority: P1) 🎯 MVP

**Goal**: ユーザーが連続入力用の操作を見たときに、そのボタンが保存して次の入力に進むものだとすぐ理解できる。

**Independent Test**: 商品追加フォームを開いて「次も登録」ボタンと補足文を確認し、保存後に次の入力へ進む操作だと判断できることを確認する。

### Tests for User Story 1

- [ ] T003 [P] [US1] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the continue-add button is shown as "次も登録" and that the helper text "保存して続けて入力できます" appears beneath it.

### Implementation for User Story 1

- [ ] T004 [US1] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the continue-add button label reads "次も登録" and the helper text is displayed directly beneath it in a visually secondary style.

**Checkpoint**: The continue-add action is clearly labeled and explained in the add form.

---

## Phase 4: User Story 2 - 通常の登録と区別して使う (Priority: P2)

**Goal**: ユーザーが通常の登録と連続登録を見た目で区別し、迷わず選べる。

**Independent Test**: 商品追加フォームを開き、通常の登録ボタンと「次も登録」ボタンの役割の違いが見分けられることを確認する。

### Tests for User Story 2

- [ ] T005 [P] [US2] Add widget regression tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the normal register button remains available and visually distinct from the continue-add copy.

### Implementation for User Story 2

- [ ] T006 [US2] Keep the normal register button path and the new helper text layout aligned in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the two actions remain easy to distinguish.

**Checkpoint**: The copy update does not blur the difference between single-save and continue-save actions.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the wording update end to end and catch layout regressions.

- [ ] T007 Run `flutter analyze` and `flutter test` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) and [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart).
- [ ] T008 Verify the manual quickstart in [specs/020-next-register-copy/quickstart.md](specs/020-next-register-copy/quickstart.md) on an emulator or device, including the updated label, helper text, and the unchanged behavior of the continue-add flow.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P2)**: Can start after Foundational; should preserve the normal register path while the new copy is introduced.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The button label should be updated before refining the surrounding visual hierarchy.
- The helper text should remain subordinate to the button and not compete with the primary action.

### Parallel Opportunities

- T002 and T001 can run in parallel because they touch different files and the test can be drafted while the implementation scope is being pinned down.
- T003 and T005 can run in parallel because they are separate widget-test slices in the same file, but they should be merged carefully to avoid overlap.
- T007 and T008 are final validation steps and should be done after the UI text update is stable.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm the label and helper text communicate the continue-add behavior clearly.
5. Deploy/demo if ready.

### Incremental Delivery

1. Update the continue-add label and add the helper text.
2. Confirm the normal register action still reads as a separate choice.
3. Run validation to make sure the wording fits the existing layout.

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
- Keep the feature local to the existing item add screen and avoid data-layer changes.
