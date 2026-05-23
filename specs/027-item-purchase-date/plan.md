# Implementation Plan: 商品への購入日設定

**Branch**: `027-item-purchase-date` | **Date**: 2026-05-23 | **Spec**: [spec.md](spec.md)  
**Input**: Feature specification from `/specs/027-item-purchase-date/spec.md`

## Summary

商品追加フォームにカレンダー日付ピッカー（購入日・任意）を追加し、商品追加画面と購入リスト画面の商品数量横に `M月D日` 形式で購入日を表示する。既存の Drift スキーマ (`WeeklyListItems`) に nullable な `purchaseDate` カラムを追加し、ドメインモデル・状態・リポジトリ・UIの4層すべてを一貫して更新する。

## Technical Context

**Language/Version**: Dart 3.x  
**Primary Dependencies**: Flutter 3.x (Material 3), Riverpod 2.x, Drift 2.x  
**Storage**: SQLite via Drift（ローカルのみ）  
**Testing**: flutter_test  
**Target Platform**: Android / iOS  
**Project Type**: Mobile app  
**Performance Goals**: リスト表示は既存と同等（60fps）  
**Constraints**: オフライン動作必須、スキーマ移行で既存データを破壊しない  
**Scale/Scope**: 既存機能への最小限の追加変更。新規ファイルは不要

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| 原則 | 評価 | 根拠 |
|------|------|------|
| I. 日本語ファースト | ✅ PASS | 仕様・設計は日本語。UIラベルは日本語（`購入日`、`M月D日`）|
| II. 品質ゲート | ✅ PASS | 受け入れ基準はスペックに明記。テスト・Lint は既存 CI に従う |
| III. 技術スタック固定 | ✅ PASS | Flutter/Material 3・Drift・Riverpod を使用。新規ライブラリ追加なし |
| IV. 買い物体験最優先 | ✅ PASS | 購入日は任意項目。入力しなければ追加ステップはゼロ |
| V. データ再利用と拡張性 | ✅ PASS | nullable カラムなので既存データは無変更。拡張しやすい設計 |

**Gate result**: PASS — すべての原則に適合

## Project Structure

### Documentation (this feature)

```text
specs/027-item-purchase-date/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit.tasks command)
```

### Source Code (変更対象ファイル)

```text
weekly_buyer/lib/
├── app/
│   ├── app_database.dart              # WeeklyListItems テーブル + スキーマ移行
│   └── app_state_providers.dart       # ItemAddDraft に purchaseDate 追加
├── features/weekly_shopping_list/
│   ├── domain/
│   │   └── weekly_shopping_models.dart  # AddItemRequest, ShoppingItemEntry に purchaseDate 追加
│   ├── data/
│   │   └── weekly_shopping_repository.dart  # addItem, 読み込みクエリに purchaseDate 対応
│   └── presentation/
│       ├── item_entry_form.dart         # 日付ピッカーフィールド追加
│       ├── item_add_destination.dart    # _SectionPreviewCard のサブタイトル更新
│       └── purchase_list_destination.dart  # _PurchaseItemTile のサブタイトル更新

weekly_buyer/test/
│   # 既存テストの AddItemRequest / ShoppingItemEntry の名前付き引数が増えるため
│   # 影響を受けるテストファイルの修正が必要
```

**Structure Decision**: 既存の単一プロジェクト構成（Option 1）を維持。新規ファイルは追加しない。

## Complexity Tracking

> 憲法違反なし — このセクションは記入不要
