# Implementation Plan: Category and Item Settings

**Branch**: `012-category-item-settings` | **Date**: 2026-04-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/012-category-item-settings/spec.md`

## Summary

設定画面でカテゴリと商品マスタを管理し、カテゴリは名前のみ編集可能にする。商品は名前を中心に管理し、数量入力はUIから外す。既存の Drift スキーマは変更せず、`WeeklyShoppingRepository` に削除前チェックを追加して、カテゴリ内に商品がある場合のカテゴリ削除と、現在の購入週に含まれる商品の削除を阻止する。UI は削除不可理由を表示し、リポジトリは例外で整合性を守る。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter analyze, flutter test, widget tests, repository tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 設定画面での追加・編集・削除が即時に反映されること  
**Constraints**: Offline-first, local-only persistence, no schema migration, delete rules enforced in repository and UI  
**Scale/Scope**: 単一 Flutter アプリ内の設定画面と購入リスト表示

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。削除不可条件と受け入れ基準を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。設定からの操作で基本の購入体験を壊さない。
- データ再利用と拡張性: 適合。既存スキーマを再利用し、将来の拡張に備える。

## Project Structure

### Documentation (this feature)

```text
specs/012-category-item-settings/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── checklists/
    └── requirements.md
```

### Source Code (repository root)

```text
weekly_buyer/
├── lib/
│   ├── app/
│   │   └── providers.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── data/
│           │   └── weekly_shopping_repository.dart
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── settings_destination.dart
│               ├── category_order_destination.dart
│               ├── category_item_settings_destination.dart
│               └── item_editor_destination.dart
└── test/
    ├── repository_test.dart
    ├── widget_test.dart
    └── category_item_settings_test.dart
```

**Structure Decision**: 設定画面のカテゴリ・商品管理は weekly_shopping_list feature 配下に集約し、永続化は既存のリポジトリとドメインを拡張して扱う。設定画面の一覧と編集ダイアログは presentation に閉じ込め、テストは repository と widget を分けて維持する。

## Complexity Tracking

不要。既存スキーマを再利用し、削除可否はアプリ層とリポジトリ層で制御するため、複雑な移行や追加基盤は不要。
