# Implementation Plan: 初期カテゴリとひらがな名の投入

**Branch**: `023-initial-catalog-seed` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/023-initial-catalog-seed/spec.md`

## Summary

アプリ起動時に使える初期カテゴリを指定の構成へ更新し、各商品候補にひらがな名を持たせる。新規インストールだけでなく既存インストールでも不足分を補えるように、起動時の seed 処理を初期データの同期として扱う。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter  
**Storage**: 既存のローカル SQLite をそのまま利用し、スキーマ変更は不要  
**Testing**: flutter analyze, flutter test, repository tests, startup seed regression tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: mobile-app  
**Performance Goals**: 初回起動時に seed が素早く完了し、起動体験を阻害しないこと  
**Constraints**: 既存ユーザーデータを上書きしない、カテゴリと商品候補の重複投入を避ける、ひらがな名は候補表示に使える形で保持する  
**Scale/Scope**: 単一 Flutter アプリ内の catalog seed と item master seed に限定

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。設計成果物は日本語で記述する。
- 品質ゲート: 適合。seed の投入内容と重複防止を受け入れ基準に含める。
- 技術スタック固定: 適合。既存の Flutter / Riverpod / Drift 構成を維持する。
- 買い物体験の最優先事項: 適合。商品候補の初期状態を整え、すぐ使い始められるようにする。
- データ再利用と拡張性: 適合。既存の category / item master テーブルをそのまま使う。

## Project Structure

### Documentation (this feature)

```text
specs/023-initial-catalog-seed/
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
│   └── app/
│       └── app_database.dart
└── test/
    └── repository_test.dart
```

**Structure Decision**: 初期 seed の定義と同期処理は `app_database.dart` に集約する。検証は `repository_test.dart` の中で、空データ環境と既存データ環境の両方に対する seed 同期を確認する。DB スキーマは変えず、seed 同期のロジックだけを追加する。

## Phase 0: Research Results

- `app_database.dart` には既に初期カテゴリと商品候補の seed があり、今回はその内容を置き換えるだけでなく、ひらがな名を同時に保持する必要がある。
- 現行の seed は「カテゴリが 1 件でもあれば何もしない」ため、既存インストールでは新しい初期データが反映されない。起動時に不足分を補う同期処理が必要である。
- ひらがな名は既存の `item_masters.hiragana` カラムに保存できるため、追加カラムやマイグレーションは不要である。
- seed 対象以外のカテゴリや商品候補は変更しない方針が最も安全である。

## Phase 1: Design & Data Model

- 初期カテゴリと商品候補を、カテゴリ名と商品名に加えてひらがな名を持つ seed 定義へ整理する。
- 起動時は seed 定義と既存データを照合し、足りないカテゴリや候補を補完する。
- 既存の seed データがある場合は重複を作らず、必要ならひらがなが空の seed 候補だけを補完する。
- seed 対象のカテゴリ順序は、指定された JSON の順序に合わせる。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。スキーマ変更はなく、主な作業は seed 定義の整理と起動時同期ロジックの拡張である。