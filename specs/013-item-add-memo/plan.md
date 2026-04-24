# Implementation Plan: 商品追加画面メモ

**Branch**: `013-item-add-memo` | **Date**: 2026-04-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/013-item-add-memo/spec.md`

## Summary

商品追加画面に、その日の私用メモを入力・編集・保存できるようにする。メモは選択中の日付にひも付く独立した日次情報として扱い、購入リスト画面には表示しない。既存の週選択状態をそのまま使い、商品登録の導線を崩さずに同じ画面内へメモ入力欄を追加する。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift, with a dedicated day-memo table added to the existing weekly schema  
**Testing**: flutter analyze, flutter test, repository tests, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: メモの表示・保存・日付切り替えが即時に反映されること  
**Constraints**: Offline-first, local-only persistence, private memo must never surface on the purchase list, existing week selection behavior must remain stable  
**Scale/Scope**: 単一 Flutter アプリ内の週次買い物画面と商品追加画面

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。日次メモの保存、編集、非表示の受け入れ基準を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。商品追加の流れを壊さず、同じ画面内でメモを扱う。
- データ再利用と拡張性: 適合。既存の週選択状態を再利用し、日次メモは独立した保存対象として追加する。

## Project Structure

### Documentation (this feature)

```text
specs/013-item-add-memo/
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
│               ├── weekly_shopping_page.dart
│               └── week_header.dart
└── test/
    ├── repository_test.dart
    ├── widget_test.dart
    └── category_item_settings_test.dart
```

**Structure Decision**: 日次メモは既存の `weekly_shopping_list` feature に統合する。週の選択状態は `lib/app/app_state_providers.dart` の共通状態を使い、入力 UI は `item_add_destination.dart` と `item_entry_form.dart` に追加する。永続化は `weekly_shopping_repository.dart` と `weekly_shopping_models.dart` を拡張し、検証は `test/repository_test.dart` と `test/widget_test.dart` を中心に行う。

## Phase 0: Research Results

- 日次メモは商品データと分離した独立エンティティにする。購入リストに紛れ込ませないため、商品行へ追記する方式は採用しない。
- メモの対象日は既存の `selectedWeekDateProvider` で決まる。週移動や日付切り替えの文脈と一致させることで、別週への誤保存を防ぐ。
- 商品追加画面の UI は、既存の入力フォームにメモ欄を追加する。画面遷移を増やさず、商品登録と同じ導線で完結させる。
- 保存と再表示の確認は repository テストと widget テストに分ける。日付ごとの保存状態は repository、画面表示と非表示は widget で検証する。

## Phase 1: Design & Data Model

- `DailyMemo` を新規のドメインエンティティとして定義する。
- 保存キーは「週の開始日 + 曜日」を基本にして、同じ週の同じ日に 1 件だけ保持する。
- repository は `loadWeek` の返却に日次メモを含めるか、日付単位で個別取得できる API を提供する。
- 画面側は、選択中の日付に応じてメモを読み出し、編集後は即座に保存する。
- 購入リスト画面ではメモを参照せず、表示対象にも含めない。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。既存の週選択状態とローカル保存を拡張するだけで、追加の外部依存や複雑な移行は不要。
