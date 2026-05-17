# Feature Specification: 未分類商品の商品マスター登録

**Feature Branch**: `024-uncategorized-item-master`  
**Created**: 2026-05-17  
**Status**: Draft  
**Input**: User description: "購入リスト画面でカテゴリーが未分類のものについては、長押しするとカテゴリーを選択の上、商品マスターに登録できるようにする。"

## Clarifications

### Session 2026-05-17

- Q: ひらがなはどう扱いますか？ → A: 登録フローでひらがな入力欄を必須にする
- Q: 未分類の商品を商品マスターに登録後、購入リストの表示はどうする？ → A: 購入リストの該当 item も登録したカテゴリに更新し、同じ画面内でカテゴリ別に表示し直す

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 未分類の商品を商品マスターに登録する (Priority: P1)

買い物をする人として、購入リスト画面で未分類の商品の長押しからカテゴリを選び、その商品を次回以降も使える商品マスターとして登録したい。

**Why this priority**: 未分類のままでは商品を再利用しにくく、買い物中に同じ入力を繰り返す手間が減らないため。

**Independent Test**: 購入リスト画面で未分類の商品を長押しし、カテゴリを選んで登録すると、その商品が商品マスターとして保存され、以後の候補として再利用できることを確認できる。

**Acceptance Scenarios**:

1. **Given** 購入リスト画面に未分類の商品が表示されている状態, **When** ユーザーがその商品を長押しする, **Then** カテゴリを選んで登録するための操作が表示される
2. **Given** 未分類商品の登録操作が表示されている状態, **When** ユーザーがカテゴリとひらがなを入力して登録する, **Then** その商品は選択したカテゴリとひらがな付きで商品マスターに登録される
3. **Given** 未分類商品の登録操作が表示されている状態, **When** ユーザーが登録を完了する, **Then** 購入リストの該当 item も選択したカテゴリに更新され、そのカテゴリ別の表示に移動する
4. **Given** 商品マスターに登録された商品がある状態, **When** ユーザーが次回の商品追加の候補を開く, **Then** その商品を再利用できる

---

### User Story 2 - 対象外の商品を誤って登録しない (Priority: P2)

買い物をする人として、すでにカテゴリが付いている商品に対しては、未分類商品の登録操作を出さず、誤って別の商品として登録したくない。

**Why this priority**: 対象外の項目まで登録対象にすると、既存の分類や候補管理が崩れてしまうため。

**Independent Test**: すでにカテゴリが付いている商品を長押ししても、未分類商品の登録操作が出ないことを確認できる。

**Acceptance Scenarios**:

1. **Given** カテゴリが付いている商品が表示されている状態, **When** ユーザーがその商品を長押しする, **Then** 未分類商品の登録操作は表示されない
2. **Given** 未分類商品の登録操作を開いた状態, **When** ユーザーがキャンセルする, **Then** 商品マスターは登録されず画面は閉じる

### Edge Cases

- 未分類の商品が1件もない場合は、長押しによる登録導線を表示しない。
- カテゴリが1件もない場合は、登録前にカテゴリを選べないため、登録を開始できない状態を分かりやすく示す。
- 同じ名前の未分類商品が複数ある場合は、各項目を個別の対象として扱う。
- 登録対象の商品がすでに商品マスターにある場合でも、ユーザーが結果を見失わないように登録後の状態を明確に示す。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST show a long-press registration action for purchase-list items that are currently uncategorized.
- **FR-002**: System MUST require hiragana input before registering an uncategorized purchase-list item as a product master entry.
- **FR-003**: System MUST allow the user to choose a category before registering an uncategorized purchase-list item as a product master entry.
- **FR-004**: System MUST save the entered hiragana and selected category together with the registered product master entry.
- **FR-005**: System MUST update the corresponding purchase-list item to the selected category after the registration completes.
- **FR-006**: System MUST make the registered product master entry available for future reuse after registration.
- **FR-007**: System MUST not show the uncategorized registration action for items that already have a category.
- **FR-008**: System MUST cancel the registration flow without saving when the user dismisses the registration action.
- **FR-009**: System MUST not allow registration when no category can be selected.

### Key Entities *(include if feature involves data)*

- **Uncategorized Purchase Item**: A purchase-list item whose category is not assigned yet and is eligible for registration.
- **Product Master Entry**: A reusable item definition created from an uncategorized purchase item, including the item's display name, hiragana reading, and selected category.
- **Category**: The classification chosen when registering the product master entry.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can register an uncategorized purchase-list item as a product master entry with a chosen category in under 1 minute.
- **SC-002**: In verification tests, uncategorized items become available as reusable product master entries after registration.
- **SC-003**: In verification tests, categorized items do not expose the uncategorized-item registration action.
- **SC-004**: At least 90% of test users can open the registration flow and cancel without saving in under 15 seconds.

## Assumptions

- 「未分類」は、購入リスト画面でカテゴリ未設定として扱われる項目を指す。
- 登録時の商品名は、長押しした購入項目の表示名をそのまま使う。
- 登録時のひらがなは手入力で補う前提とし、空欄では登録しない。
- カテゴリ選択には既存のカテゴリ一覧を再利用する。
- 登録完了後は、購入リストの該当 item も選択したカテゴリで再表示する。
- 既存の購入リスト画面からの登録フローのみを対象とし、別画面での一括登録は対象外とする。