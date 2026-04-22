# Tasks: Category Order Settings

**Input**: Design artifacts from `specs/011-category-order/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Define the shared data and navigation plumbing needed by the category-order screen.

- [X] T001 Add category-order repository helpers in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` to load categories in `sort_order` order and persist reordered categories in one transaction.
- [X] T002 Create the editable category-order state and provider in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_notifier.dart` so the screen can keep a draft order, reset it, and save it.
- [X] T003 Add the settings entry point in `weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart` and the new screen shell in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart` so the feature is reachable from settings.

**Checkpoint**: The app can open a dedicated category-order screen backed by repository APIs and editable draft state.

---

## Phase 2: User Story 1 - 購入リストのカテゴリ順を並べ替える (Priority: P1)

**Goal**: ユーザーが設定画面でカテゴリをドラッグして並べ替え、保存すると購入リスト画面の表示順が変わる。

**Independent Test**: 設定画面でカテゴリを並べ替えて保存し、購入リスト画面を開くと同じ順序でカテゴリが表示される。

### Tests for User Story 1

- [X] T004 [P] [US1] Add a repository regression test in `weekly_buyer/test/repository_test.dart` that saves a reordered category list and asserts the purchase-list load order follows the saved `sort_order` values.
- [ ] T005 [P] [US1] Add a widget regression test in `weekly_buyer/test/category_order_destination_test.dart` that opens the settings screen, drags a category, saves, and verifies the purchase list reflects the new order.

### Implementation for User Story 1

- [X] T006 [US1] Implement the reorderable category list UI, save/cancel controls, and draft-order updates in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart`.
- [X] T007 [US1] Wire save handling in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_notifier.dart` so reordered categories are persisted through `weekly_shopping_repository.dart` and the purchase-list snapshot is invalidated after save.

**Checkpoint**: Category order can be changed, saved, and reflected in the purchase list.

---

## Phase 3: User Story 2 - 並び順を既定に戻す (Priority: P2)

**Goal**: ユーザーが変更したカテゴリ順を既定順に戻せる。

**Independent Test**: 並べ替え後にリセットを押すと、画面上の順序が既定の昇順に戻る。

### Tests for User Story 2

- [ ] T008 [P] [US2] Add a widget regression test in `weekly_buyer/test/category_order_destination_test.dart` that changes the order, taps reset, and confirms the list returns to the default ascending order.

### Implementation for User Story 2

- [X] T009 [US2] Implement the reset action in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_notifier.dart` so the draft order can be restored from the repository before saving.

**Checkpoint**: Users can return to the default category order without leaving the screen.

---

## Phase 4: User Story 3 - 並び順変更を見やすく操作する (Priority: P3)

**Goal**: ユーザーが並べ替え中の状態を見分けやすく、誤操作しにくい形で操作できる。

**Independent Test**: 並べ替え対象の行が視覚的に分かり、ドラッグ対象が明確に示されることを確認する。

### Tests for User Story 3

- [ ] T010 [P] [US3] Add a widget regression test in `weekly_buyer/test/category_order_destination_test.dart` that verifies the drag handle and reorder affordance are visible and accessible.

### Implementation for User Story 3

- [ ] T011 [US3] Add drag-handle semantics, selected-row highlighting, and accessible reorder affordance in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart`.

**Checkpoint**: The reorder interaction is visually clear and accessible.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across user stories.

- [X] T012 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in touched files.
- [ ] T013 Confirm the manual quickstart steps in `specs/011-category-order/quickstart.md` on an emulator or device, including save, cancel, reset, and purchase-list verification.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **User Stories (Phase 2+)**: All depend on the Setup phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Setup; no dependency on other stories.
- **User Story 2 (P2)**: Can start after Setup; builds on the same draft-order screen state but should remain independently testable.
- **User Story 3 (P3)**: Can start after Setup; may reuse the same screen but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The repository update flow should be implemented before save wiring in the screen.
- Reset and accessibility improvements should be layered on top of the working reorder/save flow.

### Parallel Opportunities

- T004 and T005 can run in parallel because they touch different test files.
- T008 and T010 can run in parallel because they touch different verification concerns.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to create the repository API, draft state, and navigation entry.
2. Complete the User Story 1 tests and implementation.
3. **STOP and VALIDATE**: Confirm purchase-list order changes correctly after save.
4. Deploy/demo if ready.

### Incremental Delivery

1. Build the reorder/save flow for User Story 1.
2. Add reset behavior for User Story 2.
3. Add accessibility and visual clarity improvements for User Story 3.
4. Run validation after each story to keep the screen independently testable.

---

## Notes

- `[P]` tasks should modify different files and avoid direct dependency on incomplete work.
- Keep the persisted order in `sort_order` contiguous after save.
- Reuse the existing purchase-list load path instead of introducing a new order store.
