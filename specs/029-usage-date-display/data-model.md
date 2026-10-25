# データモデル: 購入リストへの使用日表示

## 方針

この機能は既存の週間買い物リストデータを画面表示時に投影する。永続化エンティティや SQLite スキーマ、Repository の読み書きは変更しない。使用日は既存の `ShoppingItemEntry.weekday` と選択中の `WeekRange` から導出する。

## 既存エンティティと表示に使う属性

### 購入リスト商品 (`ShoppingItemEntry`)

既存定義: `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`

| 属性 | 型 | 用途・制約 |
|---|---|---|
| `id` | `int` | リスト商品識別子。表示上の導出には使わない。 |
| `weekday` | `int` | 商品追加時に選んだ曜日。1（月）〜7（日）の値を使用日導出に使う。値が範囲外の場合は安全のため使用日を表示しない。 |
| `section` | `ShoppingSection` | `other` のような曜日に依存しない項目には使用日を表示しない。 |
| `purchaseDate` | `DateTime?` | 設定時のみ購入日ラベルを表示する。曜日はこの日付自身から求める。 |
| `quantity` | `int` | 現在の数量表示を維持する。日付情報と独立。 |
| `name` | `String` | 商品名。表示情報の導出に使わない。 |

Repository は `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` で保存済みの `weekday` と `purchaseDate` を読み込み、行へ渡す。これらの属性に新規の書込み要件はない。

### 対象週 (`WeekRange`)

既存定義: `weekly_shopping_models.dart`

| 属性 | 型 | 用途・制約 |
|---|---|---|
| `start` | `DateTime` | 月曜日。使用日の算出基準。 |
| `end` | `DateTime` | 日曜日。週範囲の確認・テストに使う。 |

既存 `startOfWeek` / `endOfWeek` の週意味論は月曜始まり・日曜終わり。対象週は購入リストのスナップショットが示す週とし、端末の現在日付から独自に再計算しない。表示を行う商品行まで `WeekRange`（または `start`）を引き渡す。

## 導出値: 表示用日付文字列

### 使用日

1. `section.isDayIndependent` が真、または `weekday` が1〜7の範囲外なら使用日なし。
2. それ以外は対象週開始日を日付のみへ正規化し、`weekday - DateTime.monday` 日を加算する。
3. 得られた `DateTime` から曜日略称を決める。表示形は `使用日:MM/DD(曜)`。

### 購入日

`purchaseDate == null` の場合はなし。値がある場合、その `DateTime` 自身の月・日・曜日を表示し、形は `購入日:MM/DD(曜)`。

### 行サブタイトル

- 購入リスト専用の日付フォーマット関数を用意する。既存の `formatPurchaseDate` は商品追加画面でも使われる現行表示を保つため変更しない。
- 数量の既存表示を維持し、日付ラベル部分は購入日、使用日の順に空白区切りで結合する。
- 両方ある場合: `購入日:10/25(日) 使用日:10/26(月)`
- 購入日のみ: `購入日:10/25(日)`
- 使用日のみ: `使用日:10/26(月)`
- いずれもない場合: 日付ラベルを付与しない（数量表示のみ）。
- 月と日は必ず2桁。年は含めない。曜日と日付が不一致になる独立の曜日値を保持しない。

## 関係と状態

```text
WeeklyShoppingSnapshot
  ├── WeekRange (start: 月曜日, end: 日曜日)
  └── categoryGroups[]
       └── ShoppingItemEntry
            ├── weekday ────────────┐
            ├── section (日付依存) ├─> 派生: 使用日文字列
            └── purchaseDate ─────────> 派生: 購入日文字列
```

派生文字列は一時的な UI 表示値であり、状態遷移・DB 書込み・マイグレーションを生じない。購入日と使用日の有無の組み合わせは4通りで、表示対象となるラベルだけを描画する。

## 検証ルール

- 週内曜日の導出は月曜日〜日曜日すべてに対して対象週内の日付を返す。
- 週末・月またぎ（例: 2026-10-26〜2026-11-01）を正しく扱う。
- 月日をそれぞれ2桁にし、曜日は当該日付の暦と一致させる。
- 購入日・使用日の片方または両方が未設定の場合、存在しないラベルや日付を描画しない。
- 日付に依存しない商品・無効な曜日に、推測で使用日を付与しない。
