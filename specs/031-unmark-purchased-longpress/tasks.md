# タスク: 購入済み商品の長押しによる購入済み解除

**入力**: `specs/031-unmark-purchased-longpress/` の plan.md、spec.md、research.md、data-model.md、contracts/ui-contract.md、quickstart.md  
**テスト**: 憲法の品質ゲート（テスト・Lint 必須）と plan.md のテスト計画に従い、テストタスクを含める。  
**パス基準**: すべてリポジトリルートからの相対パス。

## 形式: `- [ ] T### [P] [US#] 説明（ファイルパス）`

- **[P]**: 並行実行可能（別ファイル、未完了タスクへの依存なし）
- **[US#]**: 対応するユーザーストーリー

---

## Phase 1: セットアップ

既存の Flutter アプリ構成を使うため、新規プロジェクト設定・依存追加は不要。

- [X] T001 既存テストが通ることを基準確認する（`weekly_buyer/` で `flutter test test/repository_test.dart test/widget_test.dart` と `flutter analyze`）

---

## Phase 2: 基盤（全ストーリーの前提）

**目的**: 解除のデータ操作を用意する。US1・US2 の両方が依存する。

- [X] T002 `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` に `Future<void> unmarkPurchased(int itemId)` を追加する（`togglePurchased` の直後。`isPurchased=false`、`purchasedAt=null`、`updatedAt=now` を書き込む。未購入・不存在 ID でも例外にせず冪等）
- [X] T003 [P] `weekly_buyer/test/repository_test.dart` に `unmarkPurchased` のテストを追加する（購入済み → 解除で `isPurchased=false` かつ `purchasedAt=null`、未購入への再実行・不存在 ID で例外なし、他の行に影響なし）

**チェックポイント**: リポジトリのテストが通ること。

---

## Phase 3: ユーザーストーリー 1 - 購入済みを長押しで解除する（優先度: P1）🎯 MVP

**ゴール**: 購入済み商品を長押し → 確認ダイアログ → 「はい」で未購入に戻り、再起動後も維持される。

**独立テスト**: 購入済み商品を1件用意し、商品追加画面で長押し →「はい」で未購入表示（通常色・購入日なし）になる。

### US1 のテスト

- [X] T004 [P] [US1] `weekly_buyer/test/widget_test.dart` に、購入済み商品の長押しでダイアログ（「購入済みを解除しますか？」）が表示され、「はい」で未購入表示に戻り永続化される（再取得しても未購入）ウィジェットテストを追加する

### US1 の実装

- [X] T005 [US1] `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` の `_SectionPreviewCard` に `onUnmarkPurchased`（`Future<void> Function(ShoppingItemEntry item)`）コールバックを追加し、商品行の `ListTile.onLongPress` を「`item.isPurchased` かつ `!isReadOnly`」のときだけ設定する（それ以外は `null`）
- [X] T006 [US1] 同ファイルに確認ダイアログを追加する（`showDialog<bool>` の `AlertDialog`、タイトル「購入済みを解除しますか？」、本文に商品名、ボタン「いいえ」「はい」）。`true` のときのみ `unmarkPurchased(item.id)` を呼び、`ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate))` で再読込する。呼び出し元の `_SectionPreviewCard` 生成箇所（`onDeleteItem` の隣）で配線する

**チェックポイント**: US1 単独で動作・テスト可能（MVP）。

---

## Phase 4: ユーザーストーリー 2 - 確認をキャンセルする（優先度: P2）

**ゴール**: 「いいえ」や外側タップ・戻る操作で購入済みのまま変わらない。未購入商品と前の週では長押しが無反応。

**独立テスト**: 長押し →「いいえ」で状態不変。未購入商品の長押しでダイアログが出ない。

- [X] T007 [P] [US2] `weekly_buyer/test/widget_test.dart` に、「いいえ」選択と外側タップで購入済みのまま変わらないテスト、未購入商品の長押しでダイアログが出ないテスト、読み取り専用の週（前の週）で長押しが無効なテストを追加する
- [X] T008 [US2] T006 のダイアログ処理が `false` / `null`（外側タップ・戻る）で何も変更しないこと、`isReadOnly` の週で長押しが無効なことを `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart` で確認し、不足があれば修正する

**チェックポイント**: US1・US2 が独立して動作する。

---

## Phase 5: 仕上げ・横断事項

- [X] T009 既存操作（削除ボタン、料理メニュー操作、購入リスト画面の購入済み／元に戻す）に影響がないことを `flutter test`（全体）で確認する（`weekly_buyer/`）
- [X] T010 `weekly_buyer/` で `flutter analyze` と `dart format` を実行し、警告・整形差分がないことを確認する
- [ ] T011 `specs/031-unmark-purchased-longpress/quickstart.md` の手動確認手順（1〜6）を実機またはエミュレーターで実施する（SC-001〜004、再起動後の維持を含む）

---

## 依存関係と実行順序

- Phase 1 → Phase 2 → Phase 3（US1）→ Phase 4（US2）→ Phase 5
- US1 は Phase 2（T002）に依存。US2 は US1 のダイアログ実装（T006）を前提に検証する。
- タスク間: T005 → T006。T004 は T005・T006 の前に書いて失敗を確認してもよい。

```text
T001 → T002 ─┬→ T003 [P]
             └→ T005 → T006 → T008
T004 [P]（T002 後）                 T007 [P]（T006 後）
                                    ↓
                                  T009 → T010 → T011
```

## 並行実行の例

- T002 完了後: T003（`repository_test.dart`）と T004（`widget_test.dart`）は別ファイルなので並行可能。
- T006 完了後: T007 と T008 は並行可能（テストと実装確認）。ただし T004 と T007 は同じ `widget_test.dart` のため同時編集しない。

## 実装戦略

- **MVP**: Phase 1〜3（US1）。長押し → 「はい」で解除できる状態で一度リリース可能。
- **増分**: US2（キャンセル・無効条件の保証）を追加し、Phase 5 で全体検証。

## 概要

- タスク数: 11（US1: 3、US2: 2、基盤: 2、セットアップ: 1、仕上げ: 3）
- 並行可能: T003、T004、T007
