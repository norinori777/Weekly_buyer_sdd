# Research: 商品入力フォームの続けて追加

## Decision 1: 保存処理は既存の addItem を使う
- Decision: 通常登録と「続けて追加」どちらも、同じ保存処理を再利用する。
- Rationale: 保存の重複や分岐漏れを避けられ、データ整合性を保ちやすい。
- Alternatives considered: 連続追加用の別保存関数を作る案。処理の二重管理になりやすい。

## Decision 2: 連続追加後はフォームを閉じずに入力欄だけ初期化する
- Decision: 「続けて追加」実行後は、フォームを残したまま入力欄をクリアして次の入力に備える。
- Rationale: ユーザーが同じ画面で続けて入力でき、操作回数を減らせる。
- Alternatives considered: 毎回フォームを閉じて再表示する案。連続入力の価値が薄れる。

## Decision 3: 単発登録ボタンは残す
- Decision: 既存の登録完了導線はそのまま残し、使い分けられるようにする。
- Rationale: 1件だけ登録したいユーザーの操作を変えないため。
- Alternatives considered: 「続けて追加」だけに一本化する案。利用者の選択肢が減る。

## Decision 4: ボタンは入力欄の近くに置く
- Decision: 商品名と数量の入力欄を縮め、同じ行または近接した配置にボタンを置く。
- Rationale: 入力中に視線移動が少なく、続けて追加が見つけやすい。
- Alternatives considered: フォーム下部に別行で置く案。見つけやすさが下がる。

## Decision 5: 前回入力の再利用はしない
- Decision: 連続追加後は前回の入力内容を残さず、空の状態に戻す。
- Rationale: 誤って同じ内容を連続登録するリスクを下げる。
- Alternatives considered: 商品名や数量を残す案。入力ミスの原因になりやすい。
