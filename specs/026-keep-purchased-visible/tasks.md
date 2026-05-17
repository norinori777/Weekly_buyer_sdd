# Tasks: 商品追加画面の購入済み商品表示

**Input**: Design documents from `/specs/026-keep-purchased-visible/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: この feature では明示的なテスト作成要求はないため、実装タスクと最終検証タスクのみを含める。

**Organization**: タスクはユーザーストーリー順に整理し、各ストーリーを独立実装・独立検証できる形にする。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 別ファイルで依存関係がないため並列実行可能
- **[Story]**: ユーザーストーリーに対応するラベル（例: US1, US2）
- 説明には必ず実ファイルパスを含める

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 購入済み商品の表示に必要な共通下地を整える

- [X] T001 [P] 購入済み商品を除外しないように、`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` の item-add 用 snapshot 組み立てを見直す
- [X] T002 [P] 購入済み状態から文字色を決める共通ロジックを、`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で再利用できる形に整理する

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: すべてのユーザーストーリーに共通する表示基盤を完成させる

**⚠️ CRITICAL**: このフェーズが終わるまでユーザーストーリー作業を始めない

- [X] T003 [P] `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` で `sections` と `weekdaySections` に購入済み商品も含めるようにし、商品追加画面の一覧から消えないようにする
- [X] T004 [P] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` の `_SectionPreviewCard` で、購入済み商品の商品名と数量に購入済みを示す文字色を適用できるようにする

**Checkpoint**: 購入済み商品が一覧に残り、画面側で色を切り替えられる状態にする

---

## Phase 3: User Story 1 - 購入済み商品を一覧に残して見分けられるようにする (Priority: P1)

**Goal**: 商品追加画面で購入済みになった商品もその場に残し、買い物中に状態を見失わずに確認できるようにする

**Independent Test**: 商品を購入済みに切り替えたあとでも商品追加画面から消えず、同じ場所で状態を確認できる

### Implementation for User Story 1

- [X] T005 [US1] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で、購入済み商品が 1 件だけでも空扱いにせず表示され続けるように section card の空判定を調整する
- [X] T006 [US1] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で、購入済み・未購入が混在したまま section ごとの件数表示と一覧表示が破綻しないことを確認できるようにする

**Checkpoint**: 商品追加画面で購入済み商品が消えずに残る状態を完成させる

---

## Phase 4: User Story 2 - 購入済み商品の見た目を変える (Priority: P1)

**Goal**: 購入済みの商品をひと目で分かるようにして、未購入の商品と区別できるようにする

**Independent Test**: 商品を購入済みに切り替えたあと、商品名と数量の文字色が購入済みを示す色に変わる

### Implementation for User Story 2

- [X] T007 [US2] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` の商品名と数量に、`ShoppingItemEntry.isPurchased` に応じた購入済み色を適用する
- [X] T008 [US2] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で、未購入商品は従来の文字色のまま表示されるようにする

**Checkpoint**: 購入済みと未購入の見た目が商品追加画面で区別できる状態にする

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーにまたがる仕上げと最終確認

- [X] T009 [P] `weekly_buyer/` で `flutter analyze` を実行し、購入済み表示変更後の静的解析を確認する
- [ ] T010 [P] `specs/026-keep-purchased-visible/quickstart.md` の手順で、購入済み商品の表示と色変更を手動確認する

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: すぐ開始できる
- **Foundational (Phase 2)**: Setup 完了後に開始し、全ユーザーストーリーをブロックする
- **User Story 1 (Phase 3)**: Foundational 完了後に開始できる
- **User Story 2 (Phase 4)**: Foundational 完了後に開始できる
- **Polish (Phase 5)**: すべての必要なユーザーストーリー完了後に開始する

### User Story Dependencies

- **User Story 1 (P1)**: 依存なし。購入済み商品を一覧に残す中核機能
- **User Story 2 (P1)**: 依存なし。購入済み商品の視覚的区別

### Within Each User Story

- 取得側で購入済み商品を消さないようにしてから、表示側の色切り替えを入れる
- 空判定や件数表示が購入済み商品を含んでも崩れないことを確認する
- 購入済みと未購入の見た目を分けた後、元に戻す操作で未購入の見た目へ戻ることを確認する

### Parallel Opportunities

- T001 と T002 は別ファイルなので並列に進められる
- T003 と T004 は別ファイルなので並列に進められる
- T009 と T010 は検証作業として並列または順次実施できる

## Implementation Strategy

### MVP First

1. Phase 1 の共有下地を整える
2. Phase 2 で購入済み商品を一覧から消さないようにする
3. Phase 3 で商品追加画面に残り続けることを完成させる
4. Phase 4 で購入済み色の表示を完成させる
5. 最終確認を行う

### Incremental Delivery

1. 購入済み商品を一覧に残す
2. 購入済み商品を色で区別する
3. 手動確認で UI の意図が伝わることを確かめる

## Notes

- [P] タスクは別ファイルで依存関係がない場合のみ付ける
- タスクはすべて実ファイルパスを含める
- 新しい永続化構造は作らず、既存の購入状態をそのまま表示に反映する
