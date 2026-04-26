# Research: 「次も登録」ボタンと補足文の改善

## Decision 1: ボタン名は「次も登録」にする
- Decision: 連続登録用ボタンの表示名を「次も登録」にする。
- Rationale: 短く、保存して次の入力へ進む意味が伝わりやすい。
- Alternatives considered: 「続けて追加」は動作の説明としては正しいが、少し硬く長い。

## Decision 2: 補足文はボタン直下に表示する
- Decision: 「保存して続けて入力できます」を小さくボタンの下に置く。
- Rationale: ボタン名を短くしつつ、保存後の挙動を補足で明確にできる。
- Alternatives considered: プレースホルダーやツールチップで補う案。常時見えないため、入力時の理解が弱くなる。

## Decision 3: 既存の連続登録動作は変更しない
- Decision: 文言だけ変え、保存やフォーム維持の挙動はそのままにする。
- Rationale: 振る舞いを変えると回帰の範囲が広がるため。
- Alternatives considered: 連続入力のフロー自体を再設計する案。今回の目的は表現改善に限定する。

## Decision 4: 通常登録と役割を分ける
- Decision: 「登録する」と「次も登録」を別々の操作として並べる。
- Rationale: 単発登録と連続登録の意図を混同しにくくする。
- Alternatives considered: 1つのボタンに統合する案。操作が曖昧になる。
