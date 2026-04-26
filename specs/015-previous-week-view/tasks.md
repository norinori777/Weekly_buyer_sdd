# Tasks: 前週参照表示

**Input**: Design artifacts from `specs/015-previous-week-view/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the shared week-view state and read-only mode scaffolding used by the product registration screen.

- [X] T001 Add a week-view mode model and read-only state flags in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` so the app can distinguish next-week editing from prior-week viewing.
- [X] T002 Create shared week navigation state and helpers in `weekly_buyer/lib/app/app_state_providers.dart`, and expose any needed wiring from `weekly_buyer/lib/app/providers.dart`.
- [X] T003 Add repository helpers for loading the selected week snapshot and any existing-week navigation data in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: The app can represent a prior-week view in shared state and resolve the correct week data from the repository.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the repository and widget regression coverage that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 Add repository regression tests for resolving the default next-week snapshot and prior-week snapshots in `weekly_buyer/test/repository_test.dart`.
- [X] T005 Add widget regression tests for switching to a prior week and confirming the screen enters a read-only state in `weekly_buyer/test/widget_test.dart`.

**Checkpoint**: The repository and widget harness can exercise the baseline prior-week behavior for the product registration screen.

---

## Phase 3: User Story 1 - 過去週を表示して購入内容を参照する (Priority: P1)

**Goal**: ユーザーが商品追加画面から前の週、2週間前、3週間前へ切り替えて、購入内容と料理メニューを参照できる。

**Independent Test**: 商品追加画面を開き、前の週・2週間前・3週間前へ順に切り替えて、各週の内容が正しく表示されることを確認できる。

### Tests for User Story 1

- [X] T006 [P] [US1] Add repository regression tests for sequentially resolving one week back, two weeks back, and three weeks back in `weekly_buyer/test/repository_test.dart`.
- [X] T007 [P] [US1] Add widget regression tests for the week navigation controls and the displayed week contents in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 1

- [X] T008 [US1] Add prior-week navigation controls and the active-week display update in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
- [X] T009 [US1] Update `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` so the selected prior week is shown in the same product-add screen without introducing a new screen.
- [X] T010 [US1] Ensure `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` reads the selected prior-week snapshot and renders the matching purchase and meal-menu content.

**Checkpoint**: The product registration screen can move back through prior weeks and show the corresponding week data.

---

## Phase 4: User Story 2 - 過去週では読み取り専用で参照する (Priority: P1)

**Goal**: ユーザーが過去週を表示したとき、商品追加と料理メニュー追加ができず、表示のみになる。

**Independent Test**: 過去週を表示した状態で、商品追加と料理メニュー追加の導線が無効化され、保存操作が実行されないことを確認できる。

### Tests for User Story 2

- [X] T011 [P] [US2] Add repository regression tests that confirm prior-week selection does not create or modify saved content in `weekly_buyer/test/repository_test.dart`.
- [X] T012 [P] [US2] Add widget regression tests that confirm add buttons and input actions are disabled in prior-week mode in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 2

- [X] T013 [US2] Gate item-adding actions behind the read-only week state in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
- [X] T014 [US2] Gate meal-menu adding actions behind the read-only week state in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
- [X] T015 [US2] Ensure `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` continues to render purchase data only and never enables prior-week editing.

**Checkpoint**: Prior-week views are clearly read-only and cannot be edited from the product registration screen.

---

## Phase 5: User Story 3 - 元の翌週表示へ戻る (Priority: P2)

**Goal**: ユーザーが過去週の確認を終えたあと、次週の初期表示へ戻り、通常の編集状態に復帰できる。

**Independent Test**: 任意の過去週から次週の初期表示へ戻れること、空の週でもエラーにならず表示できることを確認できる。

### Tests for User Story 3

- [X] T016 [P] [US3] Add repository regression tests for returning to the default next-week snapshot and handling empty prior-week snapshots in `weekly_buyer/test/repository_test.dart`.
- [X] T017 [P] [US3] Add widget regression tests for returning from prior-week mode to next-week mode and confirming the edit controls become available again in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 3

- [X] T018 [US3] Add a return-to-next-week action in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart` and wire it to the shared week state.
- [X] T019 [US3] Ensure `weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart` restores the default next-week editing mode when the user returns from a prior week.
- [X] T020 [US3] Keep empty prior-week states usable in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` so the screen shows an empty but non-error view.

**Checkpoint**: Users can return to the default next-week editing flow, and empty historical weeks remain readable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across user stories.

- [X] T021 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in `weekly_buyer/lib/app/**`, `weekly_buyer/lib/features/weekly_shopping_list/**`, and `weekly_buyer/test/**`.
- [ ] T022 Confirm the manual quickstart steps in `specs/015-previous-week-view/quickstart.md` on an emulator or device, including prior-week navigation, read-only behavior, empty-week display, and return-to-next-week checks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after User Story 1 or alongside it once the shared week state exists; should remain independently testable.
- **User Story 3 (P2)**: Can start after User Story 2; reuses the same navigation and read-only state but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Week navigation state should be implemented before the screen wiring that depends on it.
- Read-only gating should build on the working prior-week selection flow.

### Parallel Opportunities

- T004 and T005 can run in parallel because they touch different test files.
- T006 and T007 can run in parallel because they verify the same feature from different layers.
- T011 and T012 can run in parallel because they touch different test files.
- T016 and T017 can run in parallel because they cover separate verification concerns.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to create the week-view state scaffolding.
2. Complete Phase 2 to add the baseline prior-week tests.
3. Complete Phase 3 and validate prior-week navigation and display independently.
4. **STOP and VALIDATE**: Confirm a prior week can be opened and displayed from the product registration screen.
5. Deploy/demo if ready.

### Incremental Delivery

1. Build the prior-week navigation and display flow for User Story 1.
2. Add the read-only behavior for User Story 2.
3. Add the return-to-default flow and empty-week handling for User Story 3.
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
