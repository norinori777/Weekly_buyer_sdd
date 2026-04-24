# Feature Specification: 商品登録画面の料理メニュー入力

**Feature Branch**: `014-item-add-menu`  
**Created**: 2026-04-24  
**Status**: Draft  
**Input**: User description: "朝、昼、夜の各セクションの右上に料理メニュー追加ボタンを表示する。料理メニュー追加ボタンを押下すると、下からスライドアップする入力フォームを表示する。入力フォームには、メニューを入力するテキストボックスとキャンセルボタンと登録ボタンがある。キャンセルボタンを押下すると入力フォームが閉じる。登録ボタンを押下すると料理メニューが登録される。現在実装されている朝、昼、夜セクションにあるテキストボックスとクリアボタンと保存ボタンは、下からの入力フォームにとってかわるため、削除してください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - セクションごとにメニューを追加する (Priority: P1)

買い物をする人として、商品登録画面の朝・昼・夜それぞれのセクション右上から、その日の料理メニューをすぐに追加したい。

**Why this priority**: どのセクションにも追加できなければ、この機能の中心価値である「その日の料理メニューを整理する」ことが成立しないため。

**Independent Test**: 商品登録画面で朝・昼・夜の各セクション右上の追加ボタンを押し、対象セクションごとの入力フォームが表示され、メニューを登録できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面が表示されている状態, **When** ユーザーが朝セクション右上の料理メニュー追加ボタンを押す, **Then** 朝セクションに紐づく入力フォームが下から表示される
2. **Given** 商品登録画面が表示されている状態, **When** ユーザーが昼セクション右上の料理メニュー追加ボタンを押す, **Then** 昼セクションに紐づく入力フォームが下から表示される
3. **Given** 商品登録画面が表示されている状態, **When** ユーザーが夜セクション右上の料理メニュー追加ボタンを押す, **Then** 夜セクションに紐づく入力フォームが下から表示される
4. **Given** 入力フォームが表示されている状態, **When** ユーザーがメニューを入力して登録する, **Then** 入力したメニューが選択中のセクションに保存される

---

### User Story 2 - 入力を取り消して閉じる (Priority: P1)

買い物をする人として、追加操作の途中で入力をやめたいときに、キャンセルして画面を閉じたい。

**Why this priority**: 登録前に閉じられないと、誤入力や途中離脱の操作ができず、入力体験が不安定になるため。

**Independent Test**: 入力フォームを開き、メニューを入力した状態でもキャンセルボタンを押してフォームが閉じることを確認できる。

**Acceptance Scenarios**:

1. **Given** 入力フォームが表示されている状態, **When** ユーザーがキャンセルボタンを押す, **Then** 入力フォームが閉じる
2. **Given** 入力フォームが表示されている状態, **When** ユーザーが何も入力せずにキャンセルボタンを押す, **Then** 料理メニューは保存されない
3. **Given** 入力フォームが表示されている状態, **When** ユーザーが内容を入力したままキャンセルボタンを押す, **Then** 入力内容は保存されずに閉じる

---

### User Story 3 - 保存したメニューを日別に維持する (Priority: P2)

買い物をする人として、同じ日付の朝・昼・夜ごとに入力した料理メニューを見失わず、別の日と混ざらないようにしたい。

**Why this priority**: 日別の文脈が崩れると、どの日の料理メニューなのか分からなくなり、買い物の補助情報として使えなくなるため。

**Independent Test**: ある日に朝・昼・夜のメニューを登録し、別の日に切り替えたあと元の日に戻って、同じ内容が維持されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** ある日に朝のメニューが保存されている状態, **When** ユーザーが別の日に切り替える, **Then** 元の日の朝メニューは別の日に上書きされない
2. **Given** ある日に昼または夜のメニューが保存されている状態, **When** ユーザーが元の日に戻る, **Then** 同じメニューが再表示される
3. **Given** 料理メニューが保存されている状態, **When** ユーザーが購入リスト画面を開く, **Then** 料理メニューは表示されない

---

### Edge Cases

- 入力欄が空のまま登録しようとした場合は、新しい料理メニューとして保存しない。
- 1つの区分に複数の料理メニューを登録できる。
- 同じ文字列の料理メニューを複数回登録した場合は、別々の登録として扱う。
- 朝・昼・夜のセクション内にある従来のテキストボックス、クリアボタン、保存ボタンは表示しない。
- どの区分にもメニューがない場合は、空のセクションを目立たせず、画面上で整理して表示する。
- 日付を切り替えても、前の日のメニューが別の日に混ざらない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a meal-menu add button at the upper right of each morning, lunch, and dinner section.
- **FR-002**: System MUST open a slide-up input form from the bottom when the corresponding add button is activated.
- **FR-003**: System MUST provide a text field, a cancel button, and a register button within the input form.
- **FR-004**: System MUST remove the inline section text fields, clear buttons, and save buttons from the morning, lunch, and dinner sections.
- **FR-005**: System MUST close the input form without saving when the cancel button is activated.
- **FR-006**: System MUST save the entered meal menu to the selected day and the section that opened the form when the register button is activated.
- **FR-007**: System MUST allow multiple meal-menu entries to be saved for the same section on the same day.
- **FR-008**: System MUST display saved meal-menu entries under the matching section heading for the selected day.
- **FR-009**: System MUST keep each day's meal-menu entries isolated within the active week.
- **FR-010**: System MUST not display meal-menu entries on the purchase list screen.
- **FR-011**: System MUST prevent empty or whitespace-only meal menus from being saved.

### Key Entities *(include if feature involves data)*

- **Daily Meal Menu**: One day's collection of meal-menu entries within the active week.
- **Meal Menu Entry**: A single saved menu item belonging to one section such as morning, lunch, or dinner.
- **Meal Section**: A day section used to group menus by morning, lunch, and dinner.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can open the correct section's add form and register a menu in under 1 minute without guidance.
- **SC-002**: At least 90% of test users can open the form and cancel without saving in under 15 seconds.
- **SC-003**: At least 90% of test users can switch to another day and confirm the saved menus remain separated by day.
- **SC-004**: In verification tests, each of the three sections can retain multiple saved menus at the same time.
- **SC-005**: In verification tests, meal-menu content appears only on the item registration screen and never on the purchase list screen.

## Assumptions

- The add button always opens the form for the section that the user tapped.
- The meal-menu entry is plain text entered manually by the user.
- Multiple meal-menu entries per section are allowed for the same day.
- Meal-menu data is stored locally and follows the existing selected-day and active-week flow.
- Editing or deleting existing meal-menu entries is out of scope for this specification unless added in a later change.
