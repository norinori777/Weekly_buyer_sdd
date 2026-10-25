---
description: "購入リストへの使用日表示の実装タスク"
---

# Tasks: 購入リストへの使用日表示

**Input**: `specs/029-usage-date-display/` の設計資料  
**実装ブランチ**: `029-display-product-usage-dates`  
**Prerequisites**: `plan.md`、`spec.md`、`research.md`、`data-model.md`、`quickstart.md`

**Tests**: 必須。日付導出・書式と購入リスト行の回帰を `flutter_test` で検証する。

**Organization**: `spec.md` の優先度順にユーザーストーリー単位で実装・検証する。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 別ファイルを扱い、未完了タスクに依存せず並列実行できるタスクのみ。
- **[Story]**: ユーザーストーリータスクにのみ `[US1]`、`[US2]` を付与する。
- 各タスクの説明にリポジトリルートからの具体的なファイルパスを記載する。

## Path Conventions

- Flutter アプリ: `weekly_buyer/lib/` および `weekly_buyer/test/`
- 本機能の設計資料: `specs/029-usage-date-display/`
- 商品追加画面、Repository、DB スキーマ、`pubspec.yaml` は変更しない。新規依存・永続化・マイグレーションは不要。

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 既存プロジェクトのため、新たな初期化や共有インフラ設定は不要。Flutter/Drift/Riverpod のプロジェクト構成とテスト基盤は既に存在し、対象の設計資料は `specs/029-usage-date-display/plan.md` に定義済み。

**Tasks**: なし。プロジェクト初期化、DB マイグレーション、新規依存の追加は行わない。

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: 全ストーリーを止める共通基盤タスクはない。既存の `ShoppingItemEntry.weekday`、`purchaseDate`、`WeekRange` と `flutter_test` をそのまま利用する。

**Tasks**: なし。共通モデルの新設や Repository/DB の変更は行わない。

**Checkpoint**: 追加の基盤作業なしでユーザーストーリーのテストと実装を開始できる。

---

## Phase 3: User Story 1 - 購入日と使用日を確認する (Priority: P1) 🎯 MVP

**Goal**: 購入リストの商品行に、購入日と対象週（月曜日〜日曜日）の使用日を「購入日:MM/DD(曜日) 使用日:MM/DD(曜日)」の順で、日本語の曜日略称付きで表示する。購入日だけ設定されている場合も購入日のラベル・日付・曜日を表示する。

**Independent Test**: 購入日が2026年10月25日、使用曜日が月曜日、対象週が2026年10月26日(月)〜11月1日(日)の商品を表示し、「購入日:10/25(日) 使用日:10/26(月)」の順序・値・日本語ラベルを確認する。購入日だけある商品では「購入日:10/25(日)」のみであることも確認する。

### Tests for User Story 1

- [X] T001 [P] [US1] `weekly_buyer/test/weekly_shopping_models_test.dart` に購入日・使用日の書式テストを追加し、購入日自身の曜日、日本語曜日略称、MM/DDゼロ埋め、月またぎ週の月曜・日曜の導出を検証する。
- [X] T002 [P] [US1] `weekly_buyer/test/widget_test.dart` に購入リスト行の回帰テストを追加し、購入日と使用日の併記順「購入日:10/25(日) 使用日:10/26(月)」および購入日だけの場合の表示を検証する。

### Implementation for User Story 1

- [X] T003 [US1] `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` に購入リスト専用の日付導出・表示ヘルパーを追加し、既存の `formatPurchaseDate` を変更せず購入日と対象週の使用日を「購入日→使用日」順に整形する（T001 のテストに対応）。
- [X] T004 [US1] `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` でスナップショットの対象 `WeekRange` を商品行まで渡し、既存の数量表示を保ちながら購入リスト専用ヘルパーの日付表示を行へ追加する（T002、T003 に依存）。

**Checkpoint**: 購入日と使用日が設定された商品の併記、および購入日だけの表示を独立して確認できる。

---

## Phase 4: User Story 2 - 使用日を確認する (Priority: P2)

**Goal**: 購入日がない場合は使用日だけを表示し、使用曜日がない商品には使用日ラベルや推測した日付を表示しない。対象週の日曜日、月初、月またぎも対象週の日付と暦上の曜日に一致させる。

**Independent Test**: 対象週が2026年10月26日(月)〜11月1日(日)のとき、購入日なし・使用曜日月曜の商品で「使用日:10/26(月)」のみ、日曜の商品で「使用日:11/01(日)」を確認する。使用曜日なし（曜日に依存しない商品を含む）では使用日表示がないことを確認する。

