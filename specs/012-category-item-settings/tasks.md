# Tasks: Category and Item Settings

**Input**: Design artifacts from `specs/012-category-item-settings/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the shared screen entry point and provider scaffolding used by the category/item settings feature.

- [X] T001 Create the category/item settings route entry in `weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart` and add the new screen shell in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart`.
- [X] T002 Create the shared category/item settings state and provider scaffolding in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_notifier.dart` and expose it from `weekly_buyer/lib/app/providers.dart`.

**Checkpoint**: The app can navigate into a dedicated category/item settings screen backed by shared state.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the repository-level validation helpers that every category/item story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Add category/item delete-guard helpers and exception types in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
- [X] T004 [P] Add shared repository access helpers for category/item loading and purchase-week lookup in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and wire the invalidation hooks in `weekly_buyer/lib/app/providers.dart`.

**Checkpoint**: The repository exposes the validation primitives needed for category and item management.

---

## Phase 3: User Story 1 - カテゴリを追加・変更・削除したい (Priority: P1)

**Goal**: ユーザーがカテゴリを名前だけで追加・編集・削除でき、カテゴリ内に商品がある場合は削除できない。

**Independent Test**: カテゴリを作成・編集・削除でき、カテゴリ内に商品があると削除が止まり、理由が表示される。

### Tests for User Story 1

- [X] T005 [P] [US1] Add repository regression tests for category add/update/delete success and delete-blocking behavior in `weekly_buyer/test/repository_test.dart`.
- [X] T006 [P] [US1] Add widget regression tests for the category editor inputs and delete-disabled state in `weekly_buyer/test/category_item_settings_test.dart`.

### Implementation for User Story 1

- [X] T007 [US1] Implement the category list, name-only editor form, and delete confirmation UI in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart`.
- [X] T008 [US1] Implement category add/update/delete flow and the empty-category delete check in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_notifier.dart`.

**Checkpoint**: Category management is independently functional and enforces the no-items delete rule.

---

## Phase 4: User Story 2 - 商品を追加・変更・削除したい (Priority: P2)

**Goal**: ユーザーが商品を追加・編集・削除でき、数量入力は表示されず、現在の購入週に含まれる商品は削除できない。

**Independent Test**: 商品を作成・編集・削除でき、現在の購入週に含まれる商品は削除が止まり、理由が表示される。

### Tests for User Story 2

- [X] T009 [P] [US2] Add repository regression tests for item add/update/delete success and current-week delete-blocking behavior in `weekly_buyer/test/repository_test.dart`.
- [X] T010 [P] [US2] Add widget regression tests for the item editor inputs and delete-blocked messaging in `weekly_buyer/test/category_item_settings_test.dart`.

### Implementation for User Story 2

- [X] T011 [US2] Implement the item editor/list UI without quantity input in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart`.
- [X] T012 [US2] Implement item add/update/delete flow and the current-week delete check in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart`.

**Checkpoint**: Item management is independently functional and enforces the current-week delete rule.

---

## Phase 5: User Story 3 - 削除不可理由を分かりやすく表示する (Priority: P3)

**Goal**: ユーザーが削除不可の理由を画面上で理解でき、無効状態と説明文で誤操作を避けられる。

**Independent Test**: 削除ボタンの無効状態、理由テキスト、必要なアクセシビリティ情報が確認できる。

### Tests for User Story 3

- [X] T013 [P] [US3] Add widget regression tests for disabled delete affordances, reason text, and accessible labels in `weekly_buyer/test/category_item_settings_test.dart`.

### Implementation for User Story 3

- [X] T014 [US3] Add semantics, disabled-action handling, and reusable delete-reason UI in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart`.

**Checkpoint**: The settings UI clearly communicates why deletion is unavailable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across user stories.

- [X] T015 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in `weekly_buyer/lib/features/weekly_shopping_list/**` and `weekly_buyer/test/**`.
- [ ] T016 Confirm the manual quickstart steps in `specs/012-category-item-settings/quickstart.md` on an emulator or device, including category deletion blocking, item deletion blocking, and field-visibility checks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P2)**: Can start after Foundational; may reuse shared repository helpers but must remain independently testable.
- **User Story 3 (P3)**: Can start after Foundational; builds on the same screens but must remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Repository validation should be implemented before screen wiring that depends on it.
- UI reason messaging should be layered on top of the working delete guards.

### Parallel Opportunities

- T005 and T006 can run in parallel because they touch different test files.
- T009 and T010 can run in parallel because they touch different test files.
- T013 can run in parallel with T015 once the UI behavior is implemented.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to create the screen entry and shared state scaffolding.
2. Complete Phase 2 to add repository validation helpers and exceptions.
3. Complete Phase 3 and validate category management independently.
4. **STOP and VALIDATE**: Confirm category add/edit/delete and the empty-category delete rule.
5. Deploy/demo if ready.

### Incremental Delivery

1. Build the category management flow for User Story 1.
2. Add item management for User Story 2.
3. Add delete-reason messaging and accessibility improvements for User Story 3.
4. Run validation after each story to keep the screen independently testable.

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

- `[P]` tasks = different files, no dependencies on incomplete work.
- `[Story]` label maps task to a specific user story for traceability.
- Each user story should be independently completable and testable.
- Verify tests fail before implementing the corresponding behavior.
- Keep the feature local-only and consistent with the existing Flutter/Riverpod/Drift architecture.
