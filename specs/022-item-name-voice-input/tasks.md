# Tasks: 商品名音声入力

**Input**: Design artifacts from `specs/022-item-name-voice-input/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Locate the item-add form entry points and the current test coverage that the voice-input flow will extend.

- [X] T001 Inspect the current product-name and add-sheet anchors in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) and [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) so the voice-input trigger can be added without changing the save flow.

**Checkpoint**: The implementation scope is limited to the existing item-add presentation layer and its current form state.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Protect the current item-add behavior before introducing a new input path.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 [P] Add regression coverage in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) for the current item-add form so the existing manual product-name entry and add-sheet submission remain stable before the voice-input controls are introduced.

**Checkpoint**: The current item-add flow is covered before the UI is extended.

---

## Phase 3: User Story 1 - 商品名を音声で入力する (Priority: P1) 🎯 MVP

**Goal**: ユーザーが商品名欄を音声で入力し、その結果を保存前に確認・修正できる。

**Independent Test**: 商品追加画面で商品名欄の音声入力を開始し、話した内容が商品名欄に反映され、必要なら手で修正できる。

### Tests for User Story 1

- [X] T003 [P] [US1] Add widget tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify the item-add form exposes a product-name voice-input trigger and that recognized text is placed back into the editable product-name field.
- [X] T004 [P] [US1] Add widget tests in [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) that verify canceling or failing voice input keeps the existing product-name text unchanged and still allows manual editing.

### Implementation for User Story 1

- [X] T005 [US1] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the product-name field can start a voice-input flow and accept recognized text back as normal editable text.
- [X] T006 [US1] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) if needed so the add-sheet wiring passes the voice-input result back into the current draft without changing quantity, section, or save behavior.

**Checkpoint**: The product-name field accepts voice input and remains editable before save.

---

## Phase 4: User Story 2 - 音声入力が使えないときも入力を続ける (Priority: P2)

**Goal**: ユーザーが音声入力を使えない状況でも、商品名入力を手入力で続けられる。

**Independent Test**: 音声入力が利用できない状態でも、商品名欄に手入力で商品名を入れられる。

### Tests for User Story 2

- [X] T007 [P] [US2] Extend [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart) with a regression case proving that the item-add form still works with manual product-name entry when voice input is unavailable.

### Implementation for User Story 2

- [X] T008 [US2] Update [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart) so the manual keyboard input path remains the primary fallback when voice input is unavailable or canceled.
- [X] T009 [US2] Keep the add-sheet submission path in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart) unchanged so voice-input availability does not affect saving an item.

**Checkpoint**: The item-add flow still completes through manual typing when voice input cannot be used.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the updated screen behavior end to end and catch regressions.

- [X] T010 Run `flutter analyze` and `flutter test` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart), [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart), and [weekly_buyer/test/widget_test.dart](weekly_buyer/test/widget_test.dart).
- [ ] T011 Verify the manual quickstart in [specs/022-item-name-voice-input/quickstart.md](specs/022-item-name-voice-input/quickstart.md) on an emulator or device, including starting voice input from the product-name field, confirming the recognized text, and falling back to manual typing when needed.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; establishes the core voice-input behavior.
- **User Story 2 (P2)**: Can start after Foundational and should preserve the manual fallback path regardless of voice-input support.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The voice-input trigger and text handoff should be validated before tightening any supporting wiring.
- The fallback path should remain usable even if the voice-input trigger is unavailable.

### Parallel Opportunities

- T002 can run in parallel with T001 because it only adds regression coverage while the implementation scope is being confirmed.
- T003 and T004 can run in parallel because they cover separate behaviors in the same widget file.
- T005 and T006 can be split once the item-entry flow is clear because they touch different presentation files.
- T007 can run after T002 and before T008/T009 because it focuses on the fallback path in the same widget file.
- T010 and T011 are final validation steps and should be done after the UI changes are stable.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm product-name voice input works and remains editable before save.
5. Deploy/demo if ready.

### Incremental Delivery

1. Add the voice-input trigger and text handoff for the product-name field.
2. Keep the manual typing fallback stable and test it explicitly.
3. Run validation after each story so the item-add flow remains usable throughout.

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
- Keep the feature local to the existing item add screen and avoid data-layer changes beyond reusing the current repository and form state.