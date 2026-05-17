# Tasks: 商品追加画面の料理メニュー編集

**Input**: Design documents from `/specs/025-edit-meal-menu/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: この feature では明示的なテスト作成要求はないため、実装タスクと最終検証タスクのみを含める。

**Organization**: タスクはユーザーストーリー順に整理し、各ストーリーを独立実装・独立検証できる形にする。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 別ファイルで依存関係がないため並列実行可能
- **[Story]**: ユーザーストーリーに対応するラベル（例: US1, US2）
- 説明には必ず実ファイルパスを含める

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: 料理メニュー編集に共通で使う下地を整える

- [X] T001 [P] 料理メニュー編集用の入力シート拡張を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` に追加し、`MealMenuAddSheet` が初期テキスト・タイトル・送信ラベルを受け取れるようにする
- [X] T002 [P] 保存済み料理メニューの更新 API を `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` に追加し、`MealMenuEntry` を `id` 指定で更新できるようにする

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: どのユーザーストーリーよりも先に必要な編集対象の受け渡し基盤を整える

**⚠️ CRITICAL**: このフェーズが終わるまでユーザーストーリー作業を始めない

- [X] T003 [P] 編集対象のメニュー行を渡す導線を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` に追加し、選択した `MealMenuEntry` の id と現在値を編集シートへ渡せるようにする

**Checkpoint**: 編集対象を 1 件に限定して受け渡す基盤ができたら、ユーザーストーリー実装に進める

---

## Phase 3: User Story 1 - 追加済みの料理メニューを編集する (Priority: P1)

**Goal**: 商品追加画面で表示済みの料理メニューにペンアイコンを出し、タップした 1 件だけを編集できるようにする

**Independent Test**: 商品追加画面で既存メニューのペンアイコンを押し、初期値が入った編集シートから内容を変更して保存すると、その 1 件だけが更新される

### Implementation for User Story 1

- [X] T004 [US1] 表示済みの料理メニュー行にペンアイコンを追加する処理を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` に実装する
- [X] T005 [US1] ペンアイコン押下で編集用 bottom sheet を開き、対象メニューの現在値を初期表示する処理を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` と `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` に実装する
- [X] T006 [US1] 編集内容の保存時に `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` の更新 API を呼び出し、`weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で該当日の `mealMenuSnapshotProvider(selectedDate)` を再読込する

**Checkpoint**: 1 件の料理メニューをペンアイコンから編集して保存できる状態にする

---

## Phase 4: User Story 2 - 編集中の変更を破棄する (Priority: P1)

**Goal**: 編集途中でやめたときに元の内容を残したまま閉じられるようにする

**Independent Test**: 既存メニューの編集シートを開いてキャンセルまたは閉じると、元の料理メニューがそのまま残る

### Implementation for User Story 2

- [X] T007 [US2] 編集シートのキャンセル操作で更新処理を呼ばずに閉じる導線を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` と `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` に実装する
- [X] T008 [US2] 空文字または空白だけの編集が既存メニューを上書きしないように、入力検証を `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart` と `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` に追加する

**Checkpoint**: 編集途中でのキャンセルと空入力抑止ができる状態にする

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 複数ストーリーにまたがる仕上げと最終確認

- [X] T009 [P] `weekly_buyer/` で `flutter analyze` を実行し、編集導線追加後の静的解析を確認する
- [X] T010 [P] `weekly_buyer/` で `flutter test` を実行し、既存の回帰がないことを確認する
- [X] T011 [P] `specs/025-edit-meal-menu/quickstart.md` の手順で、編集・保存・キャンセルの手動確認を行う

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: すぐ開始できる
- **Foundational (Phase 2)**: Setup 完了後に開始し、全ユーザーストーリーをブロックする
- **User Story 1 (Phase 3)**: Foundational 完了後に開始できる
- **User Story 2 (Phase 4)**: Foundational 完了後に開始できる
- **Polish (Phase 5)**: すべての必要なユーザーストーリー完了後に開始する

### User Story Dependencies

- **User Story 1 (P1)**: 依存なし。編集開始と保存の中核機能
- **User Story 2 (P1)**: 依存なし。編集中のキャンセルと入力抑止

### Within Each User Story

- 共有 API と入力シートの下地を先に整える
- 編集対象の受け渡しを実装してから、ペンアイコンとシート起動をつなぐ
- 保存後に対象日のメニュー一覧を再読込する
- キャンセルと空入力抑止を確認してから完了とする

### Parallel Opportunities

- T001 と T002 は別ファイルなので並列に進められる
- T003 は T001/T002 の後でもよいが、UI 受け渡しの準備として独立して実装できる
- T009 と T010 と T011 は検証作業として並列または順次実施できる

## Implementation Strategy

### MVP First

1. Phase 1 の共有 API 拡張を完了する
2. Phase 2 の編集対象受け渡しを整える
3. Phase 3 の User Story 1 を完了する
4. ここで編集の中核価値を確認する

### Incremental Delivery

1. 共有 API を追加する
2. 1 件の料理メニューを編集できるようにする
3. キャンセルと空入力抑止を追加する
4. 最終検証で回帰がないことを確認する

## Notes

- [P] タスクは別ファイルで依存関係がない場合のみ付ける
- タスクはすべて実ファイルパスを含める
- 既存のデータ構造を壊さず、`MealMenuEntry` の 1 件更新に限定する
