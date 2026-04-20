# Feature Specification: 曜日ボタン簡略化とスワイプ切替

**Feature Branch**: `009-weekday-button-swipe`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "商品登録画面の曜日切り替えのボタンは、日付の表示を外して、曜日のみボタンに表示してください。\n右、左にスワイプすると曜日が切り替わるようにしてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 曜日を素早く切り替えて登録内容を確認する (Priority: P1)

買い物をする人として、商品登録画面で曜日を切り替えながら、その曜日に登録する商品を確認したい。タップだけでなくスワイプでも切り替えられるようにして、片手操作でも素早く移動したい。

**Why this priority**: 曜日切替が煩雑だと登録作業が遅くなり、誤った曜日に登録するリスクも上がるため。

**Independent Test**: 商品登録画面を表示し、左右スワイプで曜日が切り替わること、切り替えた曜日の登録内容だけが表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日切替領域を左にスワイプする, **Then** 表示中の曜日が次の曜日へ切り替わる
2. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日切替領域を右にスワイプする, **Then** 表示中の曜日が前の曜日へ切り替わる
3. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日ボタンをタップする, **Then** タップした曜日へ切り替わる

---

### User Story 2 - 曜日ボタンを見やすくする (Priority: P2)

買い物をする人として、曜日切替のボタンは曜日だけが見えれば十分なので、日付表示をなくして見やすくしたい。

**Why this priority**: 曜日切替の視認性が上がると、誤操作を減らし、登録のスピードと安心感が向上するため。

**Independent Test**: 商品登録画面上部の曜日ボタンが曜日のみ表示になっていることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日切替ボタンを確認する, **Then** 各ボタンの表示は曜日のみ（例: 「月」「火」…）で日付（数値）が含まれない

---

### Edge Cases

- スワイプが短い/弱いなど、意図しない操作と判定される場合は曜日を切り替えない。
- 週の先頭（例: 月）で右スワイプした場合、週の外へは移動せず先頭のままになる。
- 週の末尾（例: 日）で左スワイプした場合、週の外へは移動せず末尾のままになる。
- 日付表示を除外しても、選択中の曜日が分かる選択状態（ハイライト等）は維持される。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST show weekday selector buttons on the product registration screen with weekday-only labels (no numeric date included in the button label).
- **FR-002**: System MUST allow users to change the selected weekday by tapping a weekday button.
- **FR-003**: System MUST allow users to change the selected weekday by swiping left/right on the weekday selector area.
- **FR-004**: System MUST keep the selected weekday within the current week bounds when users swipe at the first/last weekday.
- **FR-005**: System MUST update the displayed registration content to match the selected weekday after tap or swipe.

### Key Entities *(include if feature involves data)*

- **Week**: The calendar week context used by the product registration screen.
- **Selected Weekday**: The weekday currently selected by the user.
- **Weekday Selector Button**: A UI control representing a weekday selection option.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In acceptance testing, 100% of weekday selector buttons show weekday-only labels with no numeric characters.
- **SC-002**: At least 90% of test users can switch weekdays using swipe within 10 seconds without assistance.
- **SC-003**: At least 95% of swipe attempts that are intended as weekday changes result in the expected adjacent weekday being selected.

## Assumptions

- The product registration screen already has a concept of a week context and weekday-scoped registrations.
- The weekday selector area is present at the top of the screen and already supports button-based selection.
- This feature does not add a week picker or change which week is active; it only changes weekday switching interaction and label text.
