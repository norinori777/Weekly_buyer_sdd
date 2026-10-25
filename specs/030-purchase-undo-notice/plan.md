# Implementation Plan: 購入済み通知の重複解消と自動消去

**Branch**: `030-purchase-undo-notice` | **Date**: 2026-10-25 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/030-purchase-undo-notice/spec.md`

## Summary

購入リストで商品を購入済みにすると、黒色の SnackBar と画面内の `UndoBanner` が重複表示されている。SnackBar の表示を購入済み操作から削除し、`UndoBanner` を「購入済み操作の直後だけ表示される一時通知」に変更する。通知状態は Riverpod の `StateProvider` で保持し、3 秒タイマーで自動消去、タブ切替・画面遷移・「元に戻す」押下で即時消去する。

## Technical Context

**Language/Version**: Dart ^3.11.5 / Flutter (Material 3)  
**Primary Dependencies**: flutter_riverpod ^2.6.1  
**Storage**: Drift (既存)。購入状態の永続化は変更なし。通知は永続化しない一時的な UI 状態  
**Testing**: flutter_test (`weekly_buyer/test/widget_test.dart`)。`tester.pump(Duration)` で 3 秒経過を検証  
**Target Platform**: Android (Flutter)  
**Project Type**: mobile-app  
**Performance Goals**: 通知は 3 秒 (±0.5 秒) で消える  
**Constraints**: 買い物中の片手操作を妨げない。画面遷移を増やさない  
**Scale/Scope**: 2 ファイルの UI 変更 (`purchase_list_destination.dart`, `weekly_shopping_page.dart`) と状態 1 件の追加

## Constitution Check

*GATE: Phase 0 前に確認し、Phase 1 後に再確認した。*

| 原則 | 判定 | 根拠 |
|------|------|------|
| I. 日本語ファースト | PASS | 仕様・計画とも日本語で記述 |
| II. 品質ゲート | PASS | 受け入れ基準が仕様にあり、ウィジェットテストで検証する。既存テスト更新を含む |
| III. 技術スタック固定 | PASS | Flutter + Riverpod のみ。新規依存なし |
| IV. 買い物体験最優先 | PASS | 不要な通知を減らし、「元に戻す」は購入直後に 1 箇所だけ提供 |
| V. データ再利用と拡張性 | PASS | データモデル・DB 変更なし |
| 制約: 一時 UI 状態の分離 | PASS | 通知は永続データと分け、メモリ上の状態のみ |

違反なし。Complexity Tracking は不要。

## Project Structure

### Documentation (this feature)

```text
specs/030-purchase-undo-notice/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── ui-contract.md
└── tasks.md             # /speckit.tasks で作成
```

### Source Code (repository root)

```text
weekly_buyer/
├── lib/
│   ├── app/
│   │   └── app_state_providers.dart          # purchaseUndoNoticeProvider を追加
│   └── features/weekly_shopping_list/presentation/
│       ├── purchase_list_destination.dart    # SnackBar 削除、通知の表示制御
│       └── weekly_shopping_page.dart         # 同上 (UndoBanner と旧ページ側 SnackBar)
└── test/
    └── widget_test.dart                      # 既存テスト更新 + 新規テスト
```

**Structure Decision**: 既存の feature 構成 (`presentation` / `app` の状態プロバイダ) を踏襲し、新規ファイルは作らない。

## Design Overview

1. **SnackBar 削除 (FR-001, FR-002)**: 両ファイルの `onTogglePurchased` から `clearSnackBars()` + `showSnackBar(購入済み)` を削除する。他の SnackBar (カテゴリ追加依頼、マスター登録) は変更しない。
2. **一時通知状態 (FR-003, FR-006)**: `purchaseUndoNoticeProvider` (`StateProvider<PurchaseUndoNotice?>`) を追加する。購入済み操作で新しいインスタンス (商品名・発生時刻) を設定する。新しい操作では値が置き換わる。
3. **表示条件の変更**: `UndoBanner` は従来の `hiddenPurchasedCount > 0 || lastPurchasedItem != null` ではなく、通知が非 null のときだけ表示する。件数 `(n)` は従来どおり表示してよい。読み取り専用 (前の週) では表示しない。
4. **3 秒で消去 (FR-003, FR-006)**: 通知を表示するホスト Widget (StatefulWidget) で `Timer(Duration(seconds: 3))` を保持し、通知が変わるたびにキャンセルして再設定する。満了時に通知を `null` にする。`dispose` で必ずキャンセルする。
5. **画面遷移で消去 (FR-005)**: ホストが `ref.listen(mainShellDestinationProvider)` で shell の遷移を検知して通知を `null` にし、`dispose` でも `null` にする (戻ったときに再表示しない)。判断根拠は [research.md](./research.md) を参照。
6. **元に戻す (FR-004)**: 押下で `undoLatestPurchase` を実行し、スナップショットを invalidate し、通知を `null` にする。タイマー満了と同時でも通知消去は冪等とする。

## Test Strategy

- 更新: `keeps purchased items hidden after switching between list tabs` (widget_test.dart 148 行付近)。タブ切替後に通知が残る前提を、「通知は消えるが商品は非表示のまま・DB は購入済み」へ変更する。
- 新規: 購入済み操作で SnackBar が出ない (`find.byType(SnackBar)` が 0)。
- 新規: 通知が 1 組だけ表示される。
- 新規: `pump(Duration(seconds: 3))` 後に通知が消える。2 秒時点では残る。
- 新規: 連続購入で最新の通知に置き換わり、3 秒が数え直される。
- 新規: 3 秒以内に「元に戻す」を押すと未購入に戻り通知が消える。
- 新規: 3 秒以内にタブ遷移すると通知が消え、戻っても再表示されない。
- 既存テスト 1320 行付近の `元に戻す` を扱うテストは、新しい表示条件に合わせて確認・修正する。

## Complexity Tracking

該当なし。
