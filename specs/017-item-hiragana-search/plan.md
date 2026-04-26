# Implementation Plan: 商品名のひらがな候補表示

**Branch**: `017-item-hiragana-search` | **Date**: 2026-04-25 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/017-item-hiragana-search/spec.md`

## Summary

商品マスタにひらがな項目を追加し、設定画面の商品編集では商品名とひらがなをセットで登録できるようにする。商品登録画面では商品名とひらがなの両方を候補検索に使い、同じ商品を重複表示しない。既存の商品名検索は維持し、ひらがなが未登録の既存データも段階的に扱えるようにする。

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, build_runner  
**Storage**: Local SQLite via Drift, with a schema migration that adds a nullable hiragana column to the item master table  
**Testing**: flutter analyze, flutter test, repository tests, widget tests  
**Target Platform**: Flutter mobile app targets used by the existing workspace  
**Project Type**: Mobile app  
**Performance Goals**: 商品候補の表示と設定画面の保存が、通常の入力操作に対して即時に反映されること  
**Constraints**: Offline-first, local-only persistence, backward compatibility for existing items without hiragana, search must match name and hiragana, duplicate suggestions must be suppressed  
**Scale/Scope**: 単一 Flutter アプリ内の設定画面と商品登録画面

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- 日本語ファースト: 適合。成果物は日本語で記述する。
- 品質ゲート: 適合。登録必須条件と候補表示条件を明示する。
- 技術スタック固定: 適合。Flutter / Riverpod / Drift の既存構成を維持する。
- 買い物体験の最優先事項: 適合。商品登録時の候補探索を強化し、入力負荷を減らす。
- データ再利用と拡張性: 適合。既存商品を壊さず、読み追加を段階導入できる。

## Project Structure

### Documentation (this feature)

```text
specs/017-item-hiragana-search/
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
│   │   ├── app_database.dart
│   │   ├── app_database.g.dart
│   │   └── providers.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── data/
│           │   └── weekly_shopping_repository.dart
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── category_item_settings_destination.dart
│               ├── category_item_settings_notifier.dart
│               ├── item_add_destination.dart
│               ├── item_editor_destination.dart
│               └── item_entry_form.dart
└── test/
    ├── repository_test.dart
    ├── widget_test.dart
    └── category_item_settings_test.dart
```

**Structure Decision**: 既存の `weekly_shopping_list` feature に機能を集約する。商品マスタのひらがな追加は `app_database.dart` と repository / domain の拡張で扱い、設定画面の入力欄と商品登録画面の候補表示は presentation 層に閉じ込める。回帰確認は repository テストと widget テストで分ける。

## Phase 0: Research Results

- 商品マスタにひらがな列を追加し、既存データは null 許容で保持する。
- 設定画面では商品の追加・編集時にひらがな入力を必須にする。
- 商品登録画面では商品名とひらがなの両方を検索対象とし、同一商品は 1 件にまとめる。
- 既存の商品名検索は維持し、ひらがなが未登録の商品も商品名検索で引き続き候補に出す。
- 候補一覧は検索語に対して部分一致し、商品マスタ ID を基準に重複を除去する。

## Phase 1: Design & Data Model

- `ItemCandidate` にひらがな表示用の値を追加する。
- `weekly_shopping_repository.dart` にひらがな付きの add / update / search ロジックを追加する。
- `category_item_settings_notifier.dart` と `item_editor_destination.dart` にひらがな入力の受け渡しを追加する。
- `item_entry_form.dart` の候補検索を商品名とひらがなの両方に対応させる。
- Drift スキーマに対してマイグレーション手順を追加し、既存行はそのまま読めるようにする。

## Phase 1 Re-check

- 日本語ファースト: 適合。
- 品質ゲート: 適合。
- 技術スタック固定: 適合。
- 買い物体験の最優先事項: 適合。
- データ再利用と拡張性: 適合。

## Complexity Tracking

不要。新しい永続化列の追加は必要だが、既存のアプリ構成内で収まる範囲であり、外部サービスや新規基盤は不要。
