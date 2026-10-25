# Tasks: 購入済み通知の重複解消と自動消去

**Input**: Design documents from `/specs/030-purchase-undo-notice/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/ui-contract.md, quickstart.md

**Tests**: 憲法の品質ゲートと plan.md の Test Strategy に従い、ウィジェットテストを含める。

**Organization**: ユーザーストーリーごとにフェーズを分け、独立して実装・検証できるようにする。

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 並列実行可能 (別ファイル、未完了タスクへの依存なし)
- **[Story]**: 対応するユーザーストーリー (US1, US2, US3)

## Path Conventions

- アプリ本体: `weekly_buyer/lib/`
- テスト: `weekly_buyer/test/`
- 画面: `weekly_buyer/lib/features/weekly_shopping_list/presentation/`

---

## Phase 1: Setup

**Purpose**: 現状の確認

- [x] T001 `weekly_buyer` で `flutter test test/widget_test.dart` を実行し、現状のテスト結果を基準として記録する (weekly_buyer/test/widget_test.dart)

---

## Phase 2: Foundational (全ストーリーの前提)

**Purpose**: 一時通知の状態を用意する

**⚠️ CRITICAL**: US2・US3 はこのフェーズの完了後に着手する

- [x] T002 `PurchaseUndoNotice` (itemName, createdAt) を定義し、`purchaseUndoNoticeProvider` (`StateProvider<PurchaseUndoNotice?>`、初期値 null) を追加する (weekly_buyer/lib/app/app_state_providers.dart)

**Checkpoint**: 通知状態が参照できる

---

## Phase 3: User Story 1 - 購入済み通知の重複を解消する (Priority: P1) 🎯 MVP

**Goal**: 購入済み操作で黒色背景の通知 (SnackBar) を出さず、画面内の「購入済み + 元に戻す」を 1 組だけ表示する

**Independent Test**: 商品を購入済みにして、SnackBar が 0 件、「元に戻す」が 1 件であることを確認する

### Tests for User Story 1

- [x] T003 [P] [US1] 購入済み操作後に `find.byType(SnackBar)` が 0 件で、`find.text('元に戻す')` が 1 件であるウィジェットテストを追加する (weekly_buyer/test/widget_test.dart)

### Implementation for User Story 1

- [x] T004 [P] [US1] `onTogglePurchased` から購入済みの `clearSnackBars()` + `showSnackBar(...)` を削除する。他の SnackBar (カテゴリ追加依頼、マスター登録) は変更しない。不要になった `messenger` 変数も整理する (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart)
- [x] T005 [P] [US1] 旧ページ側 `onTogglePurchased` の購入済み SnackBar を同様に削除する (weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart)
- [x] T006 [US1] T003 のテストと既存テストを実行し、通ることを確認する (weekly_buyer/test/widget_test.dart)

**Checkpoint**: 重複表示が解消され、単独で MVP として確認できる

---

## Phase 4: User Story 2 - 通知を 3 秒で自動的に消す (Priority: P1)

**Goal**: 購入済み通知を購入済み操作の直後だけ表示し、3 秒で消す。「元に戻す」押下でも消す

**Independent Test**: 購入済みにして 2 秒時点では表示、3 秒経過後は非表示になること

### Tests for User Story 2

- [x] T007 [P] [US2] `pump(Duration(seconds: 2))` で表示中、`pump(Duration(seconds: 1))` 追加で非表示になるテストを追加する (weekly_buyer/test/widget_test.dart)
- [x] T008 [P] [US2] 連続して 2 件購入済みにすると最新の商品名に置き換わり、最後の操作から 3 秒で消えるテストを追加する (weekly_buyer/test/widget_test.dart)
- [x] T009 [P] [US2] 3 秒以内に「元に戻す」を押すと DB が未購入に戻り、通知が消えるテストを追加する (weekly_buyer/test/widget_test.dart)

### Implementation for User Story 2

- [x] T010 [US2] 購入済み操作で `purchaseUndoNoticeProvider` に新しい `PurchaseUndoNotice` を設定する。読み取り専用 (前の週) では設定しない (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart)
- [x] T011 [US2] `UndoBanner` の表示条件を「通知が非 null のとき」に変更する。従来の `hiddenPurchasedCount > 0 || lastPurchasedItem != null` による常時表示をやめ、ListView 下部余白の判定 (`showBottomBanner`) も同じ条件に揃える。ラベルは通知の商品名を使う (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart, weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart)
- [x] T012 [US2] 通知を表示するホストを `ConsumerStatefulWidget` 化し、通知が変わるたびに `Timer(Duration(seconds: 3))` をキャンセル・再設定して、満了時に通知を null にする。`dispose` でタイマーをキャンセルする (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart)
- [x] T013 [US2] 「元に戻す」押下で `undoLatestPurchase` 実行・スナップショット invalidate 後に通知を null にする (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart)
- [x] T014 [US2] 旧ページ側 `UndoBanner` の利用箇所にも T010〜T013 と同じ通知制御を適用する (weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart)
- [x] T015 [US2] T007〜T009 のテストを実行し、通ることを確認する (weekly_buyer/test/widget_test.dart)

**Checkpoint**: 通知が 3 秒で消え、元に戻すも動作する

---

## Phase 5: User Story 3 - 画面遷移時に通知を消す (Priority: P2)

**Goal**: 通知表示中に別画面へ遷移したら通知を消し、戻っても再表示しない

**Independent Test**: 購入済みにして 3 秒以内に「商品追加」タブへ移動し、戻ったときに通知がないこと

### Tests for User Story 3

- [x] T016 [US3] 既存テスト `keeps purchased items hidden after switching between list tabs` を更新する。タブ切替後は「購入済みにしました」が表示されないこと、商品が非表示のままであること、DB が購入済みであることを検証する (weekly_buyer/test/widget_test.dart)
- [x] T017 [P] [US3] 購入済みにした直後に「商品追加」タブへ移動し、購入リストへ戻っても通知が 0 件であるテストを追加する (weekly_buyer/test/widget_test.dart)

### Implementation for User Story 3

- [x] T018 [US3] ホストで `ref.listen(mainShellDestinationProvider)` を使って遷移を検知し、通知を null にする。`dispose` でも通知を null にする (weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart)
- [x] T019 [US3] 旧ページ側にも同じ遷移時の消去を適用する (weekly_buyer/lib/features/weekly_shopping_list/presentation/weekly_shopping_page.dart)
- [x] T020 [US3] T016・T017 のテストを実行し、通ることを確認する (weekly_buyer/test/widget_test.dart)

**Checkpoint**: 全ストーリーが独立して動作する

---

## Phase 6: Polish & Cross-Cutting Concerns

- [x] T021 `UndoBanner` を参照する既存テスト (widget_test.dart 1320 行付近の `元に戻す` を扱うテスト) を新しい表示条件に合わせて確認・修正する (weekly_buyer/test/widget_test.dart)
- [x] T022 `weekly_buyer` で `flutter analyze` と `flutter test` を全件実行し、警告とテスト失敗がないことを確認する
- [ ] T023 [quickstart.md](./quickstart.md) の手動確認手順 1〜6 を実施する (specs/030-purchase-undo-notice/quickstart.md)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし
- **Foundational (Phase 2)**: Setup 後。US2・US3 をブロックする
- **US1 (Phase 3)**: Setup 後に着手可能 (Foundational への依存なし)
- **US2 (Phase 4)**: Foundational 完了後。US1 の SnackBar 削除後に行うとテストが明確
- **US3 (Phase 5)**: US2 の通知制御 (T010〜T014) 完了後
- **Polish (Phase 6)**: 全ストーリー完了後

### User Story Dependencies

- **US1**: 独立。単独で MVP
- **US2**: Foundational に依存。US1 とは同じファイルを触るため順次実施を推奨
- **US3**: US2 の通知状態とホストに依存

### Within Each User Story

- テストを先に書き、失敗を確認してから実装する
- 同一ファイルを触るタスクは順次実施する

### Parallel Opportunities

- US1: T003 / T004 / T005 は別ファイルのため並列可
- US2: T007 / T008 / T009 は同一ファイルへの追記だが、独立したテストケースとして並行で作成できる (マージ時に注意)
- US3: T017 は T016 と別ケース。実装 T018 / T019 は別ファイルのため並列可

---

## Parallel Example: User Story 1

```text
T003 購入済み後に SnackBar 0 件のテスト追加 (widget_test.dart)
T004 purchase_list_destination.dart の SnackBar 削除
T005 weekly_shopping_page.dart の SnackBar 削除
```

---

## Implementation Strategy

### MVP First (User Story 1 のみ)

1. Phase 1: Setup
2. Phase 3: US1 (重複解消)
3. **STOP and VALIDATE**: SnackBar が出ず、「元に戻す」が 1 組だけ表示されることを確認

### Incremental Delivery

1. US1: 重複解消 → 確認
2. Phase 2 + US2: 3 秒で消える → 確認
3. US3: 遷移で消える → 確認
4. Polish: 全テスト・手動確認

---

## Notes

- `[P]` のタスクは別ファイル、または独立したテストケース
- 各タスク完了ごとにコミットすることを推奨
- 他の SnackBar (カテゴリ追加依頼、マスター登録、音声入力失敗) は変更しない
