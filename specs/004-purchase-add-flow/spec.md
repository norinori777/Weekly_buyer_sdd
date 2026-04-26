# Feature Specification: 購入・登録フロー

**Feature Branch**: `004-purchase-add-flow`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "画面遷移と画面の実装が正しくないです。購入リスト画面は週の全商品をカテゴリごとに表示し、購入済みは左フリックで一覧から非表示にする。商品登録画面は週の日にちごとに商品を登録し、週タブはフリックで曜日を切り替える。購入リスト画面から商品登録はしない。商品登録画面は画面下部の商品追加から遷移する。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Purchase items from a category-based list (Priority: P1)

買い物をする人として、今週の全商品をカテゴリごとに見ながら、買い物中に購入済みの項目だけを素早く非表示にしたい。

**Why this priority**: 買い物の中心動作であり、この画面が正しく使えないとアプリの価値が成立しないため。

**Independent Test**: 購入リスト画面を開いて、商品がカテゴリごとに表示され、左フリックで購入済みにすると一覧から消えることを確認できる。

**Acceptance Scenarios**:

1. **Given** 今週のリストに未購入の商品がある状態, **When** ユーザーが購入リスト画面を開く, **Then** 商品はカテゴリごとにまとまって表示される
2. **Given** 購入リスト画面に商品が表示されている状態, **When** ユーザーが商品を左フリックする, **Then** その商品は購入済みとなり一覧から非表示になる
3. **Given** 購入リスト画面を表示している状態, **When** ユーザーが商品登録を探す, **Then** この画面には商品登録の導線は表示されない

---

### User Story 2 - Register items by day within a week (Priority: P1)

買い物をする人として、商品登録画面で週の中の曜日を切り替えながら、その日に登録したい商品をまとめて入力したい。

**Why this priority**: 商品登録の入口と日別入力の流れが正しくないと、週単位の入力が混乱するため。

**Independent Test**: 購入リスト画面から商品登録画面へ遷移し、曜日を切り替えながら商品を登録できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 購入リスト画面を表示している状態, **When** ユーザーが画面下部の商品追加をタップする, **Then** 商品登録画面が表示される
2. **Given** 商品登録画面が表示されている状態, **When** ユーザーが週タブをフリックする, **Then** 表示対象の曜日が切り替わる
3. **Given** 商品登録画面で選択中の曜日がある状態, **When** ユーザーがその曜日に商品を追加する, **Then** 商品はその曜日の登録内容として保存される

---

### User Story 3 - Keep weekly context stable while navigating (Priority: P2)

買い物をする人として、購入リスト画面と商品登録画面を行き来しても、同じ週を見続けたい。

**Why this priority**: 画面遷移のたびに週が変わると、登録済み内容と表示内容が一致しなくなるため。

**Independent Test**: 購入リスト画面から商品登録画面へ移動し、戻っても同じ週の内容が維持されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** 今週の購入リストを見ている状態, **When** ユーザーが商品登録画面へ遷移する, **Then** 同じ週の文脈が保たれたまま商品登録画面が表示される
2. **Given** 商品登録画面で曜日を切り替えた状態, **When** ユーザーが購入リスト画面へ戻る, **Then** 週の文脈が維持されたまま購入リスト画面が表示される

---

### Edge Cases

- すべての商品が購入済みになった場合は、空状態をわかりやすく表示する。
- 購入リスト画面では、週の見出しや曜日タブ、朝昼夜の区分を表示しない。
- 商品登録画面では、選択中の曜日が変わっても、同じ週の登録内容として扱う。
- 同じ商品名が複数日に登録されている場合は、曜日ごとの登録として区別できるようにする。
- 左フリック後の元に戻す操作で、直前の購入済み状態を復帰できるようにする。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the weekly shopping items on the purchase list screen grouped by category.
- **FR-002**: System MUST not show weekly date headers, weekday tabs, or morning/afternoon/evening sections on the purchase list screen.
- **FR-003**: System MUST allow users to mark a shopping item as purchased by a left swipe on the purchase list screen.
- **FR-004**: System MUST hide purchased items from the active purchase list view after they are marked as purchased.
- **FR-005**: System MUST open the item registration screen when the user taps the bottom add action.
- **FR-006**: System MUST allow users to switch the displayed weekday on the item registration screen by swiping the week tabs.
- **FR-007**: System MUST allow users to register items for the selected weekday on the item registration screen.
- **FR-008**: System MUST keep the selected week consistent when users move between the purchase list screen and the item registration screen.
- **FR-009**: System MUST keep purchase and registration data available after the app is closed and reopened.
- **FR-010**: System MUST provide an undo action that restores the most recently purchased item to the active list.

### Key Entities *(include if feature involves data)*

- **Shopping Week**: The current week that contains the items shown in both screens.
- **Shopping Item**: A purchasable item with name, quantity, category, purchase state, and assigned day when registered.
- **Category**: A grouping used to organize purchase list items in a stable order.
- **Week Day Registration**: The day-specific registration context used on the item registration screen.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can identify the purchase list screen as a category-based shopping view without guidance.
- **SC-002**: At least 90% of test users can open the item registration screen from the bottom add action in two actions or fewer.
- **SC-003**: At least 90% of test users can switch to a different weekday on the item registration screen and register an item for that day.
- **SC-004**: At least 90% of test users can mark an item as purchased and see it disappear from the purchase list without leaving the screen.
- **SC-005**: Saved weekly data remains available after closing and reopening the app in the verification test.

## Assumptions

- The week starts on Monday and ends on Sunday.
- The purchase list screen is read-only for item creation.
- The bottom add action is the primary entry point to item registration.
- Local storage is retained between app sessions.
- Cloud sync and shared editing are out of scope for this feature.