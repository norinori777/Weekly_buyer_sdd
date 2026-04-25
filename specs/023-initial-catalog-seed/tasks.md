# Tasks: 初期カテゴリとひらがな名の投入

**Input**: Design artifacts from `specs/023-initial-catalog-seed/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Locate the current seed definition and the repository tests that will validate the updated initial catalog.

- [X] T001 Inspect the current initial catalog seed and startup hook in [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) and the related repository coverage in [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) so the new seed definition and sync behavior can be added without changing the database schema.

**Checkpoint**: The implementation scope is limited to the existing database seed path and repository regression tests.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Lock in the desired startup behavior before rewriting the seed data.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 [P] Add repository regression coverage in [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) for a clean database startup so the specified categories and item masters are created with hiragana values on first launch.
- [X] T003 [P] Add repository regression coverage in [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) for a pre-populated database so rerunning app startup does not duplicate seeded categories or item masters and does not overwrite existing user data.

**Checkpoint**: The expected seed behavior is captured in tests before the implementation changes.

---

## Phase 3: User Story 1 - 初期カテゴリを正しい構成で用意する (Priority: P1) 🎯 MVP

**Goal**: ユーザーが初回起動ですぐ使えるように、指定されたカテゴリ構成と各カテゴリ配下の商品候補が用意される。

**Independent Test**: 空のデータ環境でアプリを起動し、指定されたカテゴリと各カテゴリ配下の商品候補が作成されることを確認できる。

### Tests for User Story 1

- [X] T004 [P] [US1] Extend [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) with assertions for the exact seeded category names and their expected order.
- [X] T005 [P] [US1] Extend [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) with assertions for the exact item counts per seeded category so the full catalog structure is validated on startup.

### Implementation for User Story 1

- [X] T006 [US1] Update [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) so the startup seed definition matches the provided category list and item list, including category names and category order.
- [X] T007 [US1] Update [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) so startup seed synchronization creates any missing seeded categories and item masters when the catalog is empty or partially populated.

**Checkpoint**: The specified initial categories and item candidates are available after app startup.

---

## Phase 4: User Story 2 - 商品候補にひらがな名を持たせる (Priority: P1)

**Goal**: ユーザーが商品候補を読みから見つけられるように、seed された商品候補にひらがな名を持たせる。

**Independent Test**: 初期投入された各商品候補にひらがな名が登録されていることを確認できる。

### Tests for User Story 2

- [X] T008 [P] [US2] Extend [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) with assertions that every seeded item master has a non-empty hiragana value.
- [X] T009 [P] [US2] Extend [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart) with a regression case proving that rerunning startup preserves or backfills hiragana values without creating duplicate item masters.

### Implementation for User Story 2

- [X] T010 [US2] Update [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) so each seeded item master includes the provided hiragana reading.
- [X] T011 [US2] Update [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) so existing seeded item masters can be backfilled with hiragana values without overwriting user-created records.

**Checkpoint**: Every seeded item candidate has a hiragana name available for lookup and display.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the updated startup seed behavior end to end and catch regressions.

- [X] T012 Run `flutter analyze` and `flutter test test/repository_test.dart` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/app/app_database.dart](weekly_buyer/lib/app/app_database.dart) and [weekly_buyer/test/repository_test.dart](weekly_buyer/test/repository_test.dart).
- [ ] T013 Verify the manual quickstart in [specs/023-initial-catalog-seed/quickstart.md](specs/023-initial-catalog-seed/quickstart.md) on a clean database and on an existing database, confirming the specified categories, item candidates, hiragana values, and non-duplication behavior.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; establishes the base startup catalog shape.
- **User Story 2 (P1)**: Can start after Foundational and should share the same startup seed path as User Story 1.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- The clean-database seed behavior should be validated before adding the partial-population or backfill behavior.
- The hiragana backfill behavior should preserve existing user-created data and avoid duplicate records.

### Parallel Opportunities

- T002 and T003 can run in parallel because they cover separate startup scenarios in the same test file.
- T004 and T005 can run in parallel because they assert different aspects of the same clean-start seed.
- T008 and T009 can run in parallel because they assert different aspects of the same hiragana seed behavior.
- T012 and T013 are final validation steps and should be done after the database seed changes are stable.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm the specified initial categories and item candidates are available after startup.
5. Deploy/demo if ready.

### Incremental Delivery

1. Update the startup seed definition to the specified category set.
2. Add hiragana values for the seeded item masters.
3. Run validation after each step so the initial catalog remains consistent.

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
- Keep the feature local to the existing startup seed path and avoid schema changes.