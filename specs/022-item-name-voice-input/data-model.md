# Data Model: 商品名音声入力

## Existing entities used as-is

### AddItemRequest
- `name`
- `quantity`
- `section`
- `itemMasterId`
- `categoryId`

### ItemAddDraft
- 商品追加フォームで編集中の入力状態。
- 既存の入力値を保持し、再表示時にも復元される。

### ItemCandidate
- 商品名の候補一覧。
- 音声入力とは独立して、そのまま継続利用する。

## New or refined entities

### Voice Input Trigger
- 商品名欄の入力を音声で開始するための UI 操作。

### Recognized Product Name
- 音声認識によって得られた商品名テキスト。
- そのまま編集可能なフォーム値として扱う。

### Voice Input Attempt
- 1 回の音声入力開始から完了・失敗・キャンセルまでのまとまり。

## Relationships

- Voice Input Trigger は ItemAddDraft の商品名値を更新する。
- Recognized Product Name は AddItemRequest.name にそのまま反映される。
- Voice Input Attempt が失敗しても、ItemAddDraft の既存値は保持される。

## Validation rules

- 商品名は空欄のままでは登録できない。
- 音声入力で得た文字列は、登録前に手入力で修正できる。
- 音声入力の失敗やキャンセルは、数量や区分の入力には影響しない。
- 音声入力は商品名欄に限定し、他のフォーム項目を自動変更しない。

## Notes

- 新しい永続化エンティティは不要。
- データ層は既存の商品追加保存のまま維持する。
