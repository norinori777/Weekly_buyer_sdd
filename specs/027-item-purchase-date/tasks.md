# Tasks: 商品への購入日設定

**Input**: Design documents from `/specs/027-item-purchase-date/`  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Data Model**: [data-model.md](data-model.md) | **Research**: [research.md](research.md) | **Quickstart**: [quickstart.md](quickstart.md)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: 並列実行可能（別ファイル、未完了タスクへの依存なし）
- **[Story]**: 対応するユーザーストーリー（US1/US2/US3）
- ファイルパスは各タスクに明記

---

## Phase 1: Setup（共通インフラ確認）

**Purpose**: 実装開始前のベースライン確認。既存プロジェクトのため新規セットアップは不要

- [X] T001 既存テストが PASS することをベースラインとして確認する（`cd weekly_buyer; flutter test`）

---

## Phase 2: Foundational（すべての US に共通するブロッキング前提条件）

**Purpose**: DB スキーマ・ドメインモデル・状態・リポジトリの更新。全 3 ストーリーの前提となるため、Phase 3 以降の作業開始前に完了必須

**⚠️ CRITICAL**: Phase 2 が完了するまで US1/US2/US3 の実装は開始できない

- [X] T002 `WeeklyListItems` テーブルに `purchaseDate` nullable カラムを追加し、`schemaVersion` を 5 → 6 に変更し、`onUpgrade` に case 6 のマイグレーション処理を追加する（`weekly_buyer/lib/app/app_database.dart`）
- [X] T003 `ShoppingItemEntry` に `final DateTime? purchaseDate` フィールドを追加し、コンストラクタと `copyWith` を更新する（`weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`）
- [X] T004 `AddItemRequest` に `final DateTime? purchaseDate` フィールドを追加する（`weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`）
- [X] T005 `formatPurchaseDate(DateTime date)` ユーティリティ関数をファイル末尾に追加する（`weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`）
- [X] T006 [P] `ItemAddDraft` に `final DateTime? purchaseDate` フィールドを追加し、コンストラクタと `copyWith` を更新する（`weekly_buyer/lib/app/app_state_providers.dart`）
- [X] T007 `addItem` メソッドの `WeeklyListItemsCompanion.insert` に `purchaseDate: Value(request.purchaseDate)` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T008 `_loadWeeklyListItems` の `ShoppingItemEntry` マッピングに `purchaseDate: item.purchaseDate` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T009 `undoLatestPurchase` の `ShoppingItemEntry` 生成箇所に `purchaseDate: row.purchaseDate` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T010 Drift コード生成を実行して `app_database.g.dart` を再生成する（`cd weekly_buyer; dart run build_runner build --delete-conflicting-outputs`）

**Checkpoint**: Phase 2 完了 — DB・ドメイン・状態・リポジトリがすべて `purchaseDate` に対応。US1/US2/US3 の実装を開始可能

---

## Phase 3: User Story 1 — 商品追加時に購入日を選択する（Priority: P1）🎯 MVP

**Goal**: 商品追加フォームに任意の購入日フィールドを追加し、カレンダーから日付選択・× クリアができる

**Independent Test**: 商品追加画面の「商品を追加」ボタンからフォームを開き、購入日フィールドがフォーム最後（数量の下）に表示されることを確認。タップでカレンダーが開き、日付選択後に `M月D日` 形式で表示され × ボタンが出ること。購入日なしでも商品登録できること

### Implementation for User Story 1

