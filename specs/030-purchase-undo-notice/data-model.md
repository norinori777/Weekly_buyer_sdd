# Data Model: 購入済み通知

永続データ (Drift のテーブル) の変更はありません。追加するのはメモリ上の一時的な UI 状態のみです。

## PurchaseUndoNotice (一時的な UI 状態)

| 項目 | 型 | 説明 |
|------|----|------|
| `itemName` | String | 購入済みにした商品名 (バナー文言に使用) |
| `createdAt` | DateTime | 通知を発生させた時刻。新しい通知と古い通知を区別し、タイマー再設定の契機にする |

保持場所: `purchaseUndoNoticeProvider` (`StateProvider<PurchaseUndoNotice?>`)。`null` は通知なしを表す。

## 状態遷移

```text
なし(null) --購入済み操作--> 表示中(notice)
表示中     --別の購入済み操作--> 表示中(新しい notice, 3 秒を数え直し)
表示中     --3 秒経過--> なし
表示中     --「元に戻す」押下--> なし (商品は未購入に戻る)
表示中     --画面遷移 / 画面破棄--> なし
```

## バリデーション・ルール

- 前の週 (読み取り専用) では通知を設定・表示しない。
- 通知の消去は冪等とし、すでに `null` の場合は何もしない。
- 通知が `null` になっても、商品の購入済み状態 (`WeeklyListItems.isPurchased`) は変更しない。
