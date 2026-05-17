# Implementation Plan: 未分類商品の商品マスター登録

**Branch**: `024-uncategorized-item-master` | **Date**: 2026-05-17 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/024-uncategorized-item-master/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/plan-template.md` for the execution workflow.

## Summary

購入リスト画面で未分類の項目を長押ししたときに、カテゴリ選択とひらがな入力を伴う商品マスター登録フローを追加する。既存の購入リスト表示、カテゴリ一覧、商品マスター登録 API を再利用し、DB スキーマ変更なしで完結させる。

## Technical Context

<!--
  ACTION REQUIRED: Replace the content in this section with the technical details
  for the project. The structure here is presented in advisory capacity to guide
  the iteration process.
-->

**Language/Version**: Dart / Flutter stable
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter
**Storage**: Local SQLite via Drift; no schema change required for this feature
**Testing**: flutter analyze, flutter test, widget tests, repository tests
**Target Platform**: Flutter mobile app targets in the existing workspace
**Project Type**: mobile-app
**Performance Goals**: Long-press registration should open immediately and complete without blocking purchase-list browsing
**Constraints**: Offline-first, local-only persistence, preserve existing item-master reuse flow, no new tables or schema migration
**Scale/Scope**: Single feature slice inside the weekly shopping app; one purchase-list screen flow plus shared master-data plumbing

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。仕様、計画、成果物は日本語中心で記述する。
- 品質ゲート: 適合。受け入れ基準と検証手順を明記し、テストで確認する。
- 技術スタック固定: 適合。Flutter、Riverpod、Drift を継続使用する。
- 買い物体験の最優先事項: 適合。購入リスト画面内で完結し、画面遷移を増やさない。
- データ再利用と拡張性: 適合。既存の商品マスター登録 API とカテゴリ一覧を再利用する。

## Project Structure

### Documentation (this feature)

```text
specs/024-uncategorized-item-master/
├── plan.md
├── research.md
├── data-model.md
└── quickstart.md
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

```text
weekly_buyer/
├── lib/
│   ├── features/
│   │   └── weekly_shopping_list/
│   │       ├── data/
│   │       │   └── weekly_shopping_repository.dart
│   │       ├── domain/
│   │       │   └── weekly_shopping_models.dart
│   │       └── presentation/
│   │           ├── purchase_list_destination.dart
│   │           ├── category_item_settings_destination.dart
│   │           └── item_editor_destination.dart
└── test/
  ├── repository_test.dart
  ├── category_item_settings_test.dart
  └── widget_test.dart
```

**Structure Decision**: 変更は既存の `weekly_shopping_list` feature に閉じ込める。購入リスト画面の長押し導線は `purchase_list_destination.dart` に追加し、登録ダイアログは既存の `item_editor_destination.dart` を再利用する。データ処理は `weekly_shopping_repository.dart` の既存 item master API に集約し、検証は repository test と widget test に分ける。

## Phase 0 Research

- 既存の購入リスト画面は、カテゴリ別に表示された item tile を Dismissible で購入済みにする構造になっており、同じ item tile に長押しハンドラを追加するのが最小変更である。
- 既存の item master 登録は、`name`、`hiragana`、`categoryId` を受け取る API が既にあり、今回の要件はこの API を呼ぶ UI を追加すれば満たせる。
- 既存の item editor sheet は、商品名・ひらがな・カテゴリの入力 UI を持つため、長押し登録ダイアログとして再利用できる。
- DB スキーマ変更は不要で、未分類 item の登録フローは既存の item master テーブルに対する追加登録として扱える。

## Phase 1 Design

- 購入リスト画面の未分類 item にのみ長押しアクションを追加し、既にカテゴリが付いている item では表示しない。
- 長押しで開く登録フローでは、商品名を購入項目の表示名で初期化し、ひらがな入力を必須、カテゴリは既存カテゴリ一覧から選択必須にする。
- 登録確定時は既存の `addItemMaster` を使って商品マスターへ保存し、登録後は候補一覧で再利用できるようにする。
- 誤操作防止のため、未分類 item がない場合は導線を出さず、カテゴリ未設定で登録開始できない場合はその場で止める。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。
