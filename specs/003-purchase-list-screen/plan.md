# Implementation Plan: 購入リスト画面

**Feature Branch**: `003-purchase-list-screen`  
**Spec**: [spec.md](spec.md)  
**Status**: Draft  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Plan Summary

買い物中の確認作業を最短で終えられる購入リスト画面を実装する。カテゴリ順の一覧、進捗表示、左フリックでの購入済み化、直近操作の元に戻す、画面下部の購入リスト / 商品追加導線を一貫して提供する。既存の週次データと共有週状態を再利用し、購入リスト画面と週単位の商品追加画面の行き来を軽く保つ。

## Product Shape

### Core Screen Model

- `MainShell`: 画面下部の主要導線を束ねる外枠。
- `PurchaseListScreen`: 1週間分の商品をカテゴリ順に表示し、購入済み操作と進捗確認を担当する。
- `WeeklyAddScreen`: 週単位の商品追加を行う画面。購入リスト画面から `商品追加` をタップして開く。
- `CategoryChips`: 画面上部のカテゴリ切替と進捗確認を補助する。
- `PurchaseItemRow`: 商品名、数量、購入状態を表示する行。
- `UndoBar`: 画面下部の削除・元に戻すアクションを集約する。

## Architecture

### Presentation Layer

- Material 3 のアプリ外枠と購入リスト画面を構成する。
- カテゴリ見出し、進捗、行アイテム、空状態を小さなウィジェットに分割する。
- 購入済み操作と Undo は、画面遷移を増やさずに完結させる。

### State Layer

- 現在の週、表示カテゴリ、直近の購入操作、画面下部アクション状態を共有する。
- 購入済み化は購買データの状態として管理し、画面再表示や再起動後も崩れないようにする。
- 商品追加画面は購入リスト画面からの補助導線として扱い、週状態を共有する。

### Data Layer

- ローカル保存で週次リスト、商品、カテゴリを読み書きする。
- 購入済み状態、削除状態、並び順を一覧表示に必要な形で取得する。
- 商品候補の再利用は共有データとして扱い、購入リスト画面からも参照できるようにする。

## Data and Domain Decisions

- 1週間分の全商品を1画面で表示し、曜日区切りは表示しない。
- 購入済み項目は一覧から外し、進捗表示に反映する。
- 元に戻すは直近の購入済み操作を対象にする。
- 商品追加は画面下部の導線から週単位で開く。
- カテゴリ順はユーザー設定に従って安定表示する。

## Milestones

### 1. Shell and Navigation

- 購入リスト画面をメイン導線に組み込む。
- 画面下部の `購入リスト` と `商品追加` から各画面を開けるようにする。
- 週状態が画面切替で変わらないことを確認する。

### 2. Purchase List UI

- 進捗表示とカテゴリ順の一覧を構築する。
- 左フリックで購入済みにする操作を追加する。
- 空状態と全件購入済みの表示を整える。

### 3. Undo and Delete Actions

- 画面下部の削除・元に戻すを実装する。
- 直近の購入済み操作を復元できるようにする。

### 4. Weekly Add Entry

- 商品追加画面を週単位で開けるようにする。
- 購入リスト画面と追加画面が同じ週を参照するようにする。

### 5. Verification

- Widget tests でナビゲーション、進捗、左フリック、Undo を確認する。
- Repository / data tests で購入済み状態の保持を確認する。
- `flutter analyze` と `flutter test` を実行する。

## Risks and Mitigations

- 購入済みを一覧から消す仕様と削除の仕様が混同しやすい。→ UI 文言と状態遷移を分けて定義する。
- 週状態が画面切替で失われると買い物中の操作が遅くなる。→ 選択週は共有状態に置く。
- Undo を複数段にすると挙動が重くなる。→ 初期版は直近1件に限定する。

## Validation Strategy

- `flutter analyze`
- `flutter test`
- 購入リスト画面の widget tests
- 週次データと購入済み状態の repository tests

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- 複雑な献立管理
- Widget integration