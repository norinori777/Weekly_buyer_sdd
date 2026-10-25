# Research: 購入済み通知の重複解消と自動消去

## 現状の調査結果

- 購入済み操作 (`onTogglePurchased`) は、`purchase_list_destination.dart` と `weekly_shopping_page.dart` の両方で黒色の `SnackBar` (「{商品名} を購入済みにしました」+「元に戻す」) を表示している。
- 同時に、画面内の `UndoBanner` (`weekly_shopping_page.dart`) が `hiddenPurchasedCount > 0 || lastPurchasedItem != null` の間ずっと表示される。これが重複表示と常時表示の原因。
- `UndoBanner` は購入済み商品が 1 件でもあれば消えない。機能 026 (購入済みを非表示のまま保持) の仕様に由来する。

## 決定事項

### 1. 重複の解消

- **Decision**: 購入済み操作での `SnackBar` を削除し、画面内の `UndoBanner` を残す。
- **Rationale**: 要望で黒色背景の通知そのものを出さないと確定している。`UndoBanner` は「元に戻す」を内包している。
- **Alternatives considered**: SnackBar を残し Banner を消す案は要望と逆のため却下。SnackBar の文言だけ消す案は、確定済みの要望 (通知自体を出さない) に反するため却下。

### 2. 通知の状態管理

- **Decision**: `StateProvider<PurchaseUndoNotice?>` を `app_state_providers.dart` に追加する (商品名と発生時刻を保持)。
- **Rationale**: 既存コードが `StateProvider` を多用しており (`mainShellDestinationProvider` など)、技術スタック固定の原則に合致する。新規依存なし。
- **Alternatives considered**: Widget ローカル状態のみ。タブ切替で Widget が破棄・再生成されるため遷移時消去は自然に満たせるが、`ref.invalidate` による再構築や 2 つのホストでの共有に弱いため却下。Notifier クラス化は過剰。

### 3. 3 秒タイマー

- **Decision**: ホスト Widget に `Timer` を持たせ、通知変更時にキャンセル・再設定、`dispose` でキャンセルする。
- **Rationale**: 連続購入時に 3 秒を数え直せる (FR-006)。テストで `tester.pump(Duration)` により決定的に検証できる。
- **Alternatives considered**: `Future.delayed` はキャンセルできず、古いタイマーが新しい通知を消す恐れがあるため却下。`SnackBar` の `duration` は SnackBar 自体を出さないため不適。

### 4. 画面遷移での消去

- **Decision**: `ref.listen(mainShellDestinationProvider)` で遷移を検知して通知を消し、ホストの `dispose` でも消す。
- **Rationale**: 本アプリの主な画面遷移は下部ナビゲーションによる shell 切替であり、購入リスト画面から `Navigator.push` するのは設定画面側のみ。いずれも購入リストの Widget が破棄または非表示となるため、この 2 点で FR-005 を満たせる。
- **Alternatives considered**: `RouteObserver` を全体に導入する案は、追加の配線に見合う利点がないため却下。

### 5. 既存テストへの影響

- 機能 026 のテスト (`keeps purchased items hidden after switching between list tabs`) は、タブ切替後も「購入済みにしました (1)」が残ることを期待している。新仕様では遷移で通知が消えるため、期待値を更新する。商品が非表示のままであること、DB が購入済みであることの検証は維持する。

## 未解決事項

なし (NEEDS CLARIFICATION は存在しない)。
