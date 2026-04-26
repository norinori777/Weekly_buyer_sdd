# Feature Specification: 商品登録画面

**Feature Branch**: `005-item-add-screen`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "商品登録画面が正しくないです。上部に今週の曜日タブを表示し、月〜日とその他を切り替えられるようにする。画面構成は上部の曜日切替、朝昼夜のセクション、下部の追加操作に分ける。商品を追加ボタンをタップすると下からスライドアップする入力フォームを表示し、商品名、数量、朝・昼・夜区分を入力して登録できるようにする。登録されると朝昼夜のセクションに登録した商品が追加表示される。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch the active weekday context (Priority: P1)

買い物をする人として、商品登録画面で今週の曜日を切り替えながら、その日に登録する商品の内容を確認したい。

**Why this priority**: 曜日切り替えが正しくできないと、どの日に何を登録するかが分からなくなるため。

**Independent Test**: 商品登録画面を開き、月〜日とその他の曜日タブを切り替えて、表示中の曜日が変わることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日タブの「水」を選ぶ, **Then** 水曜日の登録内容が表示される
2. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日タブの「その他」を選ぶ, **Then** その他の登録内容が表示される
3. **Given** 今週の曜日が選択されている状態, **When** ユーザーが別の曜日に切り替える, **Then** その曜日に紐づく登録内容へ切り替わる
4. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日切り替え領域を左右にフリックする, **Then** 表示中の曜日が前後の曜日へ切り替わる

---

### User Story 2 - Add items through a bottom sheet (Priority: P1)

買い物をする人として、画面下部の商品を追加ボタンから入力フォームを開き、商品名、数量、朝・昼・夜区分を入力して登録したい。

**Why this priority**: 入力導線が最短でないと、商品追加のたびに画面遷移が増えて使いにくくなるため。

**Independent Test**: 商品を追加ボタンを押してボトムシートが開き、商品名・数量・区分を入力して登録できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面を表示している状態, **When** ユーザーが商品を追加ボタンをタップする, **Then** 下からスライドアップする入力フォームが表示される
2. **Given** 入力フォームが表示されている状態, **When** ユーザーが商品名、数量、朝・昼・夜区分を入力する, **Then** 登録前の内容がフォームに保持される
3. **Given** 入力フォームが表示されている状態, **When** ユーザーが登録ボタンを押す, **Then** 入力内容が商品登録画面に保存される

---

### User Story 3 - Show newly added items in the selected section (Priority: P2)

買い物をする人として、登録した商品が朝・昼・夜の該当セクションにすぐ表示され、追加した内容を見直したい。

**Why this priority**: 登録結果が画面に反映されないと、追加操作の手応えがなく、入力ミスにも気づきにくいため。

**Independent Test**: ある区分に商品を登録し、その商品が該当セクションに追加表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 朝のセクションを表示している状態, **When** ユーザーが朝区分の商品を登録する, **Then** 朝のセクションに商品が追加表示される
2. **Given** 昼のセクションを表示している状態, **When** ユーザーが昼区分の商品を登録する, **Then** 昼のセクションに商品が追加表示される
3. **Given** 夜のセクションを表示している状態, **When** ユーザーが夜区分の商品を登録する, **Then** 夜のセクションに商品が追加表示される

---

### Edge Cases

- 商品名が空欄のままでは登録できない。
- 数量が未入力または不正な場合は、既定値または分かりやすいエラーで扱う。
- すべての曜日タブで登録内容が空の場合は、空状態を表示する。
- 同じ商品が複数回登録された場合は、追加した回数分だけ表示する。
- 商品追加フォームを閉じた場合は、未登録の入力内容を不用意に失わないようにする。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a week-based weekday selector on the item registration screen, including Monday through Sunday and Other.
- **FR-002**: System MUST highlight the currently selected weekday on the item registration screen.
- **FR-003**: System MUST allow users to switch the displayed registration content by selecting a different weekday tab or swiping left or right on the weekday selector.
- **FR-004**: System MUST divide the item registration screen into a weekday selector, morning/afternoon/evening sections, and a bottom add action.
- **FR-005**: System MUST open a bottom-sheet input form when the user taps the add action.
- **FR-006**: System MUST allow users to enter item name, quantity, and time-of-day section in the input form.
- **FR-007**: System MUST save a new item into the selected weekday and section when the user submits the form.
- **FR-008**: System MUST display newly added items in the matching morning, afternoon, or evening section after save.
- **FR-009**: System MUST keep the registration screen aligned with the selected week while users continue adding items in the same session.

### Key Entities *(include if feature involves data)*

- **Weekday Context**: The currently selected day within the active week, including Monday through Sunday and Other.
- **Registration Section**: The morning, afternoon, or evening group used to place items on the registration screen.
- **Draft Item**: The in-progress item entry containing name, quantity, and selected section.
- **Registered Item**: A saved item displayed under the matching section for the selected weekday.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can switch between weekday tabs and recognize the selected day without guidance.
- **SC-002**: At least 90% of test users can open the item add form from the bottom action in two actions or fewer.
- **SC-003**: At least 90% of test users can enter a name, quantity, and section and submit a new item successfully.
- **SC-004**: At least 90% of test users can verify that a newly added item appears in the correct section immediately after save.
- **SC-005**: The selected weekday remains stable while the user adds multiple items in one session.

## Assumptions

- The active week is already shared with the purchase list screen.
- Other is part of the weekday selector, but time-of-day sections remain morning, afternoon, and evening for item placement.
- Local storage persists the new item after app restart.
- Cloud sync and collaborative editing are out of scope for this feature.