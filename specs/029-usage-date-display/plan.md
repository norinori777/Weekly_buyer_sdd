# 実装計画: 購入リストへの使用日表示

**ブランチ**: `029-display-product-usage-dates` | **日付**: 2026-10-25 | **仕様**: [spec.md](spec.md)  
**入力**: `specs/029-usage-date-display/spec.md`

## 概要

購入リストの商品行に、存在する購入日と、商品に設定された使用曜日から求めた対象週内の使用日を表示する。表示は購入日を先、使用日を後とし、各日付を `MM/DD(曜日)`（日本語の曜日1文字）で表す。対象週の起点・終点には既存の月曜始まり週範囲を使い、日付表示は購入リストの行に限定する。データベース変更や新規依存は行わない。

曜日計算と週の定義は既存モデル・週ヘルパーを再利用し、購入リスト専用の日付表示ヘルパーを追加する。既存の `formatPurchaseDate` は商品追加画面でも使われているため変更せず、商品追加画面の既存サブタイトルも対象外として維持する。

## 技術コンテキスト

**言語/バージョン**: Dart（`weekly_buyer/pubspec.yaml` の SDK 制約 `^3.11.5`）  
**主要依存**: Flutter / Material、Riverpod 2.x、Drift 2.x（すべて既存依存。追加なし）  
**ストレージ**: ローカル SQLite（Drift）。既存の購入日と曜日を読み取り、スキーマ変更・マイグレーションは行わない  
**テスト**: `flutter_test`。既存の Flutter テスト群を使い、表示・日付導出の単体/ウィジェット検証を追加する  
**対象プラットフォーム**: Flutter モバイルアプリ  
**プロジェクト種別**: モバイルアプリ  
**性能目標**: 表示中の購入リストで日付文字列を導出するだけとし、リスト描画に体感可能な遅延を追加しない  
**制約**: 月曜日から日曜日までの対象週、購入日と使用曜日の欠損を正しく扱う。年は表示せず、月日を2桁化し、曜日は日本語1文字で表す。外部 API・通信・新規パッケージを導入しない  
**規模/範囲**: `PurchaseListDestination` の商品行と関連する日付書式・表示テスト。商品追加画面、永続化、購入処理、他画面は変更対象外

技術上の未解決事項はない。既存実装根拠:

- `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`: `ShoppingItemEntry` は `weekday`、`purchaseDate`、`section` を保持し、`startOfWeek` / `endOfWeek` は月曜始まりの週範囲を返す。現在の `formatPurchaseDate` は別書式の購入日表示に使われている。
- `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`: 保存済みの曜日と購入日を `ShoppingItemEntry` に読み込む。追加時の曜日は選択中の日付に由来する。
- `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`: `_PurchaseItemTile` は数量と任意の購入日をサブタイトルに表示するため、日付表示の変更箇所が特定できる。
- `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`: 既存の購入日書式を追加画面でも利用する。本機能では既存書式を変更せず、追加画面の表示も範囲外である。
- `weekly_buyer/test/`: Flutter テストは `flutter_test` による既存構成である。

## 憲法チェック

### Phase 0 前

| 原則/ゲート | 判定 | 根拠 |
|---|---|---|
| 日本語ファースト | PASS | 計画・設計・利用者向けラベルを日本語で記述する。コード識別子・標準 API 名は原表記を使う。 |
| 品質ゲート | PASS | 購入日/使用日の有無、週境界、月またぎ、曜日・ゼロ埋めを検証可能なテストケースとして設計する。 |
| 技術スタック固定 | PASS | 既存の Dart/Flutter、Riverpod、Drift を維持し、新技術・依存を追加しない。 |
| 買い物体験の最優先 | PASS | 購入リストの商品行に必要な情報を追加し、画面遷移や購入操作の変更を避ける。 |
| データ再利用と拡張性 | PASS | 既存の週範囲・曜日・購入日を再利用し、重複する永続データを作らない。 |
| 非目標/データ状態 | PASS | ローカル保存および購入状態遷移を変更せず、DB マイグレーションを追加しない。 |

**ゲート結果**: 違反なし。Phase 0 の調査・設計へ進む。