- [X] T011 [US1] `_ItemEntryFormState` に `DateTime? _purchaseDate` 状態変数を追加し、`initState` で `widget.initialValue.purchaseDate` から初期化する（`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`）
- [X] T012 [US1] 数量フィールドの直後に購入日フィールドを追加する。`GestureDetector` + `AbsorbPointer` + `TextFormField` で構成し、`InputDecoration` の `labelText` を `'購入日（任意）'`、`suffixIcon` を `_purchaseDate != null` のときのみ × アイコン `IconButton` として表示し、タップ時に `showDatePicker` を呼び出す（`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`）
- [X] T013 [US1] `_purchaseDate` が変化したタイミングで `widget.onChanged` に `ItemAddDraft.copyWith(purchaseDate: _purchaseDate)` を渡して上位の `itemAddDraftProvider` を更新する（`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`）
- [X] T014 [US1] `_buildSubmitRequest` 相当の `AddItemRequest` 生成箇所（`onSubmit` および `onContinueAdd` の呼び出し部分）に `purchaseDate: _purchaseDate` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`）

**Checkpoint**: Phase 3 完了 — フォームで購入日を入力・クリアでき、登録時に DB へ保存される（US1 独立テスト可能）

---

## Phase 4: User Story 2 — 商品追加画面のリストで購入日を確認する（Priority: P2）

**Goal**: 商品追加画面の各セクションカードの商品リストで、購入日が設定されている場合は数量の横に `M月D日` を表示する

**Independent Test**: 購入日あり・なしの商品をそれぞれ追加後に商品追加画面を開き、購入日ありの商品のサブタイトルが `数量 X　M月D日` 形式で表示され、なしの場合は `数量 X` のみ表示されることを確認する

### Implementation for User Story 2

- [X] T015 [P] [US2] `_SectionPreviewCard` 内の `ListTile` の `subtitle` を、`item.purchaseDate != null` の場合は `'数量 ${item.quantity}　${formatPurchaseDate(item.purchaseDate!)}'`、null の場合は `'数量 ${item.quantity}'` を表示するよう更新する（`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`）

**Checkpoint**: Phase 4 完了 — 商品追加画面リストで購入日の条件表示が動作する（US2 独立テスト可能）

---

## Phase 5: User Story 3 — 購入リスト画面で購入日を確認する（Priority: P3）

**Goal**: 購入リスト画面の商品タイルで、購入日が設定されている場合は数量の横に `M月D日` を表示する

**Independent Test**: 購入リスト画面を開き、購入日あり・なしの商品それぞれのサブタイトルが US2 と同様の条件で表示されることを確認する

### Implementation for User Story 3

- [X] T016 [P] [US3] `_PurchaseItemTile` の `ListTile` の `subtitle` を、`item.purchaseDate != null` の場合は `'数量 ${item.quantity}　${formatPurchaseDate(item.purchaseDate!)}'`、null の場合は `'数量 ${item.quantity}'` を表示するよう更新する（`weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`）

**Checkpoint**: Phase 5 完了 — すべての 3 ストーリーが独立して動作する

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: 静的解析・テスト実行による品質確認

- [X] T017 [P] `flutter analyze` を実行してエラー・警告がゼロであることを確認する（`cd weekly_buyer; flutter analyze`）
- [X] T018 `flutter test` を実行してすべてのテストが PASS することを確認する（`cd weekly_buyer; flutter test`）
- [X] T019 [P] quickstart.md の検証チェックリストを手動で確認する（`specs/027-item-purchase-date/quickstart.md` の検証チェックリストセクション）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし — 即時開始可能
- **Foundational (Phase 2)**: Phase 1 完了後 — **US1/US2/US3 すべてをブロック**
- **User Story 1 (Phase 3)**: Phase 2 完了後 — US2/US3 に依存しない（並列開始可能）
- **User Story 2 (Phase 4)**: Phase 2 完了後 — US1 とは独立（並列開始可能）
- **User Story 3 (Phase 5)**: Phase 2 完了後 — US1/US2 とは独立（並列開始可能）
- **Polish (Phase 6)**: Phase 3/4/5 すべて完了後

### User Story Dependencies

- **US1 (P1)**: Phase 2 完了後に開始可能 — 他の US に依存しない
- **US2 (P2)**: Phase 2 完了後に開始可能 — US1 とは独立して実装・テスト可能
- **US3 (P3)**: Phase 2 完了後に開始可能 — US1/US2 とは独立して実装・テスト可能

### Within Phase 2 (Foundational)

```
T002 (DB schema) → T010 (codegen)   # sequentialT003, T004, T005 (domain models)    # can run in parallel after T002
T006 (state model)                   # parallel with T003-T005
T007, T008, T009 (repository)        # after T003, T004 (need domain types)
```

### Parallel Opportunities

- T003, T004, T005 は同一ファイル内だが順次編集として扱う
- T006 は T003/T004 と別ファイルのため並列可能
- T015（US2）と T016（US3）は別ファイルのため並列実行可能 [P] マーク済み
- T017 と T019 は並列実行可能

---

## Parallel Example: User Story 2 & 3（Phase 4/5）

Phase 2 完了後、US2 と US3 は異なるファイルのため並列実装可能：

```
Phase 2 完了
    ├── [並列] T015 [US2] item_add_destination.dart を更新
    └── [並列] T016 [US3] purchase_list_destination.dart を更新
           ↓
    T017 analyze / T018 test / T019 quickstart チェック
```

---

## Implementation Strategy

**MVP スコープ**: Phase 2（Foundational）+ Phase 3（US1）のみで、購入日の入力・保存が動作する最小実装が完成する。US2/US3 はその後に追加できる。

**推奨実装順序**（1名で作業する場合）:

```
T001 → T002 → T003 → T004 → T005 → T006 → T007 → T008 → T009 → T010
→ T011 → T012 → T013 → T014   # US1
→ T015                          # US2
→ T016                          # US3
→ T017 → T018 → T019           # Polish
```

**各タスクの粒度**: 1タスク = 1ファイルの1箇所の変更。LLM が追加コンテキストなしに完了できる粒度を維持している。
