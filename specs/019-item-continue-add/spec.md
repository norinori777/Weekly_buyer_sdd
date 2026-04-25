# Feature Specification: 商品入力フォームの続けて追加

**Feature Branch**: `019-item-continue-add`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "商品追加画面の入力フォームで商品登録後も続けて入力できる「続けて追加」ボタンを追加する。『続けて追加』ボタンの配置場所は、商品名と数量ののTextBoxの幅を短くして、ボタンを配置する。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 連続で商品を登録する (Priority: P1)

買い物をする人として、商品を 1 件登録したあとも入力フォームを閉じずに、次の商品をすぐに続けて入力したい。

**Why this priority**: 連続入力ができないと、複数の商品をまとめて入れるたびに毎回フォームを開き直す必要があり、入力効率が下がるため。

**Independent Test**: 入力フォームで商品を登録したあとに「続けて追加」を押し、フォームが閉じずに次の商品を入力できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加フォームが開いている状態, **When** ユーザーが商品名と数量を入力して「続けて追加」を押す, **Then** 1 件目の商品が登録され、フォームは閉じずに次の商品を入力できる状態のままになる
2. **Given** 商品追加フォームが開いている状態, **When** ユーザーが商品名と数量を入力して「続けて追加」を押したあと、続けて別の商品を入力して再び「続けて追加」を押す, **Then** 2 件目も登録され、同じフォームから連続で登録できる
3. **Given** 商品追加フォームが開いている状態, **When** ユーザーが「続けて追加」を押す, **Then** 次の商品を入力しやすいように入力欄が初期状態に戻る

---

### User Story 2 - 1件だけ登録して閉じる (Priority: P1)

買い物をする人として、1件だけ登録したいときは、これまでどおり登録してフォームを閉じたい。

**Why this priority**: 連続入力を追加しても、単発登録の操作感が変わらず、必要なときにすぐ画面を閉じられることが重要なため。

**Independent Test**: 1件入力して通常の登録を押し、フォームが閉じて商品が登録されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加フォームが開いている状態, **When** ユーザーが商品名と数量を入力して通常の登録を押す, **Then** 商品が登録され、フォームは閉じる
2. **Given** 商品追加フォームが開いている状態, **When** ユーザーが通常の登録を押す, **Then** 入力した商品は登録されるが、続けて入力する状態にはならない

---

### User Story 3 - 入力しやすい配置で続けて追加する (Priority: P2)

買い物をする人として、商品名や数量を入力しながら、すぐ近くに「続けて追加」ボタンが見えていてほしい。

**Why this priority**: ボタンが見つけにくいと連続入力の価値が下がるため、入力の流れを崩さずに押せる配置が必要なため。

**Independent Test**: 入力フォームを開いて、商品名と数量の入力欄と「続けて追加」ボタンが同時に見えることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加フォームが表示されている状態, **When** ユーザーがフォームを見る, **Then** 商品名と数量の入力欄の近くに「続けて追加」ボタンが表示される
2. **Given** 商品追加フォームが表示されている状態, **When** ユーザーが入力欄を見ながら操作する, **Then** 追加ボタンが入力欄の操作を妨げずに使える

### Edge Cases

- 入力欄が空のまま「続けて追加」を押した場合は、登録せずに入力フォームをそのままにする。
- 「続けて追加」を押したあと、次の入力がしやすいように前回の入力内容は残さない。
- 通常の登録と「続けて追加」の両方がある場合でも、ユーザーはその場で使い分けられる。
- 連続で複数件を追加しても、以前の入力が誤って再登録されない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a "続けて追加" button in the item add form.
- **FR-002**: System MUST register the entered item when the user activates the "続けて追加" button.
- **FR-003**: System MUST keep the item add form open after the user activates the "続けて追加" button.
- **FR-004**: System MUST clear the current item-name and quantity inputs after a successful "続けて追加" action so the next item can be entered immediately.
- **FR-005**: System MUST continue to provide the existing single-item register action that closes the form after saving.
- **FR-006**: System MUST place the "続けて追加" button within the same input area as the item name and quantity controls so the action is visible during entry.

### Key Entities *(include if feature involves data)*

- **Pending Item Input**: The current values the user has entered before choosing how to save them.
- **Registered Item**: A saved shopping item that is added to the list when either save action is used.
- **Item Add Form**: The screen used to enter and submit new shopping items.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In verification tests, users can add at least 3 items in a row without closing the form.
- **SC-002**: In verification tests, the form remains open after a successful "続けて追加" action every time.
- **SC-003**: In verification tests, the same form can still be used for a normal single-item save that closes the form.
- **SC-004**: In user validation, at least 90% of participants can notice and use the "続けて追加" action without guidance.

## Assumptions

- "続けて追加" is intended for users who want to enter multiple shopping items in one session.
- The existing single-item register button remains available for users who want to finish immediately.
- After "続けて追加", the form should return to a clean state rather than preserving the last entered values.
- The feature applies to the existing item add screen only and does not change other parts of the app.
