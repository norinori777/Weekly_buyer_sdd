# Implementation Plan: Category Order Settings

**Branch**: `011-category-order` | **Date**: 2026-04-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/011-category-order/spec.md`

## Summary

購入リスト画面に表示されるカテゴリ順を、設定画面からドラッグで並べ替え、`sort_order` に保存する。既存の `Category.sort_order` をそのまま利用し、カテゴリ取得順を更新するだけで購入リスト側の表示順に反映させる。画面内ではローカルに並び替えを保持し、保存時に一括更新することで、キャンセル・リセット・再保存の操作を予測可能にする。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter analyze, flutter test, widget tests, repository tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: カテゴリの並び替えと保存が遅延なく完了すること  
**Constraints**: Offline-first, local-only persistence, no schema migration, category order stays consistent across screens  
**Scale/Scope**: 単一 Flutter アプリ内の設定画面と購入リスト表示

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。保存と表示反映の受け入れ基準を明記する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。購入リストのカテゴリ順を最短操作で調整できるようにする。
- データ再利用と拡張性: 適合。既存の `sort_order` を再利用し、新しい永続カラムは追加しない。

## Project Structure

### Documentation (this feature)

```text
specs/011-category-order/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
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
│               └── purchase_list_screen.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: 設定画面の新規 UI と順序変更の state は feature 配下に閉じ込める。永続化は既存リポジトリに追加し、購入リスト側は `Category.sort_order` の読み込み順を維持する。

## Complexity Tracking

不要。既存の `sort_order` を再利用するため、スキーマ変更や複雑な移行は発生しない。

