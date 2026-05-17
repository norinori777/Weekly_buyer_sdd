# Implementation Plan: 商品追加画面の購入済み商品表示

**Branch**: `026-keep-purchased-visible` | **Date**: 2026-05-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/026-keep-purchased-visible/spec.md`

## Summary

商品追加画面で購入済みの商品を一覧から消さずに残し、商品名と数量を購入済みを示す色で表示する。取得側で購入済み商品を除外しない形に改め、表示側で `isPurchased` に応じて文字色を切り替えることで、状態を見失わずに買い物を続けられるようにする。

## Technical Context

**Language/Version**: Dart 3.11.5 / Flutter
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, flutter_test
**Storage**: local SQLite via Drift
**Testing**: `flutter analyze`, `flutter test`
**Target Platform**: Flutter mobile app (Android/iOS; existing desktop/web targets remain buildable)
**Project Type**: mobile-app
**Performance Goals**: 購入済み切り替え後も画面遷移なしで一覧の状態と色が即時に更新される
**Constraints**: offline-capable local storage; no schema changes required; preserve current toggle/undo flow and previous-week read-only behavior
**Scale/Scope**: `weekly_shopping_list` feature の一覧取得と行表示の局所的な変更

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合
- 品質ゲート: 適合
- 技術スタック固定: 適合
- 買い物体験の最優先事項: 適合
- データ再利用と拡張性: 適合

## Project Structure

### Documentation (this feature)

```text
specs/026-keep-purchased-visible/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root)

```text
weekly_buyer/lib/
├── app/
│   └── app_state_providers.dart
└── features/weekly_shopping_list/
    ├── data/
    │   └── weekly_shopping_repository.dart
    ├── domain/
    │   └── weekly_shopping_models.dart
    └── presentation/
        ├── weekly_shopping_page.dart
        └── purchase_list_destination.dart

weekly_buyer/test/
├── repository/
└── widget/
```

**Structure Decision**: 変更は既存の `weekly_shopping_list` feature に閉じ込める。購入済みの非表示解除は `weekly_shopping_repository.dart` のスナップショット組み立てと `weekly_shopping_page.dart` の行表示、購入済み色の適用は表示コンポーネント側に集約し、必要に応じて `purchase_list_destination.dart` 側の共有タイルにも同じ見た目を揃える。

## Phase 0: Research Results

- 現状の `WeeklyShoppingRepository.loadWeek` は、`sections` と `weekdaySections` を組み立てる際に `!item.isPurchased` を使って購入済み商品を除外している。
- 商品追加画面の行表示は `weekly_shopping_page.dart` の `ShoppingItemTile` が担っており、ここで `isPurchased` に応じた文字色切り替えを行うのが最小変更である。
- 購入済み状態の変更自体は既存の `togglePurchased` と `undoLatestPurchase` をそのまま使えるため、データモデルの拡張は不要である。
- 前の週の read-only 表示と、購入済み商品を元に戻す導線は既存の挙動を維持できる。

## Phase 1: Design & Data Model

- `ShoppingItemEntry` の `isPurchased` を表示条件として使い、購入済み商品をリストから除外しない。
- `weekly_shopping_repository.dart` では、商品追加画面用の `sections` / `weekdaySections` に購入済み商品も含める。
- `weekly_shopping_page.dart` の `ShoppingItemTile` で、購入済み商品の商品名と数量に購入済み用の色を適用する。
- 必要であれば `purchase_list_destination.dart` の共通タイルにも同じ視覚表現を揃えるが、機能要件の対象は商品追加画面とする。

## Phase 1 Re-check

- 日本語ファースト: 適合
- 品質ゲート: 適合
- 技術スタック固定: 適合
- 買い物体験の最優先事項: 適合
- データ再利用と拡張性: 適合

## Complexity Tracking

不要。新しい永続化構造や外部インターフェースは不要で、既存の購入状態と表示ロジックの接続を直すだけで実現できる。
