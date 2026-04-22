# Tasks: 翌週の購入日を既定表示にする

**Input**: Design artifacts from `specs/010-next-week-weekday-display/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[US1]` marks tasks that belong to User Story 1
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Define the shared next-week reference that every item-add screen will use.

- [x] T001 Add a next-calendar-week helper to `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` so the app can derive the Monday-based start of the following week from a base date.
- [x] T002 Update `weekly_buyer/lib/app/providers.dart` so `selectedWeekDateProvider` initializes from the next-calendar-week helper instead of `dateOnly(DateTime.now())`.

**Checkpoint**: The shared selected-date state now opens the app on the next calendar week.

---

## Phase 2: User Story 1 - 商品追加画面を翌週基準で開く (Priority: P1)

**Goal**: 商品追加画面を開いた時点で、表示対象の週が翌週になっている。

**Independent Test**: 商品追加画面を開き、週表示と曜日選択が現在週ではなく翌週の月曜始まりの範囲を指していることを確認する。

### Tests for User Story 1

- [x] T003 [P] [US1] Add a widget regression test in `weekly_buyer/test/widget_test.dart` that opens the item-add screen and asserts the first loaded `weekRange` is the next calendar week.
- [x] T004 [P] [US1] Add date-boundary coverage in `weekly_buyer/test/repository_test.dart` for the next-calendar-week helper across month-end and year-end transitions.

### Implementation for User Story 1

- [x] T005 [US1] Verify and, if needed, adjust `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` so the loaded snapshot, item insertion, and invalidation all continue to use the shared selected-date state after the default week shifts to next week.

**Checkpoint**: 商品追加画面の初期表示が翌週に切り替わり、関連する読み込みと操作がその週に追従する。

---

## Phase 3: Polish & Cross-Cutting Concerns

**Purpose**: Validate the change end to end and catch regressions.

- [x] T006 Run `flutter analyze` and `flutter test` from `weekly_buyer/`, fixing any issues in touched files.
- [ ] T007 Confirm the manual quickstart steps in `specs/010-next-week-weekday-display/quickstart.md` on an emulator or device, including month-end and year-end boundary cases.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: No dependencies; can start immediately.
- **Phase 2**: Depends on Phase 1 because the screen must have a shared next-week default before the story can be validated.
- **Phase 3**: Depends on Phase 2.

### User Story Dependencies

- **User Story 1 (P1)**: Independent; no dependencies on other stories.

### Within Each User Story

- Tests should be written before or alongside implementation and should fail until the behavior is in place.
- Shared date helpers should be implemented before screen-level wiring.
- Validation should run after the touched files are updated.

### Parallel Opportunities

- T003 and T004 can run in parallel because they touch different test files.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 to define the shared next-week default.
2. Complete the story-specific tests in Phase 2.
3. Adjust the item-add screen only if any local week bootstrapping still points at the current week.
4. Run Phase 3 validation and stop once the next-week default is verified.

### Incremental Delivery

1. Add the next-week helper.
2. Switch the shared selected-date provider to use it.
3. Add regression tests for the new default and boundary cases.
4. Validate manually and with automated checks.
