# Feature Specification: 曜日別商品登録

**Feature Branch**: `006-weekday-item-registration`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "商品追加画面ですが、現状、曜日ごとに商品が登録できません。月曜日に商品を登録した場合、火曜日を表示すると月曜日で登録した商品が表示されてしまいます。仕様としては、各曜日ごとに商品を登録できるようにしてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Register items to the selected weekday (Priority: P1)

買い物をする人として、選択中の曜日ごとに商品を登録し、別の曜日に切り替えてもその曜日の登録内容だけを見たい。

**Why this priority**: 曜日ごとの登録が分離されないと、どの日に何を登録したのか分からなくなり、商品追加画面の価値が成立しないため。

**Independent Test**: 月曜日に商品を登録し、火曜日へ切り替えたときに月曜日の商品が表示されないことを確認できる。

**Acceptance Scenarios**:

1. **Given** 月曜日が選択されている状態, **When** ユーザーが商品を登録する, **Then** その商品は月曜日の登録内容として保存される
2. **Given** 月曜日に登録した商品がある状態, **When** ユーザーが火曜日へ切り替える, **Then** 月曜日の商品は火曜日の登録内容に表示されない
3. **Given** ある曜日に複数の商品が登録されている状態, **When** ユーザーが同じ曜日を再表示する, **Then** その曜日に登録した商品だけが表示される

---

### User Story 2 - Keep weekday-specific views stable while switching (Priority: P1)

買い物をする人として、曜日を切り替えながら、曜日ごとに分かれた登録内容を安心して確認したい。

**Why this priority**: 切り替えた先の曜日に別の曜日の商品が混ざると、入力や確認の信頼性が失われるため。

**Independent Test**: 曜日を切り替えながら、各曜日に表示される内容がその曜日の登録内容だけであることを確認できる。

**Acceptance Scenarios**:

1. **Given** 複数の曜日に商品が登録されている状態, **When** ユーザーが曜日を切り替える, **Then** 選択中の曜日の登録内容だけが表示される
2. **Given** ある曜日で商品を追加した状態, **When** ユーザーが別の曜日へ切り替える, **Then** 追加した商品は元の曜日にのみ残る
3. **Given** 登録内容がない曜日を表示している状態, **When** ユーザーがその曜日を開く, **Then** 空状態が分かりやすく表示される

---

### User Story 3 - Preserve weekly context across weekday registrations (Priority: P2)

買い物をする人として、同じ週の中で曜日ごとの登録を行い、週の文脈は保ったまま管理したい。

**Why this priority**: 曜日ごとの分離は必要だが、週の単位まで分断されると全体の管理が難しくなるため。

**Independent Test**: 同じ週の中で曜日を切り替え、登録内容が曜日ごとに分かれたまま維持されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 週の中で月曜日と火曜日に別の商品が登録されている状態, **When** ユーザーが曜日を切り替える, **Then** その曜日の登録内容だけが見える
2. **Given** 週の中で複数の曜日に登録がある状態, **When** ユーザーが一度別の画面を経由して戻る, **Then** 同じ週の曜日別登録内容が維持される

---

### Edge Cases

- どの曜日にも商品がない場合は、選択中の曜日について空状態を表示する。
- 同じ商品名を別の曜日に登録した場合は、曜日ごとの別登録として扱う。
- 同じ曜日に同じ商品を複数回登録した場合は、登録した回数分をその曜日に保持する。
- 曜日を切り替えた直後でも、直前に見ていた曜日の登録内容が別曜日に混ざらない。
- 選択中の曜日が未確定の場合は、当日または既定の曜日を初期表示として扱う。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST keep shopping registrations separate for each weekday within the active week.
- **FR-002**: System MUST save a new item to the currently selected weekday.
- **FR-003**: System MUST display only the items registered for the currently selected weekday.
- **FR-004**: System MUST not show items registered on other weekdays when a different weekday is selected.
- **FR-005**: System MUST preserve previously registered items for each weekday when the user switches between weekdays.
- **FR-006**: System MUST allow the user to register multiple items on the same weekday without affecting items registered on other weekdays.
- **FR-007**: System MUST show an empty state when the selected weekday has no registered items.
- **FR-008**: System MUST keep the weekly context stable while users move between weekday views.

### Key Entities *(include if feature involves data)*

- **Week**: The shared calendar week used as the overall scope for registrations.
- **Weekday Registration**: The item set associated with one weekday inside the active week.
- **Shopping Item**: A product entry with name, quantity, and weekday association.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can register an item on one weekday and verify it does not appear on a different weekday.
- **SC-002**: At least 90% of test users can switch between weekdays and confirm that each weekday shows only its own items.
- **SC-003**: At least 90% of test users can add items to two different weekdays in the same session without cross-day confusion.
- **SC-004**: At least 95% of verification runs show the same weekday registrations after switching away and back within the same week.

## Assumptions

- The app already maintains a shared weekly context across destinations.
- Weekday selection is already available in the registration screen or its surrounding flow.
- Time-of-day grouping, if present, remains inside each weekday's registration set.
- Cloud sync and collaborative editing are out of scope for this feature.