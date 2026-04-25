# Tasks: 商品名のひらがな候補表示

**Input**: Design artifacts from `specs/017-item-hiragana-search/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Add the item-master schema and shared model wiring needed for hiragana storage and search.

- [ ] T001 Add a nullable `hiragana` column and schema upgrade path for the item master table in `weekly_buyer/lib/app/app_database.dart`, then regenerate `weekly_buyer/lib/app/app_database.g.dart`.
- [ ] T002 Update the item master domain model and candidate projection to carry hiragana in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
- [ ] T003 Update repository load/save helpers so item masters can persist and return hiragana in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: The data layer can store and expose hiragana for item masters.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the regression coverage that every user story depends on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T004 [P] Add repository regression tests for hiragana persistence, existing name-only items, and search behavior in `weekly_buyer/test/repository_test.dart`.
- [ ] T005 [P] Add widget regression tests for the item editor hiragana field and search candidate visibility in `weekly_buyer/test/widget_test.dart`.

**Checkpoint**: The new data shape and the expected UI behavior are covered by tests.

---

## Phase 3: User Story 1 - 設定で商品名の読みを登録する (Priority: P1)

**Goal**: ユーザーが設定画面で商品を追加・編集するときに、商品名とひらがなを一緒に登録できる。

**Independent Test**: 設定画面で商品を新規追加または編集し、商品名とひらがなを保存して、再度開いたときに両方が表示される。

### Tests for User Story 1

- [ ] T006 [P] [US1] Add repository regression tests for creating and updating item masters with hiragana in `weekly_buyer/test/repository_test.dart`.
- [ ] T007 [P] [US1] Add widget regression tests for the category/item editor showing a hiragana input and preserving existing hiragana in `weekly_buyer/test/category_item_settings_test.dart`.

### Implementation for User Story 1

- [ ] T008 [US1] Update the item editor bottom sheet to collect hiragana alongside the item name in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart`.
- [ ] T009 [US1] Thread hiragana through the category/item settings notifier and item-mutation flow in `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_notifier.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart`.
- [ ] T010 [US1] Enforce hiragana validation and persist the value when creating or updating item masters in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: Item settings can save and reload hiragana for new and edited items.

---

## Phase 4: User Story 2 - 商品名と読みの両方で候補を見つける (Priority: P1)

**Goal**: ユーザーが商品登録画面で商品名またはひらがなを入力すると、両方から候補を見つけられる。

**Independent Test**: 商品名の一部とひらがなの一部のどちらを入力しても、同じ商品候補が表示されることを確認できる。

### Tests for User Story 2

- [ ] T011 [P] [US2] Add repository regression tests for candidate lookup by name and hiragana, including duplicate suppression, in `weekly_buyer/test/repository_test.dart`.
- [ ] T012 [P] [US2] Add widget regression tests for candidate list visibility when searching by hiragana and avoiding duplicate display in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 2

- [ ] T013 [US2] Extend the candidate search helper to match on both item name and hiragana, and deduplicate by item ID in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
- [ ] T014 [US2] Update the item registration form to surface candidates matched by hiragana in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` and `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.

**Checkpoint**: Candidate search works from both name and hiragana without duplicate rows.

---

## Phase 5: User Story 3 - 既存商品との互換性を保つ (Priority: P2)

**Goal**: 既存のひらがな未設定商品を壊さず、商品名検索の既存挙動を維持する。

**Independent Test**: ひらがなが未登録の商品が商品名検索で引き続き候補に出ること、保存済みデータが壊れないことを確認できる。

### Tests for User Story 3

- [ ] T015 [P] [US3] Add repository regression tests for legacy rows with null hiragana and name-only lookup in `weekly_buyer/test/repository_test.dart`.
- [ ] T016 [P] [US3] Add widget regression tests for legacy items still appearing in candidate results when searched by name in `weekly_buyer/test/widget_test.dart`.

### Implementation for User Story 3

- [ ] T017 [US3] Keep the migration nullable and preserve legacy rows when loading item masters in `weekly_buyer/lib/app/app_database.dart` and `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.
- [ ] T018 [US3] Ensure the search pipeline preserves existing name-only lookup and does not filter out items with a missing hiragana value in `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`.

**Checkpoint**: Existing data remains usable while the new hiragana field is adopted.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Validate the feature end to end and catch regressions across all stories.

- [ ] T019 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in `weekly_buyer/lib/**` and `weekly_buyer/test/**`.
- [ ] T020 Confirm the manual quickstart steps in `specs/017-item-hiragana-search/quickstart.md` on an emulator or device, including hiragana entry, name search, hiragana search, and duplicate suppression checks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; no dependency on other stories.
- **User Story 2 (P1)**: Can start after Foundational; may reuse the item master model but should remain independently testable.
- **User Story 3 (P2)**: Can start after Foundational; depends on the migration shape introduced in Setup but should remain independently testable.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Repository persistence should be implemented before the UI wires in the new field or search behavior.
- Duplicate suppression should be validated at the repository layer before relying on the widget layer.

### Parallel Opportunities

- T004 and T005 can run in parallel because they touch different test files.
- T006 and T007 can run in parallel because they verify the same feature from different layers.
- T011 and T012 can run in parallel because they cover separate verification concerns.
- T015 and T016 can run in parallel because they target different test files.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to add the hiragana schema and model wiring.
2. Complete Phase 2 to add the baseline tests.
3. Complete Phase 3 and validate item settings with hiragana independently.
4. **STOP and VALIDATE**: Confirm item creation and editing can persist hiragana.
5. Deploy/demo if ready.

### Incremental Delivery

1. Build the settings flow for User Story 1.
2. Add the hiragana-aware candidate search for User Story 2.
3. Preserve compatibility for legacy items in User Story 3.
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
