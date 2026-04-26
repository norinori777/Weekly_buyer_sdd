# Research: 商品追加画面メモ

## Decision 1: メモは日次の独立データとして保存する
- Decision: メモは商品データに混ぜず、選択中の日付にひも付く独立エンティティとして保存する。
- Rationale: 商品一覧や購入リストに私用情報を混入させず、表示範囲を明確に分けられる。
- Alternatives considered: 商品行に備考欄を追加する案。購入リストへの表示漏れや再利用時の混線が起きやすいため採用しない。

## Decision 2: 対象日は既存の週選択状態を使う
- Decision: メモの対象日は `selectedWeekDateProvider` が表す現在の日付をそのまま使う。
- Rationale: 週の切り替えや曜日切り替えと同じ文脈で扱えるため、ユーザーが見ている日と保存先が一致する。
- Alternatives considered: メモ専用の独立した日付管理を追加する案。状態が分裂して画面遷移時の整合性確認が難しくなる。

## Decision 3: 入力 UI は商品追加画面に統合する
- Decision: メモ入力欄は `item_add_destination.dart` と `item_entry_form.dart` に追加し、別画面には分けない。
- Rationale: 画面遷移を増やさず、商品追加と私用メモの入力を同じ導線で完結できる。
- Alternatives considered: メモ専用ダイアログや独立画面を設ける案。操作回数が増えるため優先しない。

## Decision 4: 購入リスト画面ではメモを参照しない
- Decision: メモは週の購入対象一覧やカテゴリ一覧に含めず、購入リスト画面では非表示にする。
- Rationale: 私用情報の見落としや誤表示を防ぎ、買い物の一覧をシンプルに保てる。
- Alternatives considered: 購入リスト上部に注意書きとして表示する案。個人情報が混ざるため採用しない。

## Decision 5: 検証は repository と widget に分ける
- Decision: 日付ごとの保存・更新は repository テスト、画面表示・非表示と入力導線は widget テストで確認する。
- Rationale: 保存ロジックと表示ロジックを分けた方が、失敗時の原因を特定しやすい。
- Alternatives considered: integration_test のみで確認する案。初期コストが高く、局所的な修正に向かない。
