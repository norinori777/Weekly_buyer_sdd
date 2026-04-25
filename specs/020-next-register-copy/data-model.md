# Data Model: 「次も登録」ボタンと補足文の改善

## Existing entities used as-is

### Item Add Form
- 連続登録用の入力フォーム。

### Continue-Add Action
- 商品を保存して、次の商品入力に進む既存の UI 行為。

## New or refined entities

### Continue-Add Label
- 表示文字列: `次も登録`
- 既存の連続登録動作を示す短いラベル。

### Helper Text
- 表示文字列: `保存して続けて入力できます`
- ボタンの意味を補う補足文。

## Relationships

- Continue-Add Label は Helper Text と同じ入力エリア内で表示される。
- Helper Text はボタンの意味を補足し、単発登録との違いを明確にする。

## Validation rules

- 補足文は主ボタンより目立ちすぎない。
- ラベルと補足文は、画面内の既存レイアウトに収まる長さである。
- 表示文言は既存の連続登録動作と矛盾しない。

## Notes

- 永続化データやフォーム状態の新規項目は不要。
