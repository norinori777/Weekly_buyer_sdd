# Data Model: 初期カテゴリとひらがな名の投入

## Existing entities used as-is

### Categories
- `id`
- `name`
- `sortOrder`
- `isActive`

### Item Masters
- `id`
- `name`
- `hiragana`
- `categoryId`
- `defaultQuantity`
- `isActive`

## New or refined entities

### Initial Category Seed
- カテゴリ名と表示順を持つ初期投入対象。
- 例: 野菜、果物、肉、魚介。

### Seeded Item Master
- 初期カテゴリに属する商品候補。
- 表示名とひらがな名を持つ。

### Seed Catalog Definition
- 初期カテゴリと seed 商品候補の一覧。
- 起動時に既存データと比較して不足分を補う基準になる。

## Relationships

- Initial Category Seed は 1 つの Categories レコードに対応する。
- Seeded Item Master は 1 つの Categories レコードに属する。
- Seed Catalog Definition はカテゴリ順序とカテゴリ配下の item master 群をまとめて定義する。
- 既存の Categories / Item Masters は seed 定義と照合して不足分のみ補完する。

## Validation rules

- seed 商品候補は name と hiragana の両方を持つ。
- seed 対象のカテゴリが既にある場合は重複作成しない。
- seed 対象の商品候補が既にある場合は重複作成しない。
- 既存レコードのうち seed と一致するものは、必要な場合のみひらがなを補完する。

## Notes

- 新しいテーブルやカラムは不要。
- ひらがな名は既存の item_masters.hiragana を使用する。
