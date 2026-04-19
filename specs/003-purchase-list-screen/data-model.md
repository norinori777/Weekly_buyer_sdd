# Data Model: 購入リスト画面

## Core Entities

### Category

商品をカテゴリ順に整理するための分類。

- `id`: 識別子
- `name`: カテゴリ名
- `sort_order`: 表示順
- `is_active`: 利用中かどうか

### WeekList

1週間分の買い物リストを表す単位。

- `id`: 識別子
- `week_start_date`: 週の開始日
- `title`: 表示用タイトル

### WeekListItem

個々の買い物項目。

- `id`: 識別子
- `week_list_id`: 所属する週次リスト
- `item_master_id`: 元商品候補への参照
- `display_name`: 表示名
- `quantity`: 数量
- `unit`: 単位
- `category_id`: 所属カテゴリ
- `sort_order`: 表示順
- `is_purchased`: 購入済みかどうか
- `is_deleted`: 削除済みかどうか
- `purchased_at`: 購入済みにした時刻

### ItemMaster

再利用可能な商品候補。

- `id`: 識別子
- `category_id`: 既定カテゴリ
- `name`: 商品名
- `default_unit`: 既定単位
- `sort_order`: 候補内順序
- `is_favorite`: すぐ選べる候補かどうか
- `is_active`: 利用中かどうか

## Relationships

- `Category` は `WeekListItem` と `ItemMaster` の分類軸になる。
- `WeekList` は複数の `WeekListItem` を持つ。
- `ItemMaster` は複数の `WeekListItem` から参照される。

## State Transitions

### Purchase flow

1. `WeekListItem` は未購入状態で表示される。
2. 左フリックで `is_purchased=true` になる。
3. 購入済み項目は active list から外れる。
4. `元に戻す` で直近の `WeekListItem` が未購入に戻る。

### Delete flow

1. 画面下部の削除操作で対象項目の表示状態を更新する。
2. 直後に `元に戻す` で復帰できる。

## Derived Views

- **Progress**: `購入済み件数 / 総件数`
- **Active List**: `is_purchased=false` かつ `is_deleted=false` の項目
- **Empty State**: active list が 0 件の状態

## Notes

- Undo 履歴は永続化しない前提でよい。
- 進捗表示は派生値として扱い、保存対象にはしない。