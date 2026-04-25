# Implementation Plan: 「次も登録」ボタンと補足文の改善

**Branch**: `020-next-register-copy` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/020-next-register-copy/spec.md`

## Summary

商品追加フォームの連続入力ボタンを「次も登録」に変更し、直下に「保存して続けて入力できます」という補足を追加する。既存の連続登録動作はそのまま維持し、文言と補足だけで意図が伝わりやすい UI に整える。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter  
**Storage**: N/A - no data model or persistence change  
**Testing**: flutter analyze, flutter test, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: mobile-app  
**Performance Goals**: 既存の表示を崩さず、ボタンと補足が同一画面で即時に理解できること  
**Constraints**: Offline-first, local-only app, existing continue-add behavior must remain unchanged, helper text must fit within the current add form layout  
**Scale/Scope**: 単一 Flutter アプリ内の商品追加画面の文言改善

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。表示文言と成果物は日本語中心で記述する。
- 品質ゲート: 適合。ラベル変更と補足文の表示を検証対象に含める。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。続けて入力する意図を一目で伝える。
- データ再利用と拡張性: 適合。保存処理は変えず、UI 文言のみ改善する。

## Project Structure

### Documentation (this feature)

```text
specs/020-next-register-copy/
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
│   └── features/
│       └── weekly_shopping_list/
│           └── presentation/
│               ├── item_add_destination.dart
│               └── item_entry_form.dart
└── test/
    └── widget_test.dart
```

**Structure Decision**: この変更は商品追加画面の表示文言だけに閉じ込める。画面実装と widget テストのみを更新し、保存データやドメイン層には触れない。

## Phase 0: Research Results

- 既存の連続追加動作は維持し、名前と補足だけを変える。
- ボタン名は「次も登録」にすると、保存して次に進む意図が短く伝わる。
- 補足文はボタンの意味を補強し、ボタン単体よりも誤解を減らす。
- 表示位置は変えず、既存の操作導線を維持するのが最も安全である。

## Phase 1: Design & Data Model

- 連続登録ボタンの表示ラベルを「次も登録」に変更する。
- ボタンの直下に小さな補足文「保存して続けて入力できます」を追加する。
- 既存の通常登録ボタンと続けて登録ボタンの役割分担は維持する。
- widget テストでラベルと補足の表示を確認できるようにする。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。データ層や永続化の変更はなく、文言と補足の UI 更新だけで完了する。