## プロジェクト構成

### この機能のドキュメント

```text
specs/029-usage-date-display/
├── plan.md
├── research.md
├── data-model.md
└── quickstart.md
```

`contracts/` は作成しない。対象は Flutter アプリ内の画面表示のみで、外部 API、CLI、ライブラリ公開 API などのシステム境界インターフェースを追加・変更しない。

### ソースコードとテスト（リポジトリルートからの既存構成）

```text
weekly_buyer/
├── lib/features/weekly_shopping_list/
│   ├── domain/weekly_shopping_models.dart
│   ├── data/weekly_shopping_repository.dart
│   └── presentation/
│       ├── purchase_list_destination.dart
│       └── item_add_destination.dart  # 本機能では変更しない
└── test/
    ├── widget_test.dart
    ├── repository_test.dart
    └── ...                            # 既存 Flutter テスト
```

**構成判断**: 既存の週間買い物リスト feature に留める。画面用の日付書式・導出処理は週モデルの既存ヘルパーと整合させ、購入リストの商品行と対応テストに限って変更する。Repository や DB スキーマは変更しない。

## Phase 0: 調査結果

未解決の技術選択、依存追加、外部統合はない。ローカルコード確認で技術的前提が解決済みであり、外部調査は不要。決定事項と根拠は [research.md](research.md) に記録する。

## Phase 1: 設計概要

- 表示用の日付情報は永続化せず、選択中の対象週、既存の曜日、任意の購入日から導出する。
- スナップショットの `WeekRange` を購入リストのグループ・商品行へ渡し、商品行が選択中の対象週を使って使用日を導出できるようにする。
- `ShoppingSection.other` など日付に依存しない項目、または曜日が有効な月曜〜日曜でない項目には使用日を表示しない。
- 購入日は既存の `purchaseDate` がある場合のみ暦上の曜日とともに表示する。
- 日付文字列は購入リスト専用ヘルパーで `購入日:MM/DD(曜)`、`使用日:MM/DD(曜)` の順に必要なラベルのみ連結する。既存の `formatPurchaseDate` は商品追加画面での現行表示に使われるため維持する。ラベルが両方ともない場合には日付欄を空にする（数量表示は維持する）。
- 対象週は `WeekRange.start`（月曜日）を基準に曜日分の日数を加算する。月末・年末を跨ぐ場合も `DateTime` の暦日繰り上がりに任せ、曜日文字列は導出された日付自体から求める。
- 表示確認は `purchase_list_destination.dart` の商品行を対象とする。商品追加画面の購入日サブタイトルと既存書式関数は変更しない。
- 画面テストに加え、日付導出・書式の境界ケースをテストする。実装時の具体的なテスト名は Phase 2 のタスクで決める。

データ項目、導出規則、検証条件は [data-model.md](data-model.md)、開発者向け検証手順は [quickstart.md](quickstart.md) に記録する。

## Phase 1 後の憲法再チェック

| 原則/ゲート | 判定 | 設計後の確認 |
|---|---|---|
| 日本語ファースト | PASS | UI ラベル・曜日略称・計画資料は日本語。 |
| 品質ゲート | PASS | 週境界、曜日、日付欠損、表示順・書式を個別に検証できるよう設計。 |
| 技術スタック固定 | PASS | 既存 Flutter UI と Dart のみを使用し、新規技術・依存なし。 |
| 買い物体験の最優先 | PASS | 購入リストの商品行への情報追加に限定し、購入操作を変えない。 |
| データ再利用と拡張性 | PASS | 既存項目から導出し、DB と同期・保存モデルを増やさない。 |
| 状態・非目標 | PASS | 購入/削除状態、商品追加画面、外部連携は対象外。 |

**再チェック結果**: 違反なし。複雑性の例外はなく、Complexity Tracking は不要。

## ブランチ名について

仕様メタデータの Feature Branch は `029-usage-date-display` だが、今回の setup が返した実ブランチは `029-display-product-usage-dates` である。実行時の BRANCH を計画上のブランチとして採用し、仕様書のメタデータは本計画の範囲外として変更していない。
