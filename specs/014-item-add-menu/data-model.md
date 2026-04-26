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

## Relationships
- 1 つの週日付に対して、朝・昼・夜のメニューを関連付ける。
- 1 つの区分に複数のメニューを関連付ける。

## Validation rules
- メニュー本文は空白のみでは保存しない。
- 同じ日と同じ区分に対する複数メニューは、追加順に保持する。
- 購入リスト画面には表示しない。
- 週をまたいだ同じ曜日でも別のメニューとして扱う。

## State transitions
- Daily Meal Menu: absent -> created -> updated -> cleared
- Meal Menu Entry: absent -> created -> removed

## Notes
- 料理メニューは商品登録画面の補助情報として扱う。
- 空の区分は画面上で非表示にする。
