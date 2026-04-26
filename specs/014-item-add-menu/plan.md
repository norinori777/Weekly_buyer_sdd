# Implementation Plan: 商品登録画面の料理メニュー入力

**Branch**: `014-item-add-menu` | **Date**: 2026-04-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/014-item-add-menu/spec.md`

## Summary

商品登録画面の朝・昼・夜セクション右上に追加ボタンを置き、押下時に下からスライドアップする入力フォームでその日の料理メニューを登録できるようにする。メニューは商品データと分離した日次の文脈情報として扱い、購入リスト画面には表示しない。既存の週選択状態と商品登録画面の導線を維持しながら、各セクションの旧来の入力欄・クリアボタン・保存ボタンを廃止し、追加ボタン起点の単一フォーム導線へ置き換える。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift, with daily menu and menu-entry tables added to the existing weekly schema  
**Testing**: flutter analyze, flutter test, repository tests, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 日付切り替えと追加フォームの表示が即時に反映されること  
**Constraints**: Offline-first, local-only persistence, multi-entry per section, slide-up input form, meal menus must never appear on the purchase list  
**Scale/Scope**: 単一 Flutter アプリ内の週次買い物画面と商品登録画面

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。入力・表示・削除・非表示の受け入れ基準を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。商品登録画面の中で完結し、画面遷移を増やさない。
- データ再利用と拡張性: 適合。日次メニューと候補情報を独立した保存対象として扱う。

## Project Structure

### Documentation (this feature)

```text
specs/014-item-add-menu/
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
│   │   ├── app_state_providers.dart
│   │   └── providers.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── data/
│           │   └── weekly_shopping_repository.dart
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── item_add_destination.dart
│               ├── item_entry_form.dart
│               ├── purchase_list_destination.dart
│               ├── weekly_shopping_page.dart
│               └── week_header.dart
└── test/
    ├── repository_test.dart
    ├── widget_test.dart
    └── category_item_settings_test.dart
```

**Structure Decision**: 料理メニュー入力は既存の `weekly_shopping_list` feature に集約する。週の選択状態は `lib/app/app_state_providers.dart` の共通状態を使い、メニューの入力・候補・表示は `item_add_destination.dart` と `item_entry_form.dart` を中心に追加する。永続化は `weekly_shopping_repository.dart` と `weekly_shopping_models.dart` を拡張し、表示非表示の検証は `test/repository_test.dart` と `test/widget_test.dart` に分ける。

## Phase 0: Research Results

- 日次メニューは商品データと分離した独立エンティティにする。買い物リストと役割が異なるため、商品行への追記は採用しない。
- 1日 × 朝・昼・夜の区分で管理し、各区分は複数件のメニューを保持できるようにする。
- メニュー入力は各セクション右上の追加ボタンから下部フォームを開いて行う。
- 旧来の各セクション内テキストボックス、クリアボタン、保存ボタンは廃止する。
- 空の区分は表示しないことで、商品登録画面の情報量を抑える。
- 購入リスト画面にはメニューを参照しないことで、私用情報の混入を防ぐ。
- 検証は repository と widget に分け、保存ロジックと画面ロジックを切り分ける。

## Phase 1: Design & Data Model

- `DailyMealMenu` と `MealMenuEntry` を新規エンティティとして定義する。
- `MealMenuEntry` は `meal_section` と `sort_order` を持ち、同じ区分に複数件を追加できるようにする。
- repository は選択中の日付に対するメニュー一覧の読み書きを担当する。
- 画面側は日付切り替えに追従し、保存済みメニューをセクション見出しの下へ再表示する。
- 購入リスト画面ではメニュー関連のデータを読み込まず、表示対象から除外する。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。既存の週選択状態とローカル保存を拡張するだけで、外部同期や複雑な移行は不要。
