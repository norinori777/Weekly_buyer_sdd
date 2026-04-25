# Implementation Plan: 商品追加画面のメモ自動保存と料理メニュー削除

**Branch**: `021-memo-menu-updates` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/021-memo-menu-updates/spec.md`

## Summary

商品追加画面の私用メモは、クリア/保存ボタンを使わず入力内容をそのまま保持する自動保存に切り替える。あわせて、商品追加画面の料理メニュー一覧に各項目ごとの削除ボタンを追加し、登録済みの料理メニューをその場で個別に取り消せるようにする。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter  
**Storage**: Local SQLite via Drift, existing daily memo and meal-menu tables, no schema change required  
**Testing**: flutter analyze, flutter test, repository tests, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: mobile-app  
**Performance Goals**: 入力中のメモ保存とメニュー削除がすぐ画面に反映され、買い物中の操作を止めないこと  
**Constraints**: Offline-first, local-only persistence, private memo must remain off the purchase list, meal-menu deletion must affect only the selected entry  
**Scale/Scope**: 単一 Flutter アプリ内の商品追加画面のメモと料理メニュー領域

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。仕様・設計・成果物は日本語で記述する。
- 品質ゲート: 適合。自動保存と削除の受け入れ基準を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。商品追加画面の中で完結し、画面遷移を増やさない。
- データ再利用と拡張性: 適合。既存の memo / meal-menu 保存を再利用し、表示と操作だけを拡張する。

## Project Structure

### Documentation (this feature)

```text
specs/021-memo-menu-updates/
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
│   ├── features/
│   │   └── weekly_shopping_list/
│   │       ├── data/
│   │       │   └── weekly_shopping_repository.dart
│   │       └── presentation/
│   │           ├── item_add_destination.dart
│   │           └── item_entry_form.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: 変更は既存の `weekly_shopping_list` feature に閉じ込める。私用メモの自動保存は `item_entry_form.dart` と `item_add_destination.dart` の UI / 状態連携で処理し、料理メニューの削除は既存の `weekly_shopping_repository.dart` の削除 API を呼び出す画面側の導線を追加する。検証は repository と widget に分ける。

## Phase 0: Research Results

- 私用メモは既存の保存 API をそのまま使い、UI から明示的なクリア/保存ボタンを取り除けばよい。
- 料理メニューはすでに個別削除 API があるため、一覧の各行に削除操作を載せれば要件を満たせる。
- 商品追加画面はすでに選択中の日付の文脈を持っているため、保存と削除の対象日を追加で決め直す必要はない。
- 削除後はその日のメニュー一覧を再読み込みして即座に反映するのが最も自然である。

## Phase 1: Design & Data Model

- `DailyMemoEditor` からクリア/保存ボタンを除き、入力変更時の自動保存に切り替える。
- 自動保存後もテキスト入力欄はそのまま残し、ユーザーが続けて編集できるようにする。
- `_SectionPreviewCard` の各料理メニュー行に ✖ ボタンを追加し、押下時にその行だけを削除する。
- 料理メニュー削除後は、そのセクションの表示を再取得して一覧を更新する。
- 既存の read-only 週表示では、削除ボタンが無効になることを維持する。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。新しいデータ構造や外部依存は不要で、既存の保存 API と画面表示の接続を直すだけで実現できる。
