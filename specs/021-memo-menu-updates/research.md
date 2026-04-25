# Research: 商品追加画面のメモ自動保存と料理メニュー削除

## Decision 1: 私用メモは自動保存にする
- Decision: 私用メモは入力変更のたびに保存し、クリア/保存ボタンは廃止する。
- Rationale: ボタン操作をなくし、買い物中の入力を中断させないため。
- Alternatives considered: フォーカスを外したときだけ保存する案。保存タイミングが見えにくく、戻ったときの整合性が弱い。

## Decision 2: 料理メニューの削除は各行の右側に置く
- Decision: 登録済みの料理メニュー各行に ✖ ボタンを追加する。
- Rationale: 行単位で削除対象が明確になり、誤削除を避けやすい。
- Alternatives considered: セクション単位で削除する案。削除範囲が広すぎる。

## Decision 3: 削除後は一覧を即時更新する
- Decision: 削除が完了したら、その日の料理メニュー一覧を再読み込みする。
- Rationale: 反映遅れをなくし、削除結果をその場で確認できる。
- Alternatives considered: 画面遷移で戻す案。操作が増え、買い物中の流れを壊す。

## Decision 4: 既存の保存・削除 API を再利用する
- Decision: 私用メモの保存 API と料理メニュー削除 API は既存のものを使う。
- Rationale: データ層を増やさず、UI の変更に集中できる。
- Alternatives considered: 新しい保存モデルを作る案。今回の要件では過剰。