### Tests for User Story 2

- [X] T005 [P] [US2] `weekly_buyer/test/weekly_shopping_models_test.dart` に購入日なしの使用日単独表示と、未設定・範囲外曜日または日付非依存セクションで使用日を導出しないテストを追加する（US1 の T003 に依存）。
- [X] T006 [P] [US2] `weekly_buyer/test/widget_test.dart` に購入日なしの月曜使用日「使用日:10/26(月)」、対象週の日曜「使用日:11/01(日)」、および使用曜日なしで使用日ラベルがない購入リスト行のテストを追加する（US1 の T004 に依存）。

### Implementation for User Story 2

- [X] T007 [US2] `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` の使用日導出で、曜日非依存セクションと月曜〜日曜以外の曜日値を拒否し、購入日が null の場合にも有効な使用日だけを整形する（T005 に対応）。
- [X] T008 [US2] `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` で日付情報が空の場合に日付ラベルを描画せず、購入日なしでは有効な使用日だけが表示されることを保証する（T006、T007 に依存）。

**Checkpoint**: 購入日がない商品の使用日単独表示と、使用曜日がない商品の非表示を独立して確認できる。

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 変更範囲を購入リスト表示に保ち、関連テストと静的解析で回帰を確認する。

- [X] T009 `weekly_buyer/test/weekly_shopping_models_test.dart` と `weekly_buyer/test/widget_test.dart` に対し、`weekly_buyer/` で `flutter test test/weekly_shopping_models_test.dart test/widget_test.dart`、`flutter analyze`、`dart format --output=none --set-exit-if-changed lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` を実行して検証結果を確認する。

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: タスクなし。既存プロジェクトを利用するため初期化は不要。
- **Foundational (Phase 2)**: タスクなし。追加基盤は不要で、既存モデル・週範囲・テスト環境を再利用する。
- **User Stories**: US1 は共通基盤に依存せず開始可能。US2 は US1 が追加する日付ヘルパーと購入リスト行を拡張するため、US1 の T003・T004 完了後に開始する。
- **Polish (Phase 5)**: T001〜T008 の実装・テスト完了後に実行する。

### User Story Dependencies

- **User Story 1 (P1)**: Setup/Foundation の追加タスクなしで開始可能。他ストーリーへの依存なし。
- **User Story 2 (P2)**: US1 の日付導出ヘルパーと行への `WeekRange` 受け渡しを利用するため、T003・T004 に依存する。機能範囲を独立して確認するテストは US2 に含める。

### Within Each User Story

- US1 のモデルテスト T001 と行ウィジェットテスト T002 は別ファイルのため並列実行可能。実装 T003 は T001 後、T004 は T002・T003 後に行う。
- US2 のテスト T005・T006 はそれぞれモデルテストとウィジェットテストであり、US1 の実装完了後に並列実行可能。実装 T007 は T005 後、T008 は T006・T007 後に行う。
- 商品追加画面の `formatPurchaseDate`、Repository、DB スキーマ、`pubspec.yaml` はこの機能で変更しない。

### Parallel Opportunities

- US1: T001 と T002 は異なるテストファイルのため並列実行可能。
- US2: T005 と T006 は異なるテストファイルのため、US1 完了後に並列実行可能。
- 仕様上のストーリー間に共有実装依存があるため、US1 と US2 の実装フェーズ自体は並列化しない。

## Parallel Example: User Story 1

```text
並列実行:
Task T001: weekly_buyer/test/weekly_shopping_models_test.dart の導出・書式テスト
Task T002: weekly_buyer/test/widget_test.dart の購入日・使用日表示テスト

順次実行:
T001 完了後に T003、T002 と T003 の完了後に T004
```

## Parallel Example: User Story 2

```text
US1 の T003・T004 完了後に並列実行:
Task T005: weekly_buyer/test/weekly_shopping_models_test.dart の使用日単独・曜日なしテスト
Task T006: weekly_buyer/test/widget_test.dart の使用日単独・曜日なし行テスト

順次実行:
T005 完了後に T007、T006 と T007 の完了後に T008
```

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1・2 は既存構成の再利用を確認し、初期化・基盤タスクなしで進める。
2. Phase 3 の T001〜T004 を実行し、購入日・使用日の併記と購入日単独表示を完成させる。
3. **STOP and VALIDATE**: US1 のテストを実行し、購入日先行、日本語曜日、ゼロ埋め、月またぎの対象週日付を確認する。
4. US1 を MVP として提示可能な状態にした後、Phase 4 で使用日単独・曜日なしのケースを追加する。
5. T009 で関連テスト・静的解析・整形を確認する。
