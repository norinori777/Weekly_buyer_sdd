# Feature Specification: 商品追加画面の削除機能

**Feature Branch**: `007-item-add-delete`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "商品追加画面に削除機能を追加してください。追加したアイテムリストの右端に✖アイコンを追加して、✖アイコンをタップすると商品を削除することができます。✖アイコンは、それらしいものにしてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Remove an added item from the add screen (Priority: P1)

買い物をする人として、商品追加画面で追加済みの商品を個別に削除し、不要な登録をすぐに取り消したい。

**Why this priority**: 追加直後に誤登録を取り消せないと、商品追加画面の使い勝手が落ちるため。

**Independent Test**: 商品追加画面で任意の登録済みアイテムの削除操作を行い、そのアイテムが一覧から消えることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加画面に登録済みアイテムが表示されている状態, **When** ユーザーがそのアイテム右端の削除操作をタップする, **Then** そのアイテムは一覧から削除される
2. **Given** あるアイテムを削除した後の状態, **When** ユーザーが同じ曜日の登録内容を再表示する, **Then** そのアイテムは表示されない
3. **Given** 複数のアイテムが登録されている状態, **When** ユーザーが1件だけ削除する, **Then** 他のアイテムはそのまま残る

---

### User Story 2 - See a clear delete affordance for each item (Priority: P1)

買い物をする人として、削除できることが一目で分かる操作を見ながら、誤って押しにくい一覧を使いたい。

**Why this priority**: 削除操作が分かりづらいと、どこから消せるか迷いやすくなるため。

**Independent Test**: 登録済みアイテムの右端に、削除であることが直感的に分かる操作が表示されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** 登録済みアイテムが一覧に表示されている状態, **When** ユーザーが一覧を見る, **Then** 各アイテムの右端に削除操作が表示される
2. **Given** アイテムの削除操作が表示されている状態, **When** ユーザーがそれを確認する, **Then** それが削除用であると直感的に分かる見た目になっている
3. **Given** 登録済みアイテムがない状態, **When** ユーザーが商品追加画面を開く, **Then** 削除操作は表示されない

---

### User Story 3 - Keep the active weekday context intact after deletion (Priority: P2)

買い物をする人として、商品を削除しても今見ている曜日の文脈が保たれ、他の曜日の登録に影響しない状態で使いたい。

**Why this priority**: 削除後に別の曜日や別の登録内容へ混ざると、一覧の信頼性が落ちるため。

**Independent Test**: ある曜日でアイテムを削除し、別の曜日へ切り替えても他曜日の登録に影響がないことを確認できる。

**Acceptance Scenarios**:

1. **Given** 月曜日の登録内容を表示している状態, **When** ユーザーが月曜日のアイテムを削除する, **Then** 火曜日の登録内容には影響しない
2. **Given** ある曜日のアイテムを削除した状態, **When** ユーザーが同じ曜日に留まる, **Then** その曜日の一覧だけが更新された状態で表示される

---

### Edge Cases

- 登録済みアイテムが1件もない場合は、削除操作を表示しない。
- 同じ名前のアイテムが複数ある場合は、押した行だけを削除対象にする。
- 削除後に一覧が空になった場合は、空状態を分かりやすく表示する。
- 画面切り替えの直後でも、削除操作が別の項目にずれないようにする。
- 削除は現在表示中の曜日の登録内容だけに適用する。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a delete control on the right end of each registered item in the item add screen.
- **FR-002**: System MUST remove the selected item when the user taps its delete control.
- **FR-003**: System MUST update the visible item list immediately after deletion.
- **FR-004**: System MUST keep other items in the list unchanged when one item is deleted.
- **FR-005**: System MUST keep deletion limited to the currently selected weekday's registrations.
- **FR-006**: System MUST hide delete controls when there are no registered items to delete.
- **FR-007**: System MUST show an empty state when deletion leaves the selected weekday with no items.
- **FR-008**: System MUST present the delete control in a clear, recognizable way that communicates removal action.

### Key Entities *(include if feature involves data)*

- **Registered Item**: A shopping item shown in the add screen list that can be removed individually.
- **Weekday Registration**: The selected weekday's set of items affected by the delete action.
- **Delete Control**: The visible action on each item row that removes that item.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can identify the delete action on a registered item without guidance.
- **SC-002**: At least 90% of test users can remove a registered item in two actions or fewer.
- **SC-003**: At least 95% of verification runs show the deleted item removed from the visible list immediately.
- **SC-004**: At least 95% of verification runs show that deleting one item does not remove other items in the same list.
- **SC-005**: At least 95% of verification runs show that deleting an item on one weekday does not affect another weekday's registrations.

## Assumptions

- The delete action removes only the selected registered item, not the reusable item catalog.
- The current weekday context remains unchanged after deletion.
- No confirmation dialog is required unless later added by separate requirement.
- Cloud sync and collaborative editing are out of scope for this feature.
