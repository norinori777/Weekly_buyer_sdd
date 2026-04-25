# Feature Specification: 商品名のひらがな候補表示

**Feature Branch**: `017-item-hiragana-search`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "商品の候補を出しやすくするために、マスターテーブルの商品名に「ひらがな」の項目を追加してください。設定のカテゴリと商品で、商品を追加する場合、ひらがな名も入力する項目を追加する。商品登録画面で商品名を入れる場合、ひらがな名からも一致するものは候補に表示するようにする。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 設定で商品名の読みを登録する (Priority: P1)

商品を管理する人として、設定画面で商品を追加・編集するときに、商品名に対応するひらがなを一緒に登録したい。

**Why this priority**: ひらがな情報が登録されていなければ、登録画面での候補表示に使えず、この機能の土台が成立しないため。

**Independent Test**: 設定画面で商品を新規追加し、商品名とひらがなを入力して保存し、再度開いたときに両方の値が確認できる。

**Acceptance Scenarios**:

1. **Given** 商品の設定画面で新しい商品を追加しようとしている状態, **When** ユーザーが商品名とひらがなを入力して保存する, **Then** 両方の値が商品情報として登録される
2. **Given** 既存の商品を編集している状態, **When** ユーザーがひらがなを変更して保存する, **Then** 変更後のひらがなが保存される
3. **Given** 商品の設定画面で商品を保存しようとしている状態, **When** ユーザーがひらがなを空欄のまま保存する, **Then** 保存は完了せず、ひらがなの入力不足が示される

---

### User Story 2 - 商品名と読みの両方で候補を見つける (Priority: P1)

買い物をする人として、商品登録画面で商品名を入力するときに、正式名称だけでなくひらがな読みからも候補を見つけたい。

**Why this priority**: 入力の揺れに対応できないと、候補表示の価値が下がり、登録作業の手間が減らないため。

**Independent Test**: 商品登録画面で商品名またはひらがなを入力し、それぞれで同じ商品候補が表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面で候補を探している状態, **When** ユーザーが商品名の一部を入力する, **Then** その商品に一致する候補が表示される
2. **Given** 商品登録画面で候補を探している状態, **When** ユーザーが商品名に対応するひらがなの一部を入力する, **Then** その商品に一致する候補が表示される
3. **Given** 1つの商品が商品名とひらがなの両方で一致する状態, **When** ユーザーが候補一覧を開く, **Then** その商品は重複せず1件として表示される

---

### User Story 3 - 複数候補を同時に扱う (Priority: P2)

買い物をする人として、同じ読みや似た名前の商品が複数あるときにも、候補の一覧から見分けて選びたい。

**Why this priority**: 同音・類似商品がある現実的な入力でも、候補が正しく並ばないと誤選択につながるため。

**Independent Test**: 同じ名前または同じひらがなを持つ複数の商品を登録し、候補一覧でそれぞれが区別して表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 同じひらがなを持つ複数の商品が登録されている状態, **When** ユーザーがその読みを入力する, **Then** 該当するすべての候補が表示される
2. **Given** 商品名が似ている複数の商品が登録されている状態, **When** ユーザーが一部の文字を入力する, **Then** 一致する候補が一覧で確認できる

### Edge Cases

- ひらがなが未入力のまま保存しようとした場合は、商品を保存しない。
- ひらがなで一致する商品が複数ある場合は、すべて候補として表示する。
- 商品名とひらがなの両方で一致する場合でも、同じ商品は重複表示しない。
- 既存の商品を編集したときは、保存済みのひらがなが再表示される。
- ひらがなが登録されていない既存商品がある場合でも、商品名による候補表示は継続する。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a hiragana input field when a user creates or edits an item in the settings area.
- **FR-002**: System MUST require a hiragana value before a new item or updated item can be saved.
- **FR-003**: System MUST preserve the hiragana value so it is shown again when the item is reopened for editing.
- **FR-004**: System MUST display item suggestions on the item registration screen when the entered text matches the item name.
- **FR-005**: System MUST display item suggestions on the item registration screen when the entered text matches the hiragana reading.
- **FR-006**: System MUST show a matching item only once in the suggestion list even if both the item name and hiragana reading match.
- **FR-007**: System MUST show all matching items in the suggestion list when more than one item matches the entered text.
- **FR-008**: System MUST continue to allow item lookup by the existing item name even when a hiragana reading has not yet been added to older items.

### Key Entities *(include if feature involves data)*

- **Item Master**: A reusable item definition with a display name, a hiragana reading, and category membership.
- **Suggestion Candidate**: An item shown to the user while searching on the item registration screen.
- **Category**: A grouping used to organize item masters in settings.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In verification tests, 100% of newly created or edited items can be saved only after a hiragana reading is provided.
- **SC-002**: In verification tests, a known item can be found by entering either its item name or its hiragana reading in at least 95% of attempts.
- **SC-003**: In verification tests, items that match by both fields appear only once in the candidate list every time.
- **SC-004**: In user validation, at least 90% of participants can register an item with its hiragana reading in under 1 minute without assistance.

## Assumptions

- The hiragana reading is a user-facing lookup aid for items, not a separate item type.
- Existing items that do not yet have a hiragana reading may continue to be used until they are edited.
- If multiple items share the same name or reading, all valid matches are shown rather than choosing one automatically.
- Category management itself does not gain new fields; only item management is expanded with the hiragana reading.
