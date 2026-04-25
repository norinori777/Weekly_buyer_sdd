# Feature Specification: 「次も登録」ボタンと補足文の改善

**Feature Branch**: `020-next-register-copy`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "「続けて追加」ボタンを「次も登録」に変更。ボタン下に小さく「保存して続けて入力できます」と補足を入れる。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 連続登録の意図をすぐ理解する (Priority: P1)

買い物をする人として、連続入力のボタン名と補足が分かりやすく、押したときに何が起こるかをすぐ理解したい。

**Why this priority**: 連続入力の機能が存在していても、ラベルが分かりにくいと見つけても使われにくいため。

**Independent Test**: 商品追加フォームを開き、「次も登録」ボタンと補足文を見て、保存して次の入力に進む操作だと判断できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加フォームが表示されている状態, **When** ユーザーがフォームを見る, **Then** 連続入力用のボタンが「次も登録」と表示され、その下に小さな補足文が見える
2. **Given** 商品追加フォームが表示されている状態, **When** ユーザーが「次も登録」を見る, **Then** ボタン名だけでも保存後に次の入力へ進む操作であることが伝わる
3. **Given** 商品追加フォームが表示されている状態, **When** ユーザーが補足文を見る, **Then** ボタンを押すと保存して続けて入力できることが補足で理解できる

---

### User Story 2 - 通常の登録と区別して使う (Priority: P2)

買い物をする人として、1件だけ登録したいときと、続けて入力したいときを見た目で区別したい。

**Why this priority**: 似た操作が並ぶと迷いやすいため、文言の違いで用途をはっきり分ける必要があるため。

**Independent Test**: 商品追加フォームを開いて、通常の登録ボタンと「次も登録」ボタンの役割の違いを見分けられることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加フォームが表示されている状態, **When** ユーザーがボタンを見る, **Then** 通常登録と連続登録の違いが文言から見分けられる
2. **Given** 商品追加フォームが表示されている状態, **When** ユーザーが操作を選ぶ, **Then** 1件だけ登録するのか続けて入力するのかを迷いにくい

### Edge Cases

- 補足文が表示されても主ボタンの視認性を下げない。
- ボタン名が短くなっても、続けて入力する意味が失われない。
- 文言変更後も、既存の連続入力の使い方は変わらない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the continue-add button with the label "次も登録" in the item add form.
- **FR-002**: System MUST display a short helper text under the continue-add button stating that the item is saved and the next item can be entered immediately.
- **FR-003**: System MUST keep the continue-add action available in the same place as the existing continue-add control so users can still find the repeated-entry flow.
- **FR-004**: System MUST keep the helper text visually secondary to the button label.

### Key Entities *(include if feature involves data)*

- **Continue-Add Button**: The action users choose when they want to save and keep entering more items.
- **Helper Text**: A short supporting message that explains the effect of the continue-add action.
- **Item Add Form**: The screen where users enter new shopping items.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In usability checks, at least 90% of participants understand the continue-add button purpose without explanation.
- **SC-002**: In verification tests, the continue-add button is displayed as "次も登録" and the helper text is visible beneath it.
- **SC-003**: In user validation, fewer users confuse the continue-add action with the normal one-and-done save action.

## Assumptions

- The underlying continue-add behavior already exists and does not change.
- Only the label and helper text are updated in this feature.
- The new helper text is short enough to fit within the current add form layout.
