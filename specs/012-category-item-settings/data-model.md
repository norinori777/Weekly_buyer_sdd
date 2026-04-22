# Data Model: Category and Item Settings

## Existing entities used as-is

### Category
- `id`
- `name`
- `sort_order`

### Item master
- `id`
- `category_id`
- `name`
- 既存の付随カラムはそのまま利用するが、今回の設定 UI では数量入力を扱わない。

### Weekly list / weekly list item
- 週単位の買い物リストと、その明細を現在の仕組みのまま利用する。
- 商品削除可否の判断に、現在の購入週に紐づく明細を参照する。

## Relationships
- 1 カテゴリは複数の商品を持つ。
- 1 商品は現在の購入週の明細に複数回現れうるが、削除時は現在の週の参照有無を確認する。

## Validation rules
- カテゴリ名は必須。
- 商品名は必須。
- カテゴリ削除は関連商品が 0 件であること。
- 商品削除は現在の購入週に参照がないこと。

## State transitions
- Category: created -> updated -> deleted
- Item: created -> updated -> deleted
- Deleted actions are blocked when validation rules fail.

## Notes
- スキーマ変更は行わないため、モデル定義は既存の Drift テーブルに合わせて扱う。
- UI の削除可否は、リポジトリの結果に合わせて表示する。
