# Data Model: 前週参照表示

## Overview

この機能では新しい永続データは追加しない。既存の週単位データを、現在週と過去週のどちらとして表示するかだけを切り替える。

## Entities

### Week View

週の表示状態を表す概念エンティティ。

- `weekType`: 現在の次週表示か、過去週表示か
- `weekOffset`: 次週を 0 とした場合の相対週差
- `isReadOnly`: 過去週なら true

### Week Snapshot

1 週間分の既存データをまとめて参照する概念エンティティ。

- `purchaseContent`: その週の購入内容
- `mealMenus`: その週の料理メニュー
- `hasContent`: 参照対象の週に何らかの記録があるか

### Read-Only State

過去週表示中の操作制御状態。

- `addItemEnabled`: false
- `addMealMenuEnabled`: false
- `navigationEnabled`: true

## Relationships

- 1 つの Week View は 1 つの Week Snapshot を表示する。
- Read-Only State は Week View の表示条件として付与される。
- 過去週であっても、表示対象データは既存の保存済み週データをそのまま利用する。

## Notes

- 永続化スキーマの変更は不要。
- 履歴テーブルやスナップショット複製テーブルは追加しない。
