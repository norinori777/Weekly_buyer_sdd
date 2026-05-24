# Implementation Plan: 購入リスト画面カテゴリ内商品のひらがな順ソート

**Branch**: `028-category-item-hiragana-sort` | **Date**: 2026-05-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/028-category-item-hiragana-sort/spec.md`

## Summary

購入リスト画面の各カテゴリ内で、商品を `item_masters.hiragana` 昇順（カタカナはひらがなに正規化、未設定は末尾）で表示する。DB スキーマ変更なし。`ShoppingItemEntry` に `hiragana` フィールドを追加し、`_groupEntriesByCategory` でアプリ層ソートを実施する。

## Technical Context

**Language/Version**: Dart 3.x
**Primary Dependencies**: Flutter 3.x (Material 3), Riverpod 2.x, Drift 2.x
**Storage**: SQLite via Drift（ローカルのみ）
**Testing**: flutter_test
**Target Platform**: Android / iOS
**Project Type**: Mobile app
**Performance Goals**: リスト表示は既存と同等（60fps）
**Constraints**: オフライン動作必須、DB スキーマ変更なし（`item_masters.hiragana` は既存カラム）
**Scale/Scope**: 既存機能への最小限の追加変更。新規ファイルは追加しない

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 評価 | 根拠 |
|------|------|------|
| I. 日本語ファースト | ✅ PASS | 仕様・設計は日本語。UIラベルへの変更なし |
| II. 品質ゲート | ✅ PASS | 受け入れ基準はスペックに明記。既存 CI に従いテスト追加 |
| III. 技術スタック固定 | ✅ PASS | Flutter/Material 3・Drift・Riverpod を使用。外部ライブラリ追加なし |
| IV. 買い物体験最優先 | ✅ PASS | ソートは自動適用。ユーザーの追加操作ゼロ |
| V. データ再利用と拡張性 | ✅ PASS | 既存 `hiragana` フィールドを再利用。スキーマ変更なし |

**Gate result**: PASS — すべての原則に適合（Phase 1 設計後も変わらず）

## Project Structure

### Documentation (this feature)

```text
specs/028-category-item-hiragana-sort/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (変更対象ファイル)

```text
weekly_buyer/lib/
└── features/weekly_shopping_list/
    ├── domain/
    │   └── weekly_shopping_models.dart   # ShoppingItemEntry に hiragana フィールド追加
    └── data/
        └── weekly_shopping_repository.dart  # loadWeek でひらがな設定、
                                             # _groupEntriesByCategory でソート追加

weekly_buyer/test/
└── repository_test.dart   # カテゴリ内ひらがな順ソートの integration test 追加
```

**Structure Decision**: 既存の単一プロジェクト構成を維持。新規ファイルは追加しない。

## Complexity Tracking

> 憲法違反なし — このセクションは記入不要
