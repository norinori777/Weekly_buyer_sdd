# Data Model: 商品追加画面の料理メニュー編集

## Existing entities used as-is

### Meal Menu Entry
- `id`
- `dailyMealMenuId`
- `mealSection`
- `menuText`
- `sortOrder`
- `createdAt`
- `updatedAt`

### Meal Menu Day Snapshot
- 選択中の日付に対する料理メニュー一覧と候補。

### Meal Menu Section Entries
- 朝・昼・夜などの区分ごとの料理メニュー一覧。

## New or refined UI state

### Meal Menu Edit Target
- 編集対象の `Meal Menu Entry` を指す一時状態。
- `entryId`
- `section`
- `initialText`
- `isSaving`

### Meal Menu Edit Sheet State
- 編集シートの入力値と保存中状態。
- `currentText`
- `submitLabel`
- `isEditMode`

## Relationships

- 編集対象は 1 件の `Meal Menu Entry` に限定される。
- 編集後も `dailyMealMenuId` と `mealSection` は変わらない。
- 編集後の一覧は、同じ日付・同じ区分のスナップショットとして再取得される。

## Validation rules

- 入力は trim 後に空であってはならない。
- 空欄または空白だけの編集は既存値を上書きしない。
- 編集は対象の 1 件だけに作用し、他のメニューに影響しない。
- read-only 週表示では編集状態を開始しない。

## State transitions

- Idle -> Editing Open: ペンアイコンを押す。
- Editing Open -> Saving: 保存ボタンを押す。
- Saving -> Idle: 更新完了後にシートを閉じる。
- Editing Open -> Idle: キャンセルで閉じる。

## Notes

- 新しい永続化テーブルやカラムは不要。
- 変更点は UI の導線と repository の update 処理に集約する。
