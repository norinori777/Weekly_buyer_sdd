# Tasks: 曜日ボタン簡略化とスワイプ切替

**Input**: Design artifacts from `specs/009-weekday-button-swipe/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `quickstart.md`, `contracts/`  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Task Format

- `[ID]` Task description
- `Depends on` parent task IDs if applicable
- `Verification` what should be checked after completion

---

## Phase 1: Presentation Baseline (Header)

**Purpose**: Weekday selectorの表示と操作を、既存構造のまま仕様に合わせる。

- [ ] T001 現状の曜日切替（タップ + 左右スワイプ）が `WeekHeader` の1箇所に集約されていること、スワイプが週の範囲外へ出ない（先頭/末尾でクランプされる）ことを確認する in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: none
  - Verification: 週の先頭/末尾でのスワイプが週外へ移動しない実装になっている。

- [ ] T002 曜日ボタンのラベルを「曜日のみ」に簡略化し、数値（日付）を含めないようにする in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T001
  - Verification: ChoiceChip のラベルが「月〜日」のみになり、数字や区切り（例: `4/20`）が表示されない。

**Checkpoint**: 曜日ボタンが曜日のみ表示になり、操作仕様の前提が揃う。

---

## Phase 2: User Story 1 - 曜日を素早く切り替えて登録内容を確認する (Priority: P1)

**Goal**: 左右スワイプで曜日が切り替わり、表示内容も選択曜日に追従する。

**Independent Test**: 商品登録画面でヘッダーを左右スワイプし、選択中の曜日が隣へ移動し、内容も切り替わることを確認する。

- [ ] T003 スワイプ操作で選択中の曜日（selected date）が隣の日へ切り替わり、同じ週内に留まることを確認・必要なら調整する in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T001
  - Verification: 左スワイプで+1日、右スワイプで-1日に変化し、週の範囲外へは移動しない。

- [ ] T004 曜日切替後に表示内容が選択曜日へ追従することを確認（状態更新が同一の selected-date ソースに繋がっていること） in `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`.
  - Depends on: T003
  - Verification: スワイプ/タップで曜日を変えると、該当曜日の登録内容のみが表示される。

**Checkpoint**: スワイプによる曜日切替が成立し、内容が確実に追従する。

---

## Phase 3: User Story 2 - 曜日ボタンを見やすくする (Priority: P2)

**Goal**: 曜日ボタンから日付表示を外し、曜日のみで視認できる。

**Independent Test**: 曜日ボタンを見て、日付の数値が含まれていないことを確認する。

- [ ] T005 曜日ボタンに数値が混ざらないこと（digits が含まれないこと）を最終確認する in `weekly_buyer/lib/features/weekly_shopping_list/presentation/week_header.dart`.
  - Depends on: T002
  - Verification: 月〜日ボタンに数字が一切含まれない。

**Checkpoint**: 曜日切替UIが簡潔になり、誤読しづらい表示になる。

---

## Phase 4: Verification & Regression

**Purpose**: 仕様どおり動くことを確認し、既存機能の退行がないことを担保する。

- [ ] T006 `flutter analyze` を実行し、変更箇所に起因する警告/エラーがないことを確認する.
  - Depends on: T002, T004
  - Verification: `flutter analyze` が成功する。

- [ ] T007 `flutter test` を実行し、既存テストが通ることを確認する.
  - Depends on: T006
  - Verification: `flutter test` が成功する。

- [ ] T008 [Manual] Quickstart の手順で実機/エミュレータ確認（曜日のみ表示、左右スワイプ切替、週境界でクランプ）を行う in `specs/009-weekday-button-swipe/quickstart.md`.
  - Depends on: T007
  - Verification: 期待結果どおりに動作する。

---

## Dependencies & Execution Order

- **Phase 1** → **Phase 2** → **Phase 3** → **Phase 4** の順に実行する。
- 表示変更（T002）は他の検証の前提なので早めに完了させる。

## Notes

- 週の選択や翌週表示は本featureの対象外（曜日UIの簡略化とスワイプ切替に限定）。
- 新しい画面や週選択UIは追加しない。
