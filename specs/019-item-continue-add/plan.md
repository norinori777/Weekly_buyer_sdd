# Implementation Plan: 商品入力フォームの続けて追加

**Branch**: `019-item-continue-add` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/019-item-continue-add/spec.md`

## Summary

商品追加フォームに「続けて追加」ボタンを追加し、1件登録後もフォームを閉じずに次の商品を連続入力できるようにする。既存の単発登録導線は維持しつつ、商品名と数量の入力欄を狭くしてボタンを同一行に配置し、入力後のリセットと登録完了後の状態遷移を明確に分ける。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift, no schema change required  
**Testing**: flutter analyze, flutter test, widget tests, repository tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 連続追加時にフォームが即時リセットされ、複数件入力の流れが途切れないこと  
**Constraints**: Offline-first, local-only persistence, existing single-save flow must remain available, no data duplication when using continue-add  
**Scale/Scope**: 単一 Flutter アプリ内の商品追加画面とその入力フォーム

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。連続入力と単発登録の両方を明確に分ける。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。複数商品の入力を短時間で終えられる。
- データ再利用と拡張性: 適合。既存の保存処理を流用し、画面状態のみ拡張する。

## Project Structure

### Documentation (this feature)

```text
specs/019-item-continue-add/
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
│               └── item_entry_form.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: 連続追加は既存の `weekly_shopping_list` feature に閉じ込める。保存データは変えず、`item_entry_form.dart` の状態遷移と `item_add_destination.dart` の呼び出し側で「単発登録」と「続けて追加」を分岐する。検証は repository の保存内容確認と widget のフォーム挙動確認に分ける。

## Phase 0: Research Results

- 連続追加に必要なのは新しい保存先ではなく、フォームの送信後状態を保持する UI 挙動である。
- 単発登録の既存導線は残し、連続入力は追加ボタンとして分けるのが分かりやすい。
- ボタンは商品名・数量入力欄の近くに置くことで、入力フローを切らずに使える。
- 追加成功後は入力値をクリアし、次の商品をすぐ入力できる状態に戻す。
- 保存は従来の repository の addItem 処理を再利用し、重複登録や余計な再保存を避ける。

## Phase 1: Design & Data Model

- `ItemEntryForm` に「続けて追加」用の送信アクションを追加する。
- フォームの入力欄レイアウトを調整し、商品名・数量・ボタンが同一視線上で扱えるようにする。
- 連続追加後の入力リセットと単発登録後のフォーム終了を分岐できる状態を整理する。
- `item_add_destination.dart` 側で、フォームの送信結果に応じて閉じるか残すかを制御する。
- `ItemAddDraft` の扱いを見直し、連続追加時に前回値が誤って再投入されないようにする。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。新規ストレージや外部連携は不要で、既存のフォームと保存処理を拡張するだけで実現できる。
