# Implementation Plan: 商品追加画面の料理メニュー編集

**Branch**: `025-edit-meal-menu` | **Date**: 2026-05-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/025-edit-meal-menu/spec.md`

## Summary

商品追加画面で表示済みの料理メニューにペンアイコンを追加し、タップした 1 件だけを編集できるようにする。既存の料理メニュー入力フローと同じ bottom sheet を再利用し、保存時は既存の `meal_menu_entries` の 1 行だけを更新して、同じ日付・同じ区分・同じ並び順を維持する。

## Technical Context

**Language/Version**: Dart 3.11.5 / Flutter
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, flutter_test
**Storage**: local SQLite via Drift
**Testing**: `flutter analyze`, `flutter test`
**Target Platform**: Flutter mobile app (Android/iOS; existing desktop/web targets remain buildable)
**Project Type**: mobile-app
**Performance Goals**: 1 件の料理メニュー編集を、画面遷移を増やさず即時に開始して、保存結果を遅延なく反映する
**Constraints**: offline-capable local storage; no schema changes unless required by the edit flow; preserve current day/week isolation and read-only previous-week behavior
**Scale/Scope**: `weekly_shopping_list` feature 内の単一画面変更と、その保存先 repository の拡張

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合
- 品質ゲート: 適合
- 技術スタック固定: 適合
- 買い物体験の最優先事項: 適合
- データ再利用と拡張性: 適合

## Project Structure

### Documentation (this feature)

```text
specs/025-edit-meal-menu/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── tasks.md
```

### Source Code (repository root)

```text
weekly_buyer/lib/
├── app/
│   └── app_state_providers.dart
└── features/weekly_shopping_list/
    ├── data/
    │   └── weekly_shopping_repository.dart
    ├── domain/
    │   └── weekly_shopping_models.dart
    └── presentation/
        ├── item_add_destination.dart
        └── item_entry_form.dart

weekly_buyer/test/
├── repository/
└── widget/
```

**Structure Decision**: 変更は既存の `weekly_shopping_list` feature に閉じ込める。UI は `item_add_destination.dart` と `item_entry_form.dart` を中心に編集導線を追加し、永続化は `weekly_shopping_repository.dart` の update API 追加で対応する。新しい契約層は不要で、検証は既存の repository / widget テスト群に寄せる。

## Phase 0: Research Results

- 料理メニューの編集は、新しいデータ構造を増やさず既存の `meal_menu_entries` 1 行を更新するのが最小である。
- 既存の `MealMenuAddSheet` は、初期テキストとラベルを受け取れる形に拡張すれば編集フォームとして再利用できる。
- 編集対象はペンアイコンを押した 1 件に限定し、同じ日付・同じ区分の他メニューには触れない。
- 空文字や空白だけの入力は、既存値の上書きとして扱わない。
- 以前の週を表示中の read-only 状態では、編集導線も無効のままにする。

## Phase 1: Design & Data Model

- `MealMenuEntry` は既存の永続エンティティをそのまま使い、編集では `id` をキーに `menuText` と `updatedAt` を更新する。
- UI 側には、編集中の対象 ID と初期テキストを保持する一時状態を追加し、保存後またはキャンセル後に破棄する。
- `item_add_destination.dart` のメニュー行にペンアイコンを追加し、タップ時に対象エントリの編集シートを開く。
- `item_entry_form.dart` の bottom sheet は、追加/編集のどちらにも使えるように初期値と文言を受け取る形へ寄せる。
- 既存の登録フローと同じく、保存後はその日の料理メニュー一覧を再取得して即時反映する。

## Phase 1 Re-check

- 日本語ファースト: 適合
- 品質ゲート: 適合
- 技術スタック固定: 適合
- 買い物体験の最優先事項: 適合
- データ再利用と拡張性: 適合

## Complexity Tracking

不要。既存のローカル保存と UI の接続を拡張するだけで、外部同期や新規スキーマ追加は不要。
