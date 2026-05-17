# Tasks: 未分類商品の商品マスター登録

**Input**: Design artifacts from `specs/024-uncategorized-item-master/`
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `[P]` means the task can run in parallel with other `[P]` tasks
- `[Story]` marks tasks that belong to a user story phase
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the shared item editor so it can be reused from the purchase list without changing the settings flow.

- [X] T001 Extend [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart) with a purchase-list registration mode that can set a feature-specific title and submit label, hide the uncategorized option, and require category selection while keeping the existing category settings flow unchanged.

**Checkpoint**: The shared editor can support both item-settings edits and purchase-list registration reuse.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Add the purchase-list plumbing that all uncategorized-item registration flows depend on.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T002 Add uncategorized-item long-press plumbing in [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart) so item tiles can recognize `categoryId == null`, open the shared editor hook, and short-circuit the flow when no categories are available.

**Checkpoint**: The purchase list can now distinguish uncategorized rows and start the registration path safely.

---

## Phase 3: User Story 1 - 未分類の商品を商品マスターに登録する (Priority: P1) 🎯 MVP

**Goal**: 購入リスト画面の未分類 item を長押しし、カテゴリとひらがなを入力して商品マスターに登録できる。

**Independent Test**: 購入リスト画面で未分類 item を長押しし、カテゴリとひらがなを入力して登録すると、その item が商品マスターに保存され、次回以降の候補として再利用できる。

### Implementation for User Story 1

- [X] T003 [US1] Open the shared registration sheet from [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart) with the tapped uncategorized item's display name prefilled and the purchase-list registration mode enabled from T001.
- [X] T004 [US1] Submit successful registrations from [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart) through [weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart](weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart) by calling `addItemMaster` and refreshing the current purchase snapshot afterward.

**Checkpoint**: Unclassified purchase-list items can be promoted to reusable product master entries.

---

## Phase 4: User Story 2 - 対象外の商品を誤って登録しない (Priority: P2)

**Goal**: すでにカテゴリが付いている item には登録導線を出さず、カテゴリ未設定でも開始できない場合は分かりやすく止める。

**Independent Test**: カテゴリ付き item を長押ししても登録導線が出ず、カテゴリが存在しない状態では登録フローが開始されずにユーザー向けメッセージが表示される。

### Implementation for User Story 2

- [X] T005 [US2] Keep categorized rows from exposing the registration affordance in [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart) and show a user-visible message when a long-press registration is attempted without any categories available.
- [X] T006 [US2] Preserve the existing swipe-to-purchase, undo, and read-only behavior in [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart) while threading the new long-press path through the item tile widget.

**Checkpoint**: Only uncategorized rows expose the new registration path, and the purchase-list experience remains intact.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Validate the updated purchase-list and item-master flow end to end and catch regressions.

- [X] T007 Run `flutter analyze` and `flutter test` from [weekly_buyer/](weekly_buyer/) and fix any issues in [weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/item_editor_destination.dart), [weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart](weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart), and [weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart](weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart).
- [ ] T008 Verify the manual quickstart in [specs/024-uncategorized-item-master/quickstart.md](specs/024-uncategorized-item-master/quickstart.md) on a device or emulator, confirming uncategorized-item registration, category selection, and reuse of the newly created product master entry.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies; can start immediately.
- **Foundational (Phase 2)**: Depends on Setup completion and blocks all user stories.
- **User Stories (Phase 3+)**: All depend on the Foundational phase being complete.
- **Polish (Final Phase)**: Depends on all desired user stories being complete.

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational; establishes the core uncategorized-item registration flow.
- **User Story 2 (P2)**: Can start after Foundational; hardens the flow so categorized rows and empty-category states do not expose the new action.

### Within Each User Story

- The shared editor mode from T001 should be in place before wiring the purchase-list sheet.
- The purchase-list plumbing from T002 should be in place before adding the submit path and snapshot refresh.
- User Story 2 should preserve the behavior already covered by User Story 1 instead of reworking the submission path.

### Parallel Opportunities

- The plan is intentionally mostly sequential because the same purchase-list presentation file is touched by the new affordance, the uncategorized guard, and the existing swipe behavior.
- After T001 lands, T003 and T005 can be split by implementation focus only if the shared editor mode is already stable and the same file is not being edited concurrently.
- T007 and T008 are validation steps and should be scheduled after the UI changes settle.

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories).
3. Complete Phase 3: User Story 1.
4. **STOP and VALIDATE**: Confirm an uncategorized purchase-list item can be promoted to a reusable product master entry.
5. Deploy/demo if ready.

### Incremental Delivery

1. Add the shared purchase-list registration mode to the editor.
2. Wire uncategorized rows to the registration flow and persist the new product master entry.
3. Harden the flow so categorized rows and empty-category cases do not expose the new action.
4. Run validation after each story so the purchase list remains stable.

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
- Keep the feature local to the existing weekly shopping list flow and avoid schema changes.