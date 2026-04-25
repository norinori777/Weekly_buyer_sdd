# Implementation Plan: 前週参照表示

**Branch**: `015-previous-week-view` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/015-previous-week-view/spec.md`

## Summary

商品追加画面で、次週を初期表示のまま維持しつつ、前の週・2週間前・3週間前へさかのぼって内容を参照できるようにする。過去週は読み取り専用とし、商品追加と料理メニュー追加の導線を無効化する。既存の週単位データを再利用し、追加の保存スキーマは作らない。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift, using the existing week-scoped data model  
**Testing**: flutter analyze, flutter test, repository tests, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 週の切り替えと過去週の表示が即時に反映され、操作待ちを感じないこと  
**Constraints**: Offline-first, local-only persistence, no new history screen, prior-week views must be read-only  
**Scale/Scope**: 単一 Flutter アプリ内の週次買い物画面と商品追加画面

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。過去週の閲覧と編集不可の受け入れ基準を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。画面遷移を増やさず、同じ商品追加画面内で完結する。
- データ再利用と拡張性: 適合。既存の週単位データを再利用し、履歴用の追加スキーマは作らない。

## Project Structure

### Documentation (this feature)

```text
specs/015-previous-week-view/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
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
│               ├── item_add_destination.dart
│               ├── purchase_list_destination.dart
│               ├── weekly_shopping_page.dart
│               └── week_header.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: 前週参照は既存の `weekly_shopping_list` feature に集約し、週選択の状態は共通の app state を使う。新しい履歴画面は作らず、既存の商品追加画面の週操作とセクション表示を拡張して、読み取り専用モードを切り替える。

## Phase 0: Research Results

- この機能は新しい保存対象を増やすより、既存の週単位データを別週として表示する設計が自然である。
- ユーザーが欲しいのは「数週間前の内容を確認すること」であり、履歴編集ではないため、過去週は編集できないことを明示すべきである。
- 週の移動は連続操作が前提になるため、1 週間戻る・さらに戻るという段階的な週移動が分かりやすい。
- 過去週の空データ表示は、エラーではなく「記録なし」として扱う方が確認用途に合う。

## Phase 1: Design & Data Model

- 既存の週選択状態を拡張し、現在の次週表示と過去週表示を同じ週ビューのバリエーションとして扱う。
- 読み取り専用フラグを週ビューの状態に持たせ、過去週選択時は追加ボタンや入力導線を無効化する。
- 画面側は、選択中の週に応じて表示する内容を切り替え、過去週では参照専用の見た目を付与する。
- repository は週ごとの既存データを読み出すだけに留め、履歴用の追加保存や複製は行わない。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。既存の週表示と商品追加画面の状態制御を拡張するだけで、追加のデータ移行や外部依存は不要。
