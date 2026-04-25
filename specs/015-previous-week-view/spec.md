# Feature Specification: 前週参照表示

**Feature Branch**: `015-previous-week-view`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "商品追加画面ですが、以前の週の情報も参照できるようにしてください。そのため、前の週を表示できるようにしてください。目的としては、以下の2点となります。 - 次週の買い物をするアプリのため、次週が初期表示になっていますが、その次週になった場合、何の料理を作成するか、前の週の購入内容から確認するためです。 - ２週間前や３週間前など確認して、何を食べていたか確認し、次週の買い物の参考にするためです。また、前の週では、商品追加や料理メニュー追加はできなくてよくて、表示のみでお願いします。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 過去週を表示して購入内容を参照する (Priority: P1)

買い物をする人として、商品追加画面から前の週やさらに過去の週を表示し、何を買っていたか、何を作っていたかを見返したい。

**Why this priority**: 翌週の買い物を準備するうえで、直前の週だけでなく数週間前までさかのぼって確認できることが、献立や買い物内容の参考として最も重要だからです。

**Independent Test**: 商品追加画面を開き、前の週に切り替えて過去週の購入内容や料理メニューが表示されることを確認できる。さらに、2週間前・3週間前へも順に切り替えられることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加画面で次週が初期表示されている状態, **When** ユーザーが前の週へ切り替える, **Then** 直前の週の購入内容と料理メニューが表示される
2. **Given** 前の週が表示されている状態, **When** ユーザーがさらに前の週へ切り替える, **Then** 2週間前の内容が表示される
3. **Given** 2週間前が表示されている状態, **When** ユーザーがさらに前の週へ切り替える, **Then** 3週間前の内容が表示される

---

### User Story 2 - 過去週では読み取り専用で参照する (Priority: P1)

買い物をする人として、過去週を見返すときは、誤って内容を変えないように表示だけを行いたい。

**Why this priority**: 過去週の情報は参照用であり、編集できると当時の記録や比較の意味が失われるためです。

**Independent Test**: 過去週を表示した状態で、商品追加や料理メニュー追加の操作ができないことを確認できる。

**Acceptance Scenarios**:

1. **Given** 過去週が表示されている状態, **When** ユーザーが商品追加操作を行おうとする, **Then** 追加は実行されず、表示のみになる
2. **Given** 過去週が表示されている状態, **When** ユーザーが料理メニュー追加操作を行おうとする, **Then** 追加は実行されず、表示のみになる
3. **Given** 過去週が表示されている状態, **When** ユーザーが表示内容を確認する, **Then** 既存の記録は変更されない

---

### User Story 3 - 元の翌週表示へ戻る (Priority: P2)

買い物をする人として、過去週を確認したあとに、また翌週の買い物準備に戻りたい。

**Why this priority**: このアプリの主目的は翌週の買い物準備なので、過去週閲覧のあとに元の作業位置へ戻れることが必要です。

**Independent Test**: 任意の過去週を表示したあと、次週の初期表示へ戻れることを確認できる。

**Acceptance Scenarios**:

1. **Given** 過去週を表示している状態, **When** ユーザーが次週の表示へ戻る, **Then** 翌週の初期表示に切り替わる
2. **Given** 何度か週を移動した状態, **When** ユーザーが次週へ戻る操作を行う, **Then** 以後の編集対象は翌週に戻る

---

### Edge Cases

- 表示できる過去週に記録がない場合でも、画面はエラーにならず空の参照状態として表示する。
- 月末や年末をまたぐ週でも、前の週への切り替えが正しい週順で維持される。
- 3週間以上前の参照が可能な場合でも、週単位で順にさかのぼって閲覧できる。
- 過去週を表示中に、商品追加や料理メニュー追加の導線が誤って有効にならない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the product registration screen with the next week as the default active week.
- **FR-002**: System MUST allow the user to move the active view to prior weeks from the product registration screen.
- **FR-003**: System MUST allow the user to move sequentially to at least the immediately previous week, 2 weeks prior, and 3 weeks prior.
- **FR-004**: System MUST display the purchase content and meal menu content associated with the selected week when a prior week is shown.
- **FR-005**: System MUST keep prior-week views read-only and prevent item addition while a prior week is selected.
- **FR-006**: System MUST keep prior-week views read-only and prevent meal menu addition while a prior week is selected.
- **FR-007**: System MUST allow the user to return from any prior week view to the next-week default view without modifying saved data.
- **FR-008**: System MUST preserve week-to-week data isolation so that viewing one week does not change another week's contents.
- **FR-009**: System MUST display an empty but usable state when a selected prior week has no recorded content.

### Key Entities *(include if feature involves data)*

- **Week View**: A selected week shown on the product registration screen, including the current next-week view and prior-week views.
- **Week Snapshot**: The saved purchase and meal information associated with one week.
- **Read-Only Week State**: A prior-week mode in which content can be viewed but not edited or added.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can move from the default next-week view to a chosen prior week and identify the correct week in under 1 minute.
- **SC-002**: In verification tests, 100% of prior-week views block item addition and meal menu addition.
- **SC-003**: In verification tests, users can return from any prior week to the next-week default view without changing saved content in 100% of attempts.
- **SC-004**: At least 90% of test users can use prior-week views to confirm what was purchased or prepared in a chosen earlier week without guidance.

## Assumptions

- The app keeps the next week as the default working week, and past weeks are only for review.
- Historical data is available for at least three prior weeks so the user can review one, two, and three weeks back.
- No edits, adds, or deletions are allowed while a prior week is selected.
- The product registration screen remains the single place where week history is reviewed; no separate history screen is introduced in this iteration.
