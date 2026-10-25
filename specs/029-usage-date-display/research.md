# 調査結果: 購入リストへの使用日表示

調査はリポジトリ内の既存仕様・モデル・Repository・画面・テスト構成に限定した。技術選択はコード根拠から解決できたため、外部調査や新規パッケージの評価は不要。

## 週の定義と使用日の導出

- **決定**: 購入リストの対象週の月曜日を起点とし、商品に設定された曜日に対応する日数を加算して使用日を得る。使用曜日がない項目（曜日に依存しない項目を含む）には使用日を表示しない。
- **根拠**: `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` の `startOfWeek` は月曜日を週の開始日に正規化し、`endOfWeek` は開始日から6日後を返す。`ShoppingItemEntry` は `weekday` と `section` を持つ。`ShoppingSection.other` は `isDayIndependent` として扱われる。
- **理由**: 既存の月曜〜日曜の週意味論に沿うことで、月またぎ・年またぎでも曜日から一意な使用日を導出でき、永続データを増やさず仕様の対象週を守れる。
- **代替案**: 商品追加時に使用日を DB へ保存する。曜日と週範囲から既に決定できる値を重複保存し、マイグレーション・更新不整合を増やすため採用しない。

## 購入日・表示対象

- **決定**: 購入リストの行に限り、既存 `purchaseDate` を購入日として表示し、存在しない場合は購入日ラベルを出さない。既存 `formatPurchaseDate` は商品追加画面で共有されているため維持し、購入リスト専用の書式関数を設ける。商品追加画面の表示は変更しない。
- **根拠**: `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` の `_PurchaseItemTile` が購入リストの数量・購入日サブタイトルを描画する。`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` にも同じ `formatPurchaseDate` を使う類似表示がある。`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` は保存済み購入日と曜日を `ShoppingItemEntry` に読み込む。
- **理由**: 仕様の明示的な対象画面に絞り、既存の入力・追加フローを変更しない。
- **代替案**: 共用 `formatPurchaseDate` を新形式へ置き換える。追加画面まで意図しない表示変更となるため採用しない。

## 日付フォーマットと曜日

- **決定**: 購入日・使用日をそれぞれ `MM/DD(曜)` とし、月日をゼロ埋めして2桁化する。曜日は日付自身の `DateTime.weekday` に基づく「月・火・水・木・金・土・日」の1文字とする。ラベルは購入日、使用日の順に連結する。
- **根拠**: 仕様 `spec.md` の FR-002〜FR-007。現在の `formatPurchaseDate` は `weekly_shopping_models.dart` にあり、現状は `M月d日` 形式である。
- **理由**: 日付の実際の曜日を反映し、月初・週末・月またぎでも暦と整合する。購入日と使用日で同じ表示規則を共有できる。
- **代替案**: `intl` などの新規依存を使う。必要な書式は Dart の標準 `DateTime` と簡単なゼロ埋めで表現でき、依存追加の利点がないため採用しない。

## テスト・外部インターフェース

- **決定**: 既存の `flutter_test` を使い、日付導出・フォーマットの境界ケースと購入リスト行の表示を検証する。`contracts/` は作成しない。
- **根拠**: Flutter テストは `weekly_buyer/test/` 配下にあり、公開される外部 API・CLI・外部サービスは本機能に含まれない。
- **理由**: アプリ内表示変更に対して既存テスト基盤が十分であり、外部システム境界の契約を新設する理由がない。
- **代替案**: API 契約ファイルや追加のテスト依存を導入する。対象となる外部インターフェースがないため採用しない。
