# Feature Specification: 商品登録画面の料理メニュー入力

**Feature Branch**: `014-item-add-menu`  
**Created**: 2026-04-24  
**Status**: Draft  
**Input**: User description: "- 目的: 商品登録画面で、その日の料理メニューを朝・昼・夜ごとに入力できるようにする。  
- 表示位置: 入力したメニューは、同じ日の朝・昼・夜のセクションの見出しに表示する。  
- 単位: 1日 × 3区分で管理する。朝、昼、夜それぞれに複数件持てる前提とする。  
- 役割分担: 商品は買い物リストの本体、料理メニューはその日の文脈情報、と分けて書く。
- 動作：追加した料理メニューは、✖ボタンが左横にあり、✖ボタンをクリックするとクリアできる。  

ユーザーストーリーは、最低でも次の3本に分けると整理しやすいです。  
- 朝・昼・夜ごとに料理メニューを入力したい  
- 入力したメニューを同じセクション内で確認したい  
- 日や週を切り替えても、各日のメニューが混ざらないようにしたい  

仕様をさらに明確にするん。  
- 1つの区分に複数メニューを入れられる  
- メニューは自由入力で候補がしたに表示され、候補を選ぶことも可能  
- 朝昼夜のメニューは見出内に表示  
- 空欄のときは非表示  
- メニューは購入リスト画面表示しない"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 朝昼夜ごとに料理メニューを入力する (Priority: P1)

買い物をする人として、商品登録画面の朝・昼・夜の各セクションに、その日の料理メニューを自由に入力したい。

**Why this priority**: メニューを入力できなければ、商品登録画面で料理の流れを整理する目的が成立しないため。

**Independent Test**: 商品登録画面を開き、朝・昼・夜の各セクションに複数の料理メニューを入力して、保存後に同じ見出しの下へ表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** ある日が選択されている状態, **When** ユーザーが朝の料理メニューを入力して保存する, **Then** その日の朝セクションの見出しの下に表示される
2. **Given** ある日が選択されている状態, **When** ユーザーが昼の料理メニューを入力して保存する, **Then** その日の昼セクションの見出しの下に表示される
3. **Given** ある日が選択されている状態, **When** ユーザーが夜の料理メニューを入力して保存する, **Then** その日の夜セクションの見出しの下に表示される
4. **Given** 同じ区分に複数の料理メニューがある状態, **When** ユーザーが新しい料理メニューを追加する, **Then** 既存の料理メニューは残ったまま新しい料理メニューが追加される

---

### User Story 2 - 候補から素早く選んで、✖で消せるようにする (Priority: P1)

買い物をする人として、自由入力の下に表示される候補から料理メニューを素早く選び、不要になったメニューは✖ボタンで消したい。

**Why this priority**: 候補選択と個別クリアができないと、入力の手間が減らず、画面の整理もしづらいため。

**Independent Test**: 料理メニュー入力欄の下に候補が表示され、候補を選んで登録でき、登録済みメニューの左横の✖ボタンで個別に消せることを確認できる。

**Acceptance Scenarios**:

1. **Given** 料理メニューの入力欄が表示されている状態, **When** ユーザーが文字を入力する, **Then** 候補が入力欄の下に表示される
2. **Given** 候補が表示されている状態, **When** ユーザーが候補を選ぶ, **Then** 選んだ料理メニューをその日の該当セクションに追加できる
3. **Given** 登録済みの料理メニューがある状態, **When** ユーザーが左横の✖ボタンを押す, **Then** その料理メニューだけが消える
4. **Given** セクション内の料理メニューがすべて消えた状態, **When** 画面を表示し直す, **Then** 空のセクションは表示されない

---

### User Story 3 - 日ごとのメニューを維持して切り替える (Priority: P2)

買い物をする人として、日や週を切り替えても、その日の料理メニューが混ざらず、購入リスト画面にも表示されないようにしたい。

