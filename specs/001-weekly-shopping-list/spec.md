# Feature Specification: Weekly Shopping List

**Feature Branch**: `001-weekly-buyer-specify`  
**Created**: 2026-04-18  
**Status**: Draft  
**Input**: User description: "１週間分の買い物リストを登録"

## Clarifications

### Session 2026-04-19

- Q: 週の開始日はどうしますか？ → A: 月曜始まりの日曜終わりで固定する
- Q: 「その他」は何を意味しますか？ → A: 朝、昼、夜の区分けがない商品リストとして扱う

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a Weekly Shopping List (Priority: P1)

買い物をする人として、１週間分の買い物リストを新しく登録したい。登録したリストには、商品名、数量、カテゴリを入れておき、次回の買い物でも使えるようにしたい。

**Why this priority**: 週ごとの買い物リストを登録できないと、この機能の価値が始まらないため。

**Independent Test**: 新しい１週間分の買い物リストを作成し、複数の商品を追加したあと、画面を閉じて開き直しても内容が残っていることを確認できる。

**Acceptance Scenarios**:

1. **Given** まだ買い物リストがない状態, **When** ユーザーが新しい１週間分のリストを作成する, **Then** その週の買い物リストが保存されて表示される
2. **Given** 空の週次リスト, **When** ユーザーが商品名と数量を追加する, **Then** 商品がその週のリストに登録される

---

### User Story 2 - Reuse Known Items and Categories (Priority: P2)

買い物をする人として、よく買う商品を再利用したい。商品をカテゴリごとにまとめて見られるようにして、毎回同じ入力を繰り返さずに済ませたい。

**Why this priority**: 毎回の入力負担を減らし、週次リストの登録を速くする価値が高いため。

**Independent Test**: 一度登録した商品が次回の登録時に候補として出ること、カテゴリ順で一覧できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 以前に登録した商品がある状態, **When** ユーザーが商品を追加しようとする, **Then** 既知の商品が候補として表示される
2. **Given** まだ登録していない商品名を入力した状態, **When** ユーザーが新規登録を選ぶ, **Then** その商品が再利用可能な候補として保存される
3. **Given** 複数の商品が異なるカテゴリに属している状態, **When** ユーザーが一覧を開く, **Then** 商品はカテゴリ順でまとまって表示される

---

### Edge Cases

- １週間分のリストが空のときは、空状態を示して最初の追加を促す。
- 同じ商品を複数回追加した場合は、数量の違いが分かるように表示する。
- 商品名が既知の候補にない場合は、新規登録の流れへ進める。
- 週をまたいで保存されたリストがある場合でも、今見ている週の内容が混ざらないようにする。
- 朝、昼、夜の区分けがない商品は「その他」にまとめ、曜日や時間帯に属さない独立した商品リストとして扱う。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to create a weekly shopping list for a chosen week.
- **FR-002**: System MUST allow users to add shopping items with at least item name, quantity, and category.
- **FR-003**: System MUST preserve weekly shopping list data so users can reopen it later.
- **FR-004**: System MUST show shopping items in a category-based order that users can understand without switching views.
- **FR-005**: System MUST allow users to reuse previously registered items as candidates when adding new items.
- **FR-006**: System MUST allow users to register a new reusable item when the entered item is not already known.
- **FR-007**: System MUST allow users to mark an item as purchased during shopping.
- **FR-008**: System MUST remove purchased items from the active shopping list view until the user restores them.
- **FR-009**: System MUST allow users to restore the most recent purchased item through an undo action.
- **FR-010**: System MUST keep shopping data available offline.
- **FR-011**: System MUST allow users to manage category order for the shopping list.
- **FR-012**: System MUST allow users to place items in a special "Other" list for items that are not tied to morning, afternoon, or evening sections.

### Key Entities *(include if feature involves data)*

- **Weekly Shopping List**: A list for one week of shopping items, including the week it belongs to and the items registered for that week.
- **Shopping Item**: A purchasable item in the weekly list, including name, quantity, category, and purchase state.
- **Item Master**: A reusable catalog entry for known items so users can add common items quickly.
- **Category**: A grouping used to organize items in a stable order during shopping.
- **Other List**: A special day-independent item list used for items that are not assigned to morning, afternoon, or evening sections.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can create a weekly shopping list and add at least 10 items without leaving the main list flow.
- **SC-002**: At least 90% of test users can add a familiar item from candidates or create a new reusable item on the first attempt.
- **SC-003**: At least 90% of test users can mark a purchased item and undo that action successfully within the shopping flow.
- **SC-004**: A saved weekly shopping list remains available after the app is closed and reopened.
- **SC-005**: Users can identify the next item to buy from the weekly list without switching to a different screen.

## Assumptions

- Users primarily use the app in Japanese.
- The first version focuses on offline use with local persistence only.
- One weekly list can be created per week, with past weeks remaining available for later review.
- Users may add items manually or from reusable suggestions.
- Cloud sync, shared editing, and widgets are out of scope for the first version.
