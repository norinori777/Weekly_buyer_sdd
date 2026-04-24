# Feature Specification: 商品追加画面メモ

**Feature Branch**: `013-item-add-memo`  
**Created**: 2026-04-24  
**Status**: Draft  
**Input**: User description: "商品追加画面でメモ書きができるようにしてください。利用目的としては、その日のプライベート情報を入力します。自身が休みや、夫が夕飯いらないなど。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - その日の私用メモを登録する (Priority: P1)

買い物をする人として、商品追加画面でその日の私用メモを入力し、休みや夕飯不要のような情報を残したい。

**Why this priority**: その日の予定をすぐに残せないと、買い物の判断材料としてこの機能を使う意味がなくなるため。

**Independent Test**: 商品追加画面を開き、選択中の日にメモを入力して保存し、同じ日に戻ったときに内容が表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** ある日が選択されている状態, **When** ユーザーが私用メモを入力して保存する, **Then** その日のメモとして保存される
2. **Given** 保存済みの私用メモがある状態, **When** ユーザーが同じ日を再表示する, **Then** 保存済みのメモが表示される
3. **Given** 別の日が選択されている状態, **When** ユーザーが日を切り替える, **Then** その日ごとのメモ内容が個別に扱われる

---

### User Story 2 - メモを編集・削除する (Priority: P1)

買い物をする人として、予定が変わったときに私用メモを編集したり消したりしたい。

**Why this priority**: 予定変更に追従できないと、古い情報が残って誤った判断につながるため。

**Independent Test**: 既存メモを編集して保存し、変更後の内容が表示されること、または内容を消して空の状態に戻ることを確認できる。

**Acceptance Scenarios**:

1. **Given** 保存済みの私用メモがある状態, **When** ユーザーが内容を修正して保存する, **Then** その日のメモは新しい内容に更新される
2. **Given** 保存済みの私用メモがある状態, **When** ユーザーが内容をすべて削除して保存する, **Then** その日のメモは未設定の状態になる
3. **Given** メモが未入力の状態, **When** ユーザーが保存する, **Then** 空のメモが新規作成されない

---

### User Story 3 - 日ごとのメモを維持して切り替える (Priority: P2)

買い物をする人として、商品追加画面と日付の切り替えを行っても、日ごとのメモを見失わずに使いたい。

**Why this priority**: 日ごとの文脈が崩れると、どの日の私用情報なのか分からなくなるため。

**Independent Test**: ある日にメモを保存し、別の日に切り替えたあと元の日に戻って、同じメモが維持されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** ある日に私用メモが保存されている状態, **When** ユーザーが別の日に切り替える, **Then** 元の日のメモは別の日に上書きされない
2. **Given** ある日に私用メモが保存されている状態, **When** ユーザーが画面を離れて戻る, **Then** 同じ日には同じメモが再表示される
3. **Given** 私用メモがある状態, **When** ユーザーが購入リスト画面へ移動する, **Then** 私用メモは購入リスト画面に表示されない

---

### Edge Cases

- メモが空欄のまま保存された場合は、未設定として扱う。
- 1つの日に対して複数のメモを作らず、常にその日の1件のメモとして扱う。
- 文字数が多いメモでも、内容が途中で失われずに確認できる。
- 改行や記号を含むメモでも、そのまま保存して再表示できる。
- 別の日に同じ内容を入力しても、日ごとに独立したメモとして扱う。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a memo entry area on the item add screen for the currently selected day.
- **FR-002**: System MUST allow users to enter free-form private text for the selected day.
- **FR-003**: System MUST save the memo as part of the selected day within the active week.
- **FR-004**: System MUST display the saved memo again when the user returns to the same day.
- **FR-005**: System MUST allow users to edit an existing memo and clear it when the content is removed.
- **FR-006**: System MUST keep memos separate by day so that one day's memo does not replace another day's memo.
- **FR-007**: System MUST retain saved memos after the app is closed and reopened.
- **FR-008**: System MUST not show private memos on the purchase list screen.

### Key Entities *(include if feature involves data)*

- **Daily Memo**: A private note associated with one day in the active week.
- **Day Context**: The currently selected day that determines which memo is being viewed or edited.
- **Active Week**: The weekly scope that groups the per-day memo entries.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can add a private memo for the selected day in under 1 minute without guidance.
- **SC-002**: At least 90% of test users can return to the same day and confirm the memo is unchanged after switching to another day.
- **SC-003**: At least 90% of test users can edit or clear an existing memo in under 30 seconds.
- **SC-004**: In verification tests, saved memos remain available after closing and reopening the app.
- **SC-005**: In verification tests, private memo content appears only on the intended day view and never on the purchase list screen.

## Assumptions

- The memo is a single private note per day within the active week.
- The memo is plain text entered manually by the user.
- The memo is stored locally with the app's weekly data and does not require cloud sync.
- Cloud sharing, collaborative editing, and multiple memos per day are out of scope for v1.
