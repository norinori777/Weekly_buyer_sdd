# Data Model: 商品追加画面メモ

## New entity

### Daily Memo
- `id`
- `week_start_date`
- `weekday`
- `memo_text`
- `created_at`
- `updated_at`

## Relationships
- 1 週間に対して、曜日ごとに最大 1 件のメモを持つ。
- 同じ週の同じ曜日は同じメモとして扱う。
- メモは商品やカテゴリとは独立して扱う。

## Validation rules
- メモ本文は空白のみでは保存しない。
- 同じ週・同じ曜日に対しては新規作成ではなく更新として扱う。
- 購入リスト画面に表示するデータには含めない。
- 別週の同じ曜日とは分離して保存する。

## State transitions
- Daily Memo: absent -> created -> updated -> cleared
- クリア操作後は、その週・その曜日のメモが未設定に戻る。

## Notes
- 既存の週選択状態をキーにして保存するため、日付切り替えと表示が一致する。
- ローカル保存の範囲に留め、共有や同期は扱わない。
