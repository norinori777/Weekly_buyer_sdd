# Research: Category and Item Settings

## Decision 1: DBスキーマは変更しない
- Decision: 既存の Drift テーブルとカラムをそのまま使う。
- Rationale: ユーザー要望でデータモデルの現状維持が明示されており、移行リスクを避けられる。
- Alternatives considered: 新規カラム追加や論理削除用フラグ追加。今回は要件外のため見送る。

## Decision 2: 削除可否はリポジトリで検証する
- Decision: `deleteCategory` はカテゴリ内件数、`deleteItem` は現在の購入週の参照有無を確認してから削除する。
- Rationale: UI だけに頼ると競合や抜けが起きるため、トランザクション内で明示的にブロックする方が安全。
- Alternatives considered: UI での無効化のみ。見た目は防げても API 呼び出しや将来の操作経路で抜ける。

## Decision 3: UI では入力欄を減らす
- Decision: カテゴリ編集は名前のみ、商品編集は名前中心で、数量入力欄は出さない。
- Rationale: ユーザーは管理画面で不要な情報を扱わずに済み、操作を簡潔にできる。
- Alternatives considered: 既存の詳細入力を残して非表示にする案。設定画面が複雑になるため採用しない。

## Decision 4: 現在の購入週の定義は既存の選択週に従う
- Decision: 削除禁止の「現在の購入週」は、アプリが表示している選択中の週を基準にする。
- Rationale: 既存の週表示と整合させやすく、ユーザーが見ている週とルールの対象が一致する。
- Alternatives considered: 全週を横断して削除禁止にする案。安全だが制約が強すぎるため、今回の要件には合わない。

## Decision 5: テストは repository と widget に分ける
- Decision: データ整合性は repository テスト、表示制御は widget テストで担保する。
- Rationale: ルールの中心は削除可否であり、ドラッグや複雑なジェスチャよりも単体ロジックの安定性が重要。
- Alternatives considered: integration_test 中心。将来的には有効だが、初期段階ではコストが高い。
