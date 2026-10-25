# 実装計画: 購入済み商品の長押しによる購入済み解除

**ブランチ**: `031-unmark-purchased-longpress` | **日付**: 2026-10-25 | **仕様**: [spec.md](spec.md)  
**入力**: `specs/031-unmark-purchased-longpress/spec.md`

## 概要

商品追加画面（`ItemAddDestination`）の商品リスト行で、購入済み商品を長押しすると「購入済みを解除しますか？」の確認ダイアログを表示し、「はい」で購入済みと購入日を解除して未購入表示に戻す。「いいえ」や外側タップでは何も変更しない。未購入商品の長押しは何も起こさず、前の週（読み取り専用）では無効にする。

解除は、状態を反転する既存の `togglePurchased` ではなく、リポジトリに冪等な `unmarkPurchased(itemId)` を追加して行う。ダイアログ表示中に状態が変わっても、誤って再度購入済みにならないようにするため。DB スキーマ変更・新規依存はなし。

## 技術コンテキスト

**言語/バージョン**: Dart（`weekly_buyer/pubspec.yaml` の SDK 制約 `^3.11.5`）  
**主要依存**: Flutter / Material 3、Riverpod 2.x、Drift 2.x（すべて既存。追加なし）  
**ストレージ**: ローカル SQLite（Drift）。`weekly_list_items.is_purchased` と `purchased_at` を更新するのみ。マイグレーション不要  
**テスト**: `flutter_test`（`test/repository_test.dart`、`test/widget_test.dart`）  
**対象プラットフォーム**: Flutter モバイルアプリ  
**プロジェクト種別**: モバイルアプリ  
**性能目標**: 「はい」選択から1秒以内に一覧へ反映（SC-002）  
**制約**: 1件ずつの解除、日本語 UI、ダイアログ表示中の画面回転で状態を失わない（`showDialog` は Navigator 管理のため満たされる）  
**規模/範囲**: 商品追加画面の商品行とリポジトリ1メソッド。購入リスト画面（`purchase_list_destination.dart`）の既存操作は対象外

NEEDS CLARIFICATION はなし。既存実装の根拠:

- `item_add_destination.dart`: `_SectionPreviewCard` が商品行を `ListTile` で描画し、`item.isPurchased` で色を変えている。`onDeleteItem` と同様にコールバックを親から渡し、`ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate))` で再読込する構成。
- `weekly_shopping_repository.dart`: `togglePurchased`、`undoLatestPurchase` が `isPurchased`/`purchasedAt` を更新する既存パターン。
- `category_item_settings_destination.dart` に `showDialog` の既存利用例がある。

## 憲法チェック

### Phase 0 前

| 原則 | 判定 | 根拠 |
|------|------|------|
| I. 日本語ファースト | 適合 | 仕様・計画・ダイアログ文言とも日本語 |
| II. 品質ゲート | 適合 | 受け入れシナリオあり。テスト・`flutter analyze` を完了条件にする |
| III. 技術スタック固定 | 適合 | Flutter Material 3 / Drift / Riverpod のみ、新規依存なし |
| IV. 買い物体験 | 適合 | 画面遷移なしのダイアログ1回で解除でき、誤操作時の復帰手段になる |
| V. データ再利用・拡張性 | 適合 | ローカル保存のみ。商品マスタ・カテゴリには影響しない |

違反なし。Complexity Tracking は不要。

## プロジェクト構成

### この機能のドキュメント

```text
specs/031-unmark-purchased-longpress/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contract.md
├── checklists/requirements.md
└── tasks.md        # /speckit.tasks で作成（本コマンドでは作らない）
```

### ソースコードとテスト

```text
weekly_buyer/
├── lib/features/weekly_shopping_list/
│   ├── data/weekly_shopping_repository.dart            # unmarkPurchased(int itemId) を追加
│   └── presentation/item_add_destination.dart          # 長押し・確認ダイアログ・再読込
└── test/
    ├── repository_test.dart                            # 解除の永続化・冪等性
    └── widget_test.dart                                # 長押し→はい/いいえ/未購入
```

**構成の決定**: 既存の単一 Flutter アプリ構成（`weekly_buyer/`）に沿い、データ層1メソッドと表示層の変更のみで完結させる。

## Phase 0: 調査結果

[research.md](research.md) を参照。

## Phase 1: 設計概要

- [data-model.md](data-model.md): 既存 `weekly_list_items` の状態遷移
- [contracts/ui-contract.md](contracts/ui-contract.md): 長押し・ダイアログの UI 契約
- [quickstart.md](quickstart.md): 手動・自動の検証手順

## Phase 1 後の憲法再チェック

設計後も全原則に適合。スキーマ変更・新規依存・画面遷移の追加はなく、既存の購入済み／元に戻す操作とも干渉しない。
