# Tasks: 商品追加画面メモ

**Input**: Design artifacts from `specs/013-item-add-memo/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the shared memo data model and state scaffolding used by the item-add screen.

- [X] T001 Add a daily memo table and schema upgrade path in `weekly_buyer/lib/app/app_database.dart` and regenerate `weekly_buyer/lib/app/app_database.g.dart`.
- [X] T002 Create the daily memo domain model and week-level memo snapshot types in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
- [ ] T003 Create the memo draft state and shared providers in `weekly_buyer/lib/app/app_state_providers.dart` and expose any repository wiring from `weekly_buyer/lib/app/providers.dart`.
- [X] T004 Add repository access helpers for loading and saving day memos in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: The app has a memo data model, shared state, and repository hooks that the screen can use.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the repository-level memo behavior that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Add repository regression tests for memo creation and loading by selected day in `weekly_buyer/test/repository_test.dart`.
- [X] T006 Add widget regression tests for the memo entry area visibility and initial binding in `weekly_buyer/test/widget_test.dart`.

**Checkpoint**: The repository and widget test harness can exercise memo behavior for the selected day.

---

## Phase 3: User Story 1 - その日の私用メモを登録する (Priority: P1)

**Goal**: ユーザーが商品追加画面でその日の私用メモを入力し、保存できる。

**Independent Test**: 商品追加画面を開き、選択中の日にメモを入力して保存し、同じ日に戻ったときに内容が表示される。

### Tests for User Story 1

- [X] T007 [P] [US1] Add repository regression tests for saving a memo and loading it again for the same selected day in `weekly_buyer/test/repository_test.dart`.
- [X] T008 [P] [US1] Add widget regression tests for entering a memo and seeing it persist when the same day is reopened in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 1

- [X] T009 [US1] Extend `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` so the selected day can save and reload a private memo without affecting purchase-list data.
- [X] T010 [US1] Add the memo entry area to `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`.

**Checkpoint**: A memo can be entered and restored for the selected day without changing the purchase list flow.

---

## Phase 4: User Story 2 - メモを編集・削除する (Priority: P1)

**Goal**: ユーザーが保存済みの私用メモを編集したり、空にして未設定へ戻せる。

**Independent Test**: 既存メモを編集して保存し、変更後の内容が表示されること、または内容を消して空の状態に戻ることを確認できる。

### Tests for User Story 2

- [X] T011 [P] [US2] Add repository regression tests for updating and clearing an existing memo in `weekly_buyer/test/repository_test.dart`.
- [X] T012 [P] [US2] Add widget regression tests for editing and clearing the memo field in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 2

- [X] T013 [US2] Update `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` so an existing memo is replaced for the same day and blank content clears the memo.
- [X] T014 [US2] Prefill the memo editor from the current day state and allow clearing it in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`.

**Checkpoint**: A saved memo can be corrected or cleared without creating duplicate entries.

---

## Phase 5: User Story 3 - 日ごとのメモを維持して切り替える (Priority: P2)

**Goal**: ユーザーが日を切り替えても、各日のメモが混ざらず、購入リスト画面には表示されない。

**Independent Test**: ある日にメモを保存し、別の日に切り替えたあと元の日に戻って同じメモが維持され、購入リスト画面では私用メモが表示されない。

### Tests for User Story 3

- [X] T015 [P] [US3] Add repository regression tests for keeping memo values isolated by day within the active week in `weekly_buyer/test/repository_test.dart`.
- [X] T016 [P] [US3] Add widget regression tests that confirm private memo content does not appear on the purchase list screen in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 3

- [X] T017 [US3] Keep memo storage keyed by the active week and selected day in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` and `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
- [X] T018 [US3] Ensure `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` do not read or render private memo content.

**Checkpoint**: Private memo content stays day-specific and never appears in the purchase list view.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across user stories.

- [X] T019 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in `weekly_buyer/lib/app/**`, `weekly_buyer/lib/features/weekly_shopping_list/**`, and `weekly_buyer/test/**`.
- [ ] T020 Confirm the manual quickstart steps in `specs/013-item-add-memo/quickstart.md` on an emulator or device, including add, edit, clear, day switching, and purchase-list visibility checks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after Foundational; may reuse the same memo editor and repository helpers but should remain independently testable.
- **User Story 3 (P2)**: Can start after Foundational; may reuse the same storage and display state but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Repository memo persistence should be implemented before screen wiring that depends on it.
- Clear and day-switch behavior should build on the working save/load flow.

### Parallel Opportunities

- T005 and T006 can run in parallel because they touch different test files.
- T007 and T008 can run in parallel because they verify the same feature from different layers.
- T011 and T012 can run in parallel because they touch different test files.
- T015 and T016 can run in parallel because they cover separate verification concerns.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to create the schema, model, and shared state scaffolding.
2. Complete Phase 2 to add the baseline memo tests.
3. Complete Phase 3 and validate memo save/load independently.
4. **STOP and VALIDATE**: Confirm a memo can be added and restored for the selected day.
5. Deploy/demo if ready.

### Incremental Delivery

1. Build the add/save/load memo flow for User Story 1.
2. Add edit and clear behavior for User Story 2.
3. Add day-isolation and purchase-list exclusion for User Story 3.
4. Run validation after each story to keep the feature independently testable.

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
- Verify tests fail before implementing the corresponding behavior.
- Keep the feature local-only and consistent with the existing Flutter/Riverpod/Drift architecture.
