# Research: 商品追加画面の料理メニュー編集

## Decision 1: 既存の追加シートを編集にも再利用する
- Decision: 料理メニュー編集は既存の bottom sheet 系入力 UI を拡張して再利用する。
- Rationale: 追加と編集はどちらも 1 件の料理メニュー文字列を扱うため、同じフォームに初期値とラベルだけを足すのが最小変更である。
- Alternatives considered: 編集専用の新しいダイアログを作る案。UI の重複が増え、追加と編集で見た目が分岐しやすい。

## Decision 2: 更新は repository の 1 行更新で行う
- Decision: 料理メニュー編集は `meal_menu_entries` の対象行を `id` で特定し、`menuText` と `updatedAt` を更新する。
- Rationale: 既存テーブルに必要なカラムが揃っており、再挿入や新規テーブルは不要である。
- Alternatives considered: いったん削除して再登録する案。`createdAt` や並び順の扱いが不自然になりやすい。

## Decision 3: 編集対象はペンアイコンを押した 1 件に限定する
- Decision: 編集 UI は選択された単一の Meal Menu Entry にだけ紐づける。
- Rationale: 同じ区分に複数件ある前提でも、編集対象を明示できるため誤更新を防ぎやすい。
- Alternatives considered: 区分全体をまとめて編集する案。1 件だけ直したい通常操作に対して重い。

## Decision 4: 空欄編集は保存しない
- Decision: 空文字または空白だけの入力は既存のメニューを更新しない。
- Rationale: 既存値を消してしまう誤操作を避けられる。
- Alternatives considered: 空入力で削除扱いにする案。削除機能は別の操作と分けたほうが分かりやすい。

## Decision 5: read-only 週表示では編集を無効化する
- Decision: 前の週を表示している read-only 状態では、ペンアイコンも無効にする。
- Rationale: 既存の表示制御と一致させることで、編集可能範囲を曖昧にしない。
- Alternatives considered: read-only でも編集画面だけ開ける案。保存不可の操作導線が混乱を招く。

## Decision 6: 外部インターフェースの契約ファイルは作らない
- Decision: この機能では contracts/ を新規作成しない。
- Rationale: 内部の Flutter 画面と repository の変更だけで完結し、外部公開 API はない。
- Alternatives considered: UI 契約書を作る案。今回の内部機能には過剰である。
