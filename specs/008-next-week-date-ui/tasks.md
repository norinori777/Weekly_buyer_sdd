# Tasks: 翌週日付表示と曜日ボタン簡略化

**Input**: Design artifacts from `specs/008-next-week-date-ui/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Week Context Foundation (Shared)

**Purpose**: Define and apply a next-week default context without changing persisted entities.

- [ ] T001 Decide the single definition of “next week” as the next calendar week (Mon–Sun) and document it in code-level helpers used by the app week computation in `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`.
  - Depends on: none
  - Verification: there is a clear helper/logic that yields a reference date inside the next calendar week using the existing Monday-start rule.

- [ ] T002 Apply the next-week default to the shared selected-date provider in `weekly_buyer/lib/app/providers.dart` so opening the app uses next-week as the active planning window.
  - Depends on: T001
  - Verification: initial `selectedWeekDateProvider` resolves to a date in the next calendar week.

**Checkpoint**: The app has a single, stable next-week reference date driving the active week.

---

## Phase 2: User Story 1 - Plan next week’s shopping by weekday (Priority: P1)

**Goal**: The product registration screen uses next calendar week as its active week and correctly maps weekday selection to that week.

**Independent Test**: Open the item-add/product registration screen and confirm the week label corresponds to next week; switch weekdays and confirm content stays within that next-week scope.

- [ ] T003 Wire the item-add destination to the updated shared selected date and confirm the snapshot load path is driven by that date in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T002
  - Verification: the loaded snapshot’s `weekRange` corresponds to next calendar week when the screen is first opened.

- [ ] T004 Ensure weekday switching (tap + swipe) continues to select a date inside the currently loaded week range (now next week) in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T003
  - Verification: selecting “水” (or any weekday) maps to the corresponding date within the next-week `weekRange`.

**Checkpoint**: The registration screen consistently operates within next calendar week.

---

## Phase 3: User Story 2 - Reduce clutter in weekday selector (Priority: P2)

**Goal**: Weekday selector buttons show weekday-only labels with no numeric dates.

**Independent Test**: Open the screen and confirm the weekday chips show only “月…日” and do not include digits or date separators.

- [ ] T005 Update weekday label formatting so the chip label shows weekday-only text (no month/day) in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T004
  - Verification: weekday chip labels contain only weekday text and contain no digits.

- [ ] T006 Confirm the week-range label remains visible and correct for next week in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart` and referenced formatting utilities.
  - Depends on: T003
  - Verification: week-range label matches next calendar week and does not regress due to label formatting changes.

**Checkpoint**: Weekday selector is simplified while preserving the header’s week context.

---

## Phase 4: Verification & Regression

**Purpose**: Validate the feature with automated checks and guard against date-boundary regressions.

- [ ] T007 Add widget tests asserting weekday-only labels (no digits) in `weekly_buyer/test/widget_test.dart`.
  - Depends on: T005
  - Verification: tests fail before the UI change and pass after; they assert weekday chip labels do not include numeric characters.

- [ ] T008 Add test coverage for next-week default behavior (week label reflects next calendar week) in `weekly_buyer/test/widget_test.dart` (and/or `weekly_buyer/test/repository_test.dart` if date helpers are tested at domain level).
  - Depends on: T002, T003
  - Verification: test asserts initial week context is next calendar week across month/year boundaries.

- [ ] T009 Run `flutter analyze` and `flutter test`, fixing issues only in touched files.
  - Depends on: T007, T008
  - Verification: static analysis and tests pass.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1**: Starts immediately and blocks later phases.
- **Phase 2**: Depends on Phase 1 (next-week default applied) and validates screen behavior.
- **Phase 3**: Depends on Phase 2 (selector behavior stable) and simplifies labels.
- **Phase 4**: Depends on Phases 2–3 and validates via tests and analysis.

### Parallel Opportunities

- T007 and T008 can proceed in parallel once their respective behavior is stable.

## Notes

- Keep “next week” as the next calendar week (Mon–Sun), consistent with existing project decisions.
- Avoid introducing per-screen week defaults in this feature; keep a single shared planning week unless a later spec requires otherwise.
- Do not add new UI (week picker) in this iteration.
