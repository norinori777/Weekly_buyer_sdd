# Tasks: 商品登録画面の料理メニュー入力

**Input**: Design artifacts from `specs/014-item-add-menu/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the shared meal-menu data model and provider scaffolding used by the item-registration screen.

- [X] T001 Add daily meal menu and meal menu entry tables plus schema upgrade path in `weekly_buyer/lib/app/app_database.dart` and regenerate `weekly_buyer/lib/app/app_database.g.dart`.
- [X] T002 Create the meal menu domain entities, section types, and week/day snapshot types in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
- [X] T003 Add repository helpers for loading, saving, deleting, and listing meal menu entries in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
- [X] T004 Create shared meal-menu draft state and providers in `weekly_buyer/lib/app/app_state_providers.dart` and expose repository wiring from `weekly_buyer/lib/app/providers.dart`.

**Checkpoint**: The app has the meal-menu schema, domain types, repository hooks, and shared state needed by the screen.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the repository and widget regression coverage that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 Add repository regression tests for creating and loading meal-menu entries by day and meal section in `weekly_buyer/test/repository_test.dart`.
- [X] T006 Add widget regression tests for section add-button visibility, slide-up form opening, and empty-section hiding in `weekly_buyer/test/widget_test.dart`.

**Checkpoint**: The repository and widget harness can exercise the baseline meal-menu behavior for a selected day.

---

## Phase 3: User Story 1 - セクションごとにメニューを追加する (Priority: P1)

**Goal**: ユーザーが商品登録画面の朝・昼・夜の各セクション右上から、下からスライドアップする入力フォームを開いて料理メニューを追加できる。

**Independent Test**: 商品登録画面を開き、朝・昼・夜の各セクション右上の追加ボタンから入力フォームを開いてメニューを登録し、保存後に同じセクションへ表示される。

### Tests for User Story 1

- [X] T007 [P] [US1] Add repository regression tests for saving multiple meal-menu entries in the same section for the same day in `weekly_buyer/test/repository_test.dart`.
- [X] T008 [P] [US1] Add widget regression tests for opening the slide-up form from each section and seeing saved menus appear under the matching section heading in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 1

- [X] T009 [US1] Add the meal-menu add buttons at the upper right of the morning, lunch, and dinner sections in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
- [X] T010 [US1] Add the slide-up meal-menu input form and its cancel/register actions in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`.
- [X] T011 [US1] Extend `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` so the selected day can save and reload multiple meal-menu entries without affecting purchase-list data.

**Checkpoint**: Meal menus can be entered, saved, and restored for the selected day without changing the purchase flow.

---

## Phase 4: User Story 2 - 入力を取り消して閉じる (Priority: P1)

**Goal**: ユーザーが入力フォームのキャンセルボタンで編集を取り消して閉じられる。

**Independent Test**: 入力フォームを開き、メニューを入力した状態でもキャンセルボタンを押してフォームが閉じ、保存されないことを確認できる。

### Tests for User Story 2

- [X] T012 [P] [US2] Add repository regression tests for canceling an add flow without persisting data in `weekly_buyer/test/repository_test.dart`.
- [X] T013 [P] [US2] Add widget regression tests for the cancel button closing the slide-up form without saving in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 2

- [X] T014 [US2] Wire the cancel action so it closes the slide-up input form without changing stored meal-menu data in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`.
- [X] T015 [US2] Ensure the section-level inline text boxes, clear buttons, and save buttons are removed from `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
- [X] T016 [US2] Keep the add-flow state local to the selected section so canceling does not create or modify any meal-menu entry in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: Users can open the add form and back out without saving anything.

---

## Phase 5: User Story 3 - 日ごとのメニューを維持して切り替える (Priority: P2)

**Goal**: ユーザーが日や週を切り替えても、その日の料理メニューが混ざらず、購入リスト画面にも表示されない。

**Independent Test**: ある日に料理メニューを保存し、別の日に切り替えたあと元の日に戻って同じ内容が維持されること、購入リスト画面に料理メニューが表示されないことを確認できる。

### Tests for User Story 3

- [X] T017 [P] [US3] Add repository regression tests for day isolation and active-week separation in `weekly_buyer/test/repository_test.dart`.
- [X] T018 [P] [US3] Add widget regression tests that confirm meal menus are hidden from `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 3

- [X] T019 [US3] Keep meal-menu storage keyed by the active week and selected day in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
- [X] T020 [US3] Ensure `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` do not read or render meal-menu content.
- [X] T021 [US3] Invalidate and reload the item registration snapshot when the selected day changes in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.

**Checkpoint**: Meal-menu content stays day-specific and never appears in the purchase list view.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across user stories.

- [X] T022 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in `weekly_buyer/lib/app/**`, `weekly_buyer/lib/features/weekly_shopping_list/**`, and `weekly_buyer/test/**`.
- [ ] T023 Confirm the manual quickstart steps in `specs/014-item-add-menu/quickstart.md` on an emulator or device, including add, candidate selection, ✖ deletion, day switching, and purchase-list visibility checks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after Foundational; may reuse the same editor and repository helpers but should remain independently testable.
- **User Story 3 (P2)**: Can start after Foundational; may reuse the same storage and screen state but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Repository menu persistence should be implemented before screen wiring that depends on it.
- Candidate suggestions and ✖ deletion should build on the working save/load flow.

### Parallel Opportunities

- T005 and T006 can run in parallel because they touch different test files.
- T007 and T008 can run in parallel because they verify the same feature from different layers.
- T012 and T013 can run in parallel because they touch different test files.
- T017 and T018 can run in parallel because they cover separate verification concerns.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to create the schema, model, and shared state scaffolding.
2. Complete Phase 2 to add the baseline meal-menu tests.
3. Complete Phase 3 and validate meal-menu save/load independently.
4. **STOP and VALIDATE**: Confirm meal menus can be added and restored for the selected day.
5. Deploy/demo if ready.

### Incremental Delivery

1. Build the add/save/load meal-menu flow for User Story 1.
2. Add the cancel-and-close behavior for User Story 2.
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
