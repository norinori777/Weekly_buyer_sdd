# Data Model: 商品追加画面の購入済み商品表示

## Existing entities used as-is

### Shopping Item Entry
- `id`
- `weekday`
- `section`
- `name`
- `quantity`
- `isPurchased`
- `sortOrder`
- `categoryId`
- `categoryName`
- `itemMasterId`

### Weekly Shopping Snapshot
- 選択中の日付に対する商品一覧、カテゴリ別グループ、週単位の表示データ。

## New or refined presentation state

### Purchased Item Visual State
- 購入済みかどうかに応じて変化する文字色の見た目。
- 永続化はしない。

### Visible Shopping Section Items
- `isPurchased` を含めたまま描画する商品一覧。
- 購入済みと未購入を同じ画面内で区別できる。

## Relationships

- `Shopping Item Entry` は購入済み状態を持ち、その状態に応じて見た目が変わる。
- 商品追加画面では、購入済み商品も未購入商品と同じ一覧に表示される。
- 購入済みの見た目変更は商品名と数量の両方に適用される。

## Validation rules

- 購入済み商品は一覧から除外しない。
- 未購入商品は従来の見た目を維持する。
- 購入済み状態を元に戻した場合は、未購入の見た目へ戻る。
- 前の週の read-only 表示は既存の制御を維持する。

## Notes

- 新しい永続化テーブルやカラムは不要。
- 変更の中心は snapshot の組み立てと行表示のスタイル切り替え。
