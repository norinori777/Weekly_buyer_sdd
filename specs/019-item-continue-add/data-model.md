# Data Model: 商品入力フォームの続けて追加

## Existing entities used as-is

### Add Item Request
- `name`
- `quantity`
- `section`
- `itemMasterId`
- `categoryId`

### Item Add Draft
- `name`
- `quantityText`
- `section`
- `selectedCandidateId`
- `categoryId`

### Shopping Item Entry
- 既存の商品明細をそのまま利用する。

## New or refined entities

### Pending Item Input
- `name`
- `quantityText`
- `section`
- `selectedCandidateId`
- `categoryId`
- フォームで編集中の値を表す。

### Continue-Add Action Result
- `savedItem`
- `shouldKeepFormOpen`
- 連続追加後にフォームを閉じるかどうかを判定するための UI 内部表現。

## Relationships

- 1 回の入力から 1 件の商品が登録される。
- 「続けて追加」は保存後も同じフォームで次の Pending Item Input を作り直す。
- 通常登録は保存後にフォームを閉じる。

## Validation rules

- 商品名は必須。
- 数量は従来どおり数値として扱う。
- 続けて追加後は前回の入力値を残さない。
- 既存の候補選択ロジックはそのまま利用する。

## State transitions

- Pending Item Input: empty -> editing -> saved -> reset -> editing
- Item Add Form: open -> continue-add -> open -> register -> closed

## Notes

- 新しい永続化テーブルやカラムは不要。
- 状態の追加は presentation 層に限定する。
