# Data Model: 翌週の購入日を既定表示にする

## Purpose

この feature は永続データの構造を変えず、商品追加画面が参照する週の基準だけを翌週へ移す。したがって、中心になるのは保存モデルではなく、画面表示に使う state とその派生値である。

## Core Entities

### SelectedWeekDate

商品追加画面で現在の週として扱う基準日。

- `value`: 画面が参照している日付
- `normalizedDate`: 日時成分を落とした日付
- `role`: 週データ読み込みのキー

### WeekRange

選択された基準日から導出される 1 週間の範囲。

- `start`: 週の開始日
- `end`: 週の終了日

### WeeklyShoppingSnapshot

選択中の週に対応する画面表示データ。

- `weekRange`: 表示中の週範囲
- `selectedDate`: 現在選択中の日付
- `weekdaySections`: 曜日ごとの登録一覧
- `candidates`: 商品追加候補

## Relationships

- `SelectedWeekDate` から `WeekRange` が導出される。
- `WeekRange` をキーに `WeeklyShoppingSnapshot` が読み込まれる。
- `WeeklyShoppingSnapshot.selectedDate` は `WeekHeader` の選択状態と一致する。

## State Transitions

### Screen Open

1. 商品追加画面を開く。
2. 初期 `SelectedWeekDate` を翌週の月曜日に設定する。
3. その日付を使って `WeeklyShoppingSnapshot` を読み込む。

### Tap Selection

1. ユーザーが曜日チップをタップする。
2. `SelectedWeekDate` がその曜日の日付に更新される。
3. 対応する週データが再読み込みされる。

### Swipe Selection

1. ユーザーがヘッダを左右にスワイプする。
2. 選択中の曜日が 1 日分だけ移動する。
3. 週の先頭・末尾を越える場合はその週内にとどまる。

## Notes

- `week_range` のような追加保存項目は不要。
- この feature では migration を追加しない。
- 日付の正規化は既存の `dateOnly` を使う前提とする。
