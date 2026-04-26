# Implementation Plan: 商品名音声入力

**Branch**: `022-item-name-voice-input` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/022-item-name-voice-input/spec.md`

## Summary

商品追加画面の入力フォームにある商品名欄へ、音声で入力した内容を反映できるようにする。手入力は常時残しつつ、音声入力の結果は編集可能なテキストとして商品名欄へ戻し、保存前に確認・修正できる流れにする。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, existing item add form widgets  
**Storage**: 既存のローカル SQLite 永続化をそのまま利用し、データモデル変更は不要  
**Testing**: flutter analyze, flutter test, widget test focused on item add form and voice-input flow  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: mobile-app  
**Performance Goals**: 音声入力開始から商品名欄への反映までが自然に感じられ、追加操作の流れを中断しないこと  
**Constraints**: 商品名欄のみが対象、手入力は維持、既存の週・曜日文脈や保存処理は壊さない  
**Scale/Scope**: 単一 Flutter アプリ内の商品追加画面の入力フォームに限定

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。計画・設計成果物は日本語で記述する。
- 品質ゲート: 適合。音声入力の成功・失敗・手入力継続を受け入れ基準に含める。
- 技術スタック固定: 適合。既存の Flutter / Riverpod / Drift 構成を維持する。
- 買い物体験の最優先事項: 適合。商品追加画面内で完結し、入力の手数を減らす。
- データ再利用と拡張性: 適合。保存モデルは変えず、商品名欄の入力導線だけを拡張する。

## Project Structure

### Documentation (this feature)

```text
specs/022-item-name-voice-input/
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
│           ├── data/
│           │   └── weekly_shopping_repository.dart
│           └── presentation/
│               ├── item_add_destination.dart
│               └── item_entry_form.dart
└── test/
    └── widget_test.dart
```

**Structure Decision**: 変更は商品追加画面とそのフォームに閉じ込める。音声入力の開始点と認識結果の反映は `item_entry_form.dart` 側で扱い、画面遷移や保存先の変更は行わない。検証は `widget_test.dart` に音声入力の有無と商品名欄の編集可能性を確認するケースを追加する。

## Phase 0: Research Results

- 商品名欄は既存のテキスト入力として実装されているため、音声入力の結果をそのまま反映する追加導線で対応できる。
- 手入力による商品名入力は現状のまま維持し、音声入力が使えない端末や状況でも操作を止めないのが最も安全である。
- 音声認識結果は編集可能なテキストとして扱い、保存前にユーザーが確認できる形にするのが自然である。
- 商品名以外の数量・区分などの入力ロジックは変更対象にしない。

## Phase 1: Design & Data Model

- 商品名欄の近くに音声入力の起点を追加し、開始後は認識結果を商品名欄へ反映する。
- 音声入力が失敗・キャンセルされた場合でも、既存の入力値を保持し、フォームの状態を壊さない。
- 認識結果は通常の文字列として扱い、ユーザーがその場で編集できるようにする。
- 既存の保存処理はそのまま利用し、音声入力は保存前の入力補助としてのみ扱う。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。データスキーマ変更はなく、主な作業は入力フォームの UI と状態遷移の拡張に限定される。