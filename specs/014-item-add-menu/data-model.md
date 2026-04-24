# Data Model: 商品登録画面の料理メニュー入力

## New entities

### Daily Meal Menu
- `id`
- `week_start_date`
- `weekday`
- `created_at`
- `updated_at`

### Meal Menu Entry
- `id`
- `daily_meal_menu_id`
- `meal_section`
- `menu_text`
- `sort_order`
- `created_at`
- `updated_at`

### Menu Suggestion
- `id`
- `suggestion_text`
- `usage_count`
- `last_used_at`

## Relationships
- 1 つの週日付に対して、朝・昼・夜のメニューを関連付ける。
- 1 つの区分に複数のメニューを関連付ける。
- 候補は入力を補助するための独立した表示情報として扱う。

## Validation rules
- メニュー本文は空白のみでは保存しない。
- 同じ日と同じ区分に対する複数メニューは、追加順に保持する。
- ✖ で削除されたメニューは、その日の該当区分から除外される。
- 購入リスト画面には表示しない。
- 週をまたいだ同じ曜日でも別のメニューとして扱う。

## State transitions
- Daily Meal Menu: absent -> created -> updated -> cleared
- Meal Menu Entry: absent -> created -> removed
- Menu Suggestion: dormant -> suggested -> selected -> updated by reuse

## Notes
- 料理メニューは商品登録画面の補助情報として扱う。
- 候補表示は入力補助のためのローカル情報として管理する。
- 空の区分は画面上で非表示にする。
