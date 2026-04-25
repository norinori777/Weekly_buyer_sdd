# Research: 初期カテゴリとひらがな名の投入

## Decision 1: seed は同期処理として扱う
- Decision: 初期カテゴリの投入は、空データ時の一回限りではなく、起動時に不足分を補う同期処理として扱う。
- Rationale: 既存インストールでも新しい初期カテゴリやひらがな名が反映される必要があるため。
- Alternatives considered: 完全な初回起動のみで投入する案。既存利用者に反映されない。

## Decision 2: ひらがな名は seed と同時に保存する
- Decision: 各 item master に対して、表示名とひらがな名を同時に保持する。
- Rationale: 候補検索や表示にそのまま使えるため、後から別処理で埋める必要をなくせる。
- Alternatives considered: 表示名だけ先に投入し、別の補完処理でひらがなを入れる案。同期の複雑さが増える。

## Decision 3: seed 対象以外は上書きしない
- Decision: ユーザーが作成したカテゴリや商品候補、seed 以外の既存レコードは維持する。
- Rationale: 既存データ破壊を避け、初期データだけを更新対象に限定できるため。
- Alternatives considered: catalog 全体を再生成する案。ユーザーデータ損失の危険がある。

## Decision 4: カテゴリ順は指定 JSON の順序を優先する
- Decision: seed するカテゴリ順序は、ユーザーが提示した JSON の順序に合わせる。
- Rationale: 画面上のカテゴリ並びと初期体験を入力要求どおりに揃えられるため。
- Alternatives considered: 現在の内部順序を維持する案。新しいカテゴリ構成が反映されにくい。