**Why this priority**: 日ごとの文脈が崩れると、どの日の料理メニューなのか分からなくなり、買い物の補助情報として使えなくなるため。

**Independent Test**: ある日に料理メニューを保存し、別の日に切り替えたあと元の日に戻って同じ内容が維持されること、購入リスト画面に料理メニューが表示されないことを確認できる。

**Acceptance Scenarios**:

1. **Given** ある日に料理メニューが保存されている状態, **When** ユーザーが別の日に切り替える, **Then** 元の日の料理メニューは上書きされない
2. **Given** ある日に料理メニューが保存されている状態, **When** ユーザーが元の日に戻る, **Then** 同じ料理メニューが再表示される
3. **Given** 料理メニューが保存されている状態, **When** ユーザーが購入リスト画面を開く, **Then** 料理メニューは表示されない
4. **Given** 朝・昼・夜のどの区分にも料理メニューがない状態, **When** ユーザーが商品登録画面を表示する, **Then** メニュー領域は空状態として扱われる

---

### Edge Cases

- 同じ料理メニュー名を複数回入力した場合は、別の候補として個別に扱う。
- 空欄のまま保存しようとした場合は、新しい料理メニューとして追加しない。
- 候補が 0 件のときは、自由入力のみで操作を完結できる。
- 1つの区分に複数メニューがある場合でも、見出しの下で一覧として読みやすく表示する。
- ✖ボタンで最後の1件を消した区分は、空状態として見出しだけを残すか非表示にするかを統一して扱う。
- 週をまたいだ同じ曜日でも、料理メニューは週ごとに分離して扱う。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display meal-menu entry areas under the morning, lunch, and dinner section headings on the item registration screen.
- **FR-002**: System MUST allow users to enter free-form meal-menu text for the selected day and meal section.
- **FR-003**: System MUST allow users to add multiple meal-menu entries to the same meal section for the same day.
- **FR-004**: System MUST show selectable candidate suggestions below the meal-menu input field.
- **FR-005**: System MUST allow users to choose a candidate suggestion to add a meal-menu entry for the selected day and section.
- **FR-006**: System MUST display saved meal-menu entries under the matching meal section heading for the selected day.
- **FR-007**: System MUST show a clear control to the left of each saved meal-menu entry and remove that entry when activated.
- **FR-008**: System MUST keep each day's meal-menu entries isolated within the active week.
- **FR-009**: System MUST not display private meal-menu entries on the purchase list screen.
- **FR-010**: System MUST hide empty meal sections when no entries are present for that section and day.

### Key Entities *(include if feature involves data)*

- **Daily Meal Menu**: The set of meal-menu entries for one day within the active week.
- **Meal Menu Entry**: One free-form menu item belonging to a specific meal section such as morning, lunch, or dinner.
- **Meal Section**: A display grouping used to organize menu entries under the corresponding section heading.
- **Menu Suggestion**: A selectable candidate shown beneath the input field to help users add a meal-menu entry quickly.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can add a meal-menu entry to the correct section in under 1 minute without guidance.
- **SC-002**: At least 90% of test users can select a suggested candidate and clear a saved entry with ✖ in under 30 seconds.
- **SC-003**: At least 90% of test users can return to the same day after switching days and confirm the same meal-menu entries are still shown.
- **SC-004**: In verification tests, at least three meal-menu entries can be kept under the same meal section at once without replacing previous entries.
- **SC-005**: In verification tests, meal-menu content appears only in the item registration screen and never in the purchase list screen.

## Assumptions

- The menu suggestion list is a local candidate list shown beneath the input field and can be selected to populate a new menu entry.
- Each day can store multiple meal-menu entries per section, and the same text may appear more than once if the user enters it separately.
- Empty meal sections are hidden rather than labeled as empty to keep the screen focused.
- Meal-menu entries are private day-context information and are not shared with the purchase list view.
- The feature reuses the existing active-week and day-selection flow already present in the app.
