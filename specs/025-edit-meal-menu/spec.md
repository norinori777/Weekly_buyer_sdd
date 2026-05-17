# Feature Specification: 商品追加画面の料理メニュー編集

**Feature Branch**: `025-edit-meal-menu`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User description: "商品追加画面の料理メニューで追加したメニューを編集できるようにしてください。ペンアイコンをタップすると編集できるようにしてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 追加済みの料理メニューを編集する (Priority: P1)

買い物をする人として、商品追加画面にある追加済みの料理メニューを必要に応じてすぐ編集したい。

**Why this priority**: 追加後の修正ができないと、誤入力や予定変更に対応できず、料理メニューを買い物の判断材料として使いにくくなるため。

**Independent Test**: 商品追加画面で既存の料理メニューに表示されたペンアイコンを押し、内容を変更して保存すると、そのメニューだけが更新されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加画面に保存済みの料理メニューが表示されている状態, **When** ユーザーが対象メニューのペンアイコンを押す, **Then** そのメニューの編集画面が開く
2. **Given** 編集画面が開いている状態, **When** ユーザーが内容を修正して保存する, **Then** 対象の料理メニューだけが新しい内容に更新される
3. **Given** 同じ区分に複数の料理メニューが表示されている状態, **When** ユーザーが 1 件だけ編集して保存する, **Then** ほかの料理メニューは変更されない

---

### User Story 2 - 編集中の変更を破棄する (Priority: P1)

買い物をする人として、編集途中でやめたいときに、元の内容を残したまま閉じたい。

**Why this priority**: 編集の取り消しができないと、誤操作や途中離脱で意図しない変更が残るおそれがあるため。

**Independent Test**: 既存メニューのペンアイコンを押して編集画面を開き、キャンセルして閉じたあと、元の内容がそのまま残っていることを確認できる。

**Acceptance Scenarios**:

1. **Given** 編集画面が開いている状態, **When** ユーザーがキャンセルして閉じる, **Then** 元の料理メニューは更新されない
2. **Given** 編集画面で内容を入力済みの状態, **When** ユーザーが保存せずに閉じる, **Then** 入力中の変更は破棄される
3. **Given** 保存済みの料理メニューがある状態, **When** ユーザーが画面を開き直す, **Then** 直前に保存した内容がそのまま表示される

---

### Edge Cases

- 編集内容が空欄または空白だけの場合は、元の料理メニューを上書きしない。
- 1 件の料理メニューを編集しても、同じ区分にあるほかの料理メニューはそのまま残る。
- 料理メニューが保存されていない状態では、編集用のペンアイコンを表示しない。
- 編集対象は、ユーザーが押したペンアイコンに対応する 1 件だけとする。
- 長い料理メニュー名や記号を含む内容でも、編集後に欠けずに表示できる。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display an edit control for each saved meal menu entry on the item add screen.
- **FR-002**: System MUST open the meal-menu editing form when the user activates the edit control for a saved entry.
- **FR-003**: System MUST prefill the editing form with the current text of the selected meal menu entry.
- **FR-004**: System MUST update only the selected meal menu entry when the user saves edited content.
- **FR-005**: System MUST keep the edited meal menu associated with the same day and section as the original entry.
- **FR-006**: System MUST prevent empty or whitespace-only edits from overwriting an existing meal menu entry.
- **FR-007**: System MUST leave the original meal menu unchanged when the user cancels or closes the editing form without saving.

### Key Entities *(include if feature involves data)*

- **Meal Menu Entry**: A saved menu item shown under a meal section for a selected day.
- **Edit Control**: The pen icon used to open editing for one specific saved meal menu entry.
- **Meal Menu Editing Form**: The input surface used to change the text of an existing meal menu entry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can open the correct meal-menu editor and save a change in under 1 minute without guidance.
- **SC-002**: At least 90% of test users can cancel an edit without changing the original menu in under 15 seconds.
- **SC-003**: In verification tests, editing one meal menu entry does not change any other entry in the same section.
- **SC-004**: In verification tests, the edited menu remains updated after leaving and returning to the same day.
- **SC-005**: In verification tests, empty or whitespace-only edits do not replace an existing menu entry.

## Assumptions

- The pen icon is shown next to each saved meal menu entry and opens the edit flow for that entry only.
- Editing uses the same general entry workflow as adding a menu, with the current text already filled in.
- The feature scope is limited to updating existing meal menu entries on the item add screen.
- Deleting meal menu entries is handled by a separate feature.
- Meal menu edits are stored within the existing selected-day and section-based weekly data model.
