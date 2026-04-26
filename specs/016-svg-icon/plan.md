# Implementation Plan: SVG アイコン統一

**Branch**: `016-svg-icon` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/016-svg-icon/spec.md`

## Summary

アプリで使うブランドアイコンを、`assets/weekly_buyer.svg` のベクター表現へ統一する。既存の PNG プレースホルダ参照を廃止し、SVG を複数画面で再利用できる共通アイコンとして表示する。画面サイズに依存しにくい描画に切り替え、アプリの他の動作は変えない。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner, SVG 表示用パッケージ  
**Storage**: No persistent data changes  
**Testing**: flutter analyze, flutter test, widget tests for icon rendering  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: アイコン表示が初回表示時から即時に描画され、画面サイズ変更でも崩れないこと  
**Constraints**: Offline-first, local-only persistence, existing screens and navigation must remain unchanged  
**Scale/Scope**: 単一 Flutter アプリ内の共通ブランド表示と各主要画面の AppBar

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。SVG アイコンの表示と回帰防止を明示する。
- 技術スタック固定: 適合。Flutter の既存構成を維持し、必要最小限の表示依存のみ追加する。
- 買い物体験の最優先事項: 適合。画面遷移や操作フローを変えず、見た目だけを改善する。
- データ再利用と拡張性: 適合。保存データは変更せず、共通ブランド表示として再利用する。

## Project Structure

### Documentation (this feature)

```text
specs/016-svg-icon/
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
├── assets/
│   └── weekly_buyer.svg
├── lib/
│   ├── app/
│   │   ├── weekly_buyer_app.dart
│   │   └── providers.dart
│   └── features/
│       └── weekly_shopping_list/
│           └── presentation/
│               ├── main_shell.dart
│               ├── item_add_destination.dart
│               ├── purchase_list_destination.dart
│               └── settings_destination.dart
└── test/
    └── widget_test.dart
```

**Structure Decision**: SVG アイコンは共通のブランド要素として扱い、アプリの主要な AppBar に再利用する。`weekly_buyer_app.dart` と各主要画面のタイトル領域に共通表示を追加し、画像資産の参照は SVG に一本化する。

## Phase 0: Research Results

- 現在のコードベースにはブランド画像の共通表示がなく、AppBar はテキスト中心で構成されている。
- アセット参照は SVG を使うので、アセット参照と描画方法の両方を更新する必要がある。
- 最小の変更でブランド感を出すには、共通の小さなアイコン表示を AppBar に追加するのが自然である。
- 既存画面の見た目と操作を壊さないため、アイコンは独立した再利用 widget として実装するのがよい。

## Phase 1: Design & Data Model

- `weekly_buyer.svg` を表示する共通ブランド widget を新規作成する。
- AppBar のタイトル周辺に SVG アイコンを配置し、主要画面で同じ見た目を再利用する。
- `pubspec.yaml` のアセット参照を SVG に更新する。
- widget テストで、ブランド icon が表示されることと既存の主要画面が引き続き開けることを確認する。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。保存データや画面遷移を変えず、共通のブランド表示を差し替えるだけで完結する。
