# Data Model: 商品追加画面のメモ自動保存と料理メニュー削除

## Existing entities used as-is

### Private Memo
- `weekStartDate`
- `weekday`
- `memoText`

### Meal Menu Entry
- `id`
- `dailyMealMenuId`
- `mealSection`
- `menuText`
- `sortOrder`

### Meal Menu Day Snapshot
- 選択中の日付に対する料理メニュー一覧と候補。

## New or refined entities

### Auto-Saved Private Memo State
- 入力中の私用メモを、そのまま保存結果へ反映する UI 状態。

### Meal Menu Delete Action
- 1 件の料理メニューエントリを削除する UI 操作。

## Relationships

- 私用メモは選択中の日付に 1 件だけ対応する。
- 料理メニュー削除は Meal Menu Entry の id に対して行う。
- 削除後は同じ日付・同じセクションの一覧を再取得して再描画する。

## Validation rules

- 私用メモは空文字なら保存対象を消す。
- 料理メニュー削除は対象の 1 件だけを消す。
- 削除しても他の料理メニューはそのまま残る。
- 画面表示は商品追加画面の文脈に従う。

## Notes

- 新しい永続化テーブルやカラムは不要。
- UI の自動保存と削除導線が主な変更点。
