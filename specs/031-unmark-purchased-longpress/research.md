# 調査結果: 購入済み商品の長押しによる購入済み解除

## 決定 1: 長押しの検出方法

- **決定**: 商品行の `ListTile.onLongPress` を使い、`item.isPurchased` が true かつ読み取り専用でない場合のみハンドラを設定する（それ以外は `null`）。
- **根拠**: 標準 Material ウィジェットで足り、`null` なら長押しが無反応になる（FR-007）。末尾の削除 `IconButton` のタップとも競合しない。
- **却下案**: `GestureDetector` / `InkWell` の個別実装（`ListTile` で足りるため冗長）。

## 決定 2: 確認ダイアログ

- **決定**: `showDialog<bool>` の `AlertDialog` で、本文に商品名を含め、「いいえ」「はい」を表示する。`true` のときのみ解除する。外側タップ・戻る操作は `null` となり何もしない（FR-006）。
- **根拠**: 画面遷移を増やさない（憲法 IV）。既存コードに `showDialog` の利用例がある。
- **却下案**: SnackBar での確認（誤操作の取消がしづらい）。

## 決定 3: 解除処理

- **決定**: `WeeklyShoppingRepository.unmarkPurchased(int itemId)` を追加。`isPurchased=false`、`purchasedAt=null`、`updatedAt=now` を書き込む。対象が未購入・不存在でも例外にせず、状態は未購入のまま（冪等）。
- **根拠**: `togglePurchased` は反転のため、ダイアログ表示中に状態が変わると再び購入済みにしてしまう。冪等な専用メソッドなら安全。`undoLatestPurchase` と同じ更新内容で一貫する。
- **却下案**: `togglePurchased` の再利用（上記の理由）。

## 決定 4: 画面への反映

- **決定**: 解除後に `ref.invalidate(weeklyShoppingSnapshotProvider(selectedDate))` で再読込する（削除処理と同じ方式）。購入日は `purchasedAt` ではなく購入済み情報の削除で、サブタイトルの購入日表示も消える（FR-008）。
- **根拠**: 既存パターンを踏襲し、永続化（FR-005）と即時反映（FR-004）を両立できる。

## 決定 5: 読み取り専用の週

- **決定**: 前の週の表示（`isReadOnly`）では長押しを無効にする。
- **根拠**: 同画面の削除・追加が読み取り専用で無効であることと一貫させる。

## 未解決事項

なし。
