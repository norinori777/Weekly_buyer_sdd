# Data Model: 商品名のひらがな候補表示

## Existing entities used as-is

### Category
- `id`
- `name`
- `sort_order`

### Item master
- `id`
- `category_id`
- `name`
- `hiragana`  
- `default_quantity`
- `is_active`
- 既存の付随カラムはそのまま利用する。

### Weekly list / weekly list item
- 週単位の買い物リストと、その明細を現行の仕組みのまま利用する。
- 候補表示は item master を参照し、週次購入データは候補の表示条件には使わない。

## New or refined entities

### Item Candidate
- `id`
- `name`
- `hiragana`
- `categoryId`
- `categoryName`
- `defaultQuantity`
- 商品登録画面で候補として表示される要約情報。

### Search Match
- `itemId`
- `matchedByName`
- `matchedByHiragana`
- `displayOrder`
- 候補を 1 件にまとめるための検索結果内部表現。

## Relationships

- 1 カテゴリは複数の商品を持つ。
- 1 商品は 1 つのひらがな読みを持つか、既存データでは未設定のまま残る。
- 商品登録画面の候補は item master を元に生成し、同一商品 ID は 1 回だけ表示する。

## Validation rules

- カテゴリ名は必須。
- 商品名は必須。
- ひらがなは新規作成時と更新時に必須。
- 既存の未設定行は読み込み可能だが、編集時はひらがなを補完して保存する。
- 候補検索は商品名またはひらがなの部分一致でヒットする。

## State transitions

- Category: created -> updated -> deleted
- Item: created -> updated -> deleted
- Search Match: generated -> deduplicated -> displayed

## Notes

- スキーマ変更は Drift のマイグレーションで追加する。
- UI の入力値は settings 画面で検証し、検索画面は読み込み専用で扱う。
