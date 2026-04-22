# Implementation Plan: 翌週の購入日を既定表示にする

**Branch**: `010-next-week-weekday-display` | **Date**: 2026-04-22 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-next-week-weekday-display/spec.md`

## Summary

商品追加画面は、起動直後から「翌週の買い物」を基準に表示する。既存の曜日切替ヘッダと週単位の取得処理をそのまま使い、初期選択日だけを翌週の月曜日に寄せることで、週表示・曜日選択・読み込み対象を一貫して翌週に合わせる。既存の曜日ラベル簡略化とスワイプ切替は維持し、今回の変更は初期週コンテキストの調整に集中する。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter analyze, flutter test, widget tests, repository tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 画面起動時に翌週表示へ切り替わっても遅延を感じないこと  
**Constraints**: Offline-first, Monday-start week, selected week stays within a single calendar week, no schema migration  
**Scale/Scope**: 単一 Flutter アプリ内の買い物関連画面とそのテスト

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。受け入れ基準と自動テストを plan に含める。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。画面遷移を増やさず、初期表示だけを翌週に合わせる。
- データ再利用と拡張性: 適合。既存の週単位 state を流用し、永続化は変更しない。

## Project Structure

### Documentation (this feature)

```text
specs/010-next-week-weekday-display/
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
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── item_add_destination.dart
│               └── week_header.dart
└── test/
    └── widget_test.dart
```

**Structure Decision**: 画面初期化は `weekly_buyer/lib/app/providers.dart` の週選択 state を基点にし、表示は `weekly_buyer/lib/features/weekly_shopping_list/presentation/` 配下に閉じ込める。永続層は変更せず、関連テストは `weekly_buyer/test/widget_test.dart` に追加する。

## Complexity Tracking

不要。今回の変更は既存の state 初期値と UI 表示の調整に収まり、構成原則を逸脱しない。
