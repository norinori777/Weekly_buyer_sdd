# Research: 未分類商品の商品マスター登録

## Decision 1: 登録フローは既存の item editor sheet を再利用する

- Decision: `item_editor_destination.dart` の既存 bottom sheet をベースに、購入リストの長押しから開く登録フローとして使う。
- Rationale: すでに商品名、ひらがな、カテゴリの入力 UI とキャンセル/登録の導線が揃っており、重複実装を避けられる。
- Alternatives considered:
  - 新しい専用ダイアログを作る: UI の重複が増え、既存の編集体験と分岐しやすい。
  - 設定画面へ遷移する: 購入リスト内で完結せず、買い物中の操作速度を落とす。

## Decision 2: 商品マスター登録は既存の `addItemMaster` を使う

- Decision: 新しい永続化 API は作らず、`WeeklyShoppingRepository.addItemMaster(name, hiragana, categoryId)` を呼ぶ。
- Rationale: 既に商品名・ひらがな・カテゴリを受け取る API があり、スキーマ変更なしで要件を満たせる。
- Alternatives considered:
  - 新しい登録 API を追加する: 既存 API と責務が重複し、保守コストが上がる。
  - purchase item を直接更新してマスター扱いにする: マスターと購入リストの責務が曖昧になる。

## Decision 3: 対象はカテゴリ未設定の購入リスト項目に限定する

- Decision: 長押し導線は `categoryId == null` の item にのみ表示する。
- Rationale: 既にカテゴリが付いている item は対象外とし、誤って別の登録経路を見せない。
- Alternatives considered:
  - すべての item に長押し導線を出す: 対象外の操作が増え、誤操作を誘発する。
  - 未分類の判定を別フラグで持つ: スキーマ変更が必要になり、今回の方針とずれる。

## Decision 4: ひらがなは手入力必須とする

- Decision: 登録フローでひらがな入力欄を必須にする。
- Rationale: 既存の item master はひらがなを保持しており、再利用候補の検索や識別に使える。自動生成は誤変換のリスクがある。
- Alternatives considered:
  - 商品名から自動変換する: 変換品質に依存し、誤登録のリスクがある。
  - ひらがなを登録しない: 既存の候補検索と整合しない。

## Decision 5: UI 変更は purchase list の item tile に限定する

- Decision: 購入リスト画面の item tile に long press を追加し、購入済みフローや read-only 表示は変えない。
- Rationale: 既存の購入済み操作と整合し、画面遷移を増やさずに目的だけを達成できる。
- Alternatives considered:
  - 専用のメニュー画面を別途作る: 目的に対して重く、買い物体験を損ねる。
  - 右上メニューに追加する: item ごとの文脈が弱く、未分類 item だけを狙いにくい。

## Decision 6: テストは repository と widget の両方で確認する

- Decision: repository test で `addItemMaster` の保存結果、widget test で長押し導線と入力必須を確認する。
- Rationale: データ保存と UI 動作の両方を分離して検証できる。
- Alternatives considered:
  - widget test のみで済ませる: 保存内容の検証が弱くなる。
  - repository test のみで済ませる: 長押し導線の検証が抜ける。