# Feature Specification: 商品追加画面の購入済み商品表示

**Feature Branch**: `026-keep-purchased-visible`  
**Created**: 2026-05-18  
**Status**: Draft  
**Input**: User description: "商品追加画面の商品は、購入済みになっても非表示にしない。購入済みの場合は、商品、数量の文字の色を購入済みを示す色に変更する。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 購入済み商品を一覧に残して見分けられるようにする (Priority: P1)

買い物をする人として、商品追加画面で購入済みになった商品もその場に残り、買い物中に状態を見失わずに確認したい。

**Why this priority**: 購入済み商品が一覧から消えると、何を買ったか把握しづらくなり、買い物の進行確認に支障が出るため。

**Independent Test**: 商品を購入済みに切り替えたあとでも商品追加画面から消えず、同じ場所で状態を確認できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加画面に未購入の商品が表示されている状態, **When** ユーザーがその商品を購入済みに切り替える, **Then** その商品は一覧から消えずに表示されたままになる
2. **Given** 購入済みの商品がある状態, **When** ユーザーが商品追加画面を見続ける, **Then** その商品は同じ画面内に残り続ける
3. **Given** 購入済みの商品が複数ある状態, **When** ユーザーが買い物リストを確認する, **Then** 購入済みの商品と未購入の商品を同じ画面で見分けられる

---

### User Story 2 - 購入済み商品の見た目を変える (Priority: P1)

買い物をする人として、購入済みの商品をひと目で分かるようにして、未購入の商品と区別したい。

**Why this priority**: 表示が区別できないと、一覧に残っていても状態を見誤り、買い忘れや二重購入につながるため。

**Independent Test**: 商品を購入済みに切り替えたあと、商品名と数量の文字色が購入済みを示す色に変わることを確認できる。

**Acceptance Scenarios**:

1. **Given** 未購入の商品が表示されている状態, **When** ユーザーがその商品を購入済みに切り替える, **Then** 商品名と数量の文字色が購入済みを示す色に変わる
2. **Given** 購入済みの商品が表示されている状態, **When** ユーザーが画面を切り替えたり戻ったりする, **Then** 購入済みを示す文字色が維持される
3. **Given** 未購入の商品が表示されている状態, **When** ユーザーが一覧を見る, **Then** 未購入の商品は従来の表示色のままになる

---

### Edge Cases

- 購入済みの商品が 1 件だけでも、一覧から消えずに表示される。
- 複数の商品を購入済みにしても、購入済みの商品と未購入の商品が混在したまま区別できる。
- 前の週を表示している状態では、既存の表示制御をそのまま維持する。
- 購入済みの見た目変更は商品名と数量の両方に適用される。
- 購入済み表示の変更後も、商品を元に戻した場合は未購入の見た目に戻る。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST keep purchased items visible on the item add screen instead of hiding them from the list.
- **FR-002**: System MUST display purchased items in a distinct visual style that makes them clearly different from unpurchased items.
- **FR-003**: System MUST apply the purchased-item visual style to both the item name and quantity text.
- **FR-004**: System MUST keep unpurchased items in the existing normal visual style.
- **FR-005**: System MUST preserve the purchased-item visual style when the screen is refreshed or revisited for the same day.
- **FR-006**: System MUST restore the normal visual style when a purchased item is returned to an unpurchased state.

### Key Entities *(include if feature involves data)*

- **Shopping Item Entry**: A shopping-list item with purchase state, name, quantity, and section information.
- **Purchased State**: Whether an item has been marked as purchased.
- **Purchased Visual Style**: The color treatment applied to purchased item name and quantity text.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In verification tests, purchased items remain visible in the item add screen after being marked purchased.
- **SC-002**: In verification tests, both the item name and quantity text change to the purchased-item color for every purchased item.
- **SC-003**: In verification tests, unpurchased items keep the normal text color.
- **SC-004**: In user validation, at least 90% of participants can identify purchased items without relying on memory of removed rows.
- **SC-005**: In user validation, at least 90% of participants can correctly tell purchased items apart from unpurchased items on the same screen.

## Assumptions

- The purchased-item color uses the existing app theme's purchased/secondary emphasis color.
- The change applies only to the item add screen and does not alter purchase-list behavior.
- No new persistence fields are required because purchased state already exists.
- Purchased items remain interactive according to the current screen behavior unless explicitly changed in a later feature.
