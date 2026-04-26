# Tasks: SVG アイコン統一

**Input**: Design documents from /specs/016-svg-icon/
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, quickstart.md

**Tests**: 仕様で独立検証が求められているため、アイコン表示と回帰確認のテストタスクを含める。

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: SVG 表示に必要な依存関係と資産定義を整える

- [ ] T001 Add flutter_svg dependency and switch asset registration from assets/weekly_buyer.png to assets/weekly_buyer.svg in weekly_buyer/pubspec.yaml

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: All user stories depend on a reusable brand icon widget

**Checkpoint**: Shared SVG brand icon widget is available for all AppBar updates.

- [ ] T002 Create a reusable SVG brand icon widget in weekly_buyer/lib/app/widgets/weekly_buyer_brand_icon.dart that loads assets/weekly_buyer.svg with a fixed display size and semantic label

---

## Phase 3: User Story 1 - SVG ブランドアイコンを表示する (Priority: P1) 🎯 MVP

**Goal**: 主要画面で SVG のブランドアイコンが表示され、画面サイズに関わらず見た目が保たれる

**Independent Test**: アプリを起動し、主要画面の AppBar に SVG ブランドアイコンが表示されることと、画面サイズ変更でも比率が崩れないことを確認できる。

### Tests for User Story 1

- [ ] T003 [P] [US1] Add brand icon rendering coverage in weekly_buyer/test/brand_icon_test.dart to verify assets/weekly_buyer.svg loads and renders at the intended size

### Implementation for User Story 1

- [ ] T004 [P] [US1] Update the weekly shopping page AppBar in weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart to show the shared SVG brand icon next to the title
- [ ] T005 [P] [US1] Update the remaining AppBars in weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart, and weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart to use the shared SVG brand icon

**Checkpoint**: SVG ブランドアイコンが主要画面で表示され、見た目の統一ができている

---

## Phase 4: User Story 2 - 既存の見た目を壊さずに置き換える (Priority: P2)

**Goal**: アイコン変更後も既存の画面表示や操作が変わらず、安心して使い続けられる

**Independent Test**: 既存の購入リスト、商品追加、設定の各フローがそのまま動作し、アイコン変更による回帰がないことを確認できる。

### Tests for User Story 2

- [ ] T006 [P] [US2] Extend weekly_buyer/test/widget_test.dart with regression coverage that confirms the existing shopping, add-item, and settings flows still work after the SVG icon swap

### Implementation for User Story 2

- [ ] T007 [US2] Delete the obsolete assets/weekly_buyer.png placeholder file after the SVG asset is wired into weekly_buyer/pubspec.yaml
- [ ] T008 [US2] Keep the existing titles, navigation, and action availability stable in weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart, and weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart while validating the SVG icon integration against the current widget tests

**Checkpoint**: Existing behaviors still work and the PNG placeholder is fully retired

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and documentation alignment

- [ ] T009 [P] Validate the updated app against specs/016-svg-icon/quickstart.md and fix any SVG-related layout or analyzer issues in weekly_buyer/lib/app/widgets/weekly_buyer_brand_icon.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart, weekly_buyer/test/brand_icon_test.dart, and weekly_buyer/test/widget_test.dart

---

## Dependencies & Execution Order

### Phase Dependencies

- Phase 1 must complete before SVG rendering work starts.
- Phase 2 blocks both user stories because the shared brand widget is reused everywhere.
- User Story 1 is the MVP and should be completed before User Story 2 is verified.
- Phase 5 depends on the user stories being complete.

### User Story Dependencies

- User Story 1: Depends only on the Setup and Foundational phases.
- User Story 2: Depends on the SVG icon being wired in User Story 1, then verifies no regressions remain.

### Within Each User Story

- Tests, when included, should be written and validated against the updated UI path.
- Shared widgets before screen-specific integration.
- Screen-specific integration before regression cleanup.

### Parallel Opportunities

- T003, T004, and T005 can proceed in parallel after T002 because they touch different files.
- T006 and T007 can proceed in parallel once the SVG icon integration is in place.

---

## Parallel Example: User Story 1

```text
Task: T003 Add brand icon rendering coverage in weekly_buyer/test/brand_icon_test.dart
Task: T004 Update the weekly shopping page AppBar in weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart
Task: T005 Update the remaining AppBars in weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/settings_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/category_order_destination.dart, and weekly_buyer/lib/features/weekly_shopping_list/presentation/category_item_settings_destination.dart
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup.
2. Complete Phase 2: Foundational.
3. Complete Phase 3: User Story 1.
4. Validate the SVG icon on the main app entry points.
5. Stop and demo the brand icon change if the icon renders correctly.

### Incremental Delivery

1. Complete Setup and Foundational work.
2. Deliver User Story 1 so the SVG icon appears in the app.
3. Deliver User Story 2 so the existing flows are confirmed unchanged and the old PNG placeholder is retired.
4. Finish with quickstart validation and any last layout fixes.

### Parallel Team Strategy

1. One developer can implement the shared SVG widget.
2. Another developer can update the AppBars in the destination screens.
3. A third developer can add the icon rendering and regression tests.
