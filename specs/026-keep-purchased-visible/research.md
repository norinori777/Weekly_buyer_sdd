# Research: 商品追加画面の購入済み商品表示

## Decision 1: 購入済み商品は取得段階で除外しない
- Decision: 商品追加画面用の一覧は、`isPurchased` が true の商品も含めて返す。
- Rationale: 非表示にしてしまうと、買い物の進行状況が見えなくなるため。
- Alternatives considered: 表示層でだけ再表示する案。データ側で消したままだと、件数や順序の整合性が取りにくい。

## Decision 2: 画面側で購入済み色を切り替える
- Decision: 商品名と数量の文字色は、`ShoppingItemTile` などの表示コンポーネントで `isPurchased` を見て切り替える。
- Rationale: 購入済みの見た目は UI の責務であり、データ層に持ち込まないほうが分かりやすい。
- Alternatives considered: repository で色情報を付与する案。永続データと UI 表現が混ざる。

## Decision 3: 既存の購入済みトグルと undo をそのまま使う
- Decision: `togglePurchased` と `undoLatestPurchase` のフローは維持する。
- Rationale: 状態遷移はすでに存在しており、今回必要なのは表示の変更だけだから。
- Alternatives considered: 新しい購入済み専用 API を作る案。重複実装になる。

## Decision 4: 購入済みの見た目は既存テーマの強調色を使う
- Decision: 購入済み商品には、アプリテーマの購入済み/副次強調に相当する色を使う。
- Rationale: 既存 UI と調和し、追加のデザイン定義を増やさないため。
- Alternatives considered: 新しい固定色を追加する案。テーマとの整合性が弱い。

## Decision 5: 対象範囲は商品追加画面に限定する
- Decision: 機能要件の対象は商品追加画面とし、購入リスト画面の挙動は変更しない。
- Rationale: ユーザー要望が商品追加画面の表示に限定されているため。
- Alternatives considered: 全画面で purchased 表示を統一する案。今回の変更範囲を不必要に広げる。
