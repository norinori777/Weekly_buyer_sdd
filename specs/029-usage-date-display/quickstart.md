# クイックスタート: 購入リストへの使用日表示

## 前提

- Flutter SDK が利用できること。
- 作業ディレクトリを `weekly_buyer/` にすること。
- この機能の対象は購入リスト画面の商品行であり、商品追加画面の表示や DB スキーマは変更しない。

## 検証手順

1. Flutter パッケージディレクトリへ移動する。

   ```powershell
   Set-Location weekly_buyer
   ```

2. 依存関係を同期し、関連テストを実行する。

   ```powershell
   flutter pub get
   flutter test
   ```

3. 必要に応じて静的解析と整形を確認する。

   ```powershell
   flutter analyze
   dart format --output=none --set-exit-if-changed lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart test
   ```

## 期待される確認項目

- 購入日 `2026-10-25`、対象週 `2026-10-26`〜`2026-11-01`、使用曜日が月曜の商品では、購入日を先に、`購入日:10/25(日) 使用日:10/26(月)` と表示する。
- 購入日がなく、使用曜日が月曜なら `使用日:10/26(月)` と表示する。
- 使用曜日が日曜なら、月またぎ対象週の終端 `11/01(日)` を表示する。
- 月日が1桁になるケースでも `MM/DD` を保つ。
- 購入日だけがある場合は購入日ラベルだけを表示し、両日付がない場合は日付ラベルがない。
- 日付に依存しない項目には使用日を推測表示しない。
- 数量表示、購入済み操作、商品追加画面の既存表示に回帰がない。

この文書は計画時の検証手順であり、実装やテスト実行の完了を意味しない。
