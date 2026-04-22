これから行う作業（短く）
- 仕様設計 → UI 要素・操作・状態遷移を定義します。  
- 実装タスク化 → 実装者向けタスクとテスト要件を提示します。  

設計：カテゴリ並び順設定画面（要点）
- 目的：購入リスト画面で表示されるカテゴリ順をユーザーが並べ替えできるようにする。  
- 主な操作：ドラッグで並び替え、並び替えの即時プレビュー、保存／キャンセル、既定順（リセット）  
- 想定ターゲット画面：設定内の「カテゴリ並び順」画面（モバイル縦画面）

画面構成（上から順）
- ヘッダ：タイトル「カテゴリの並び順」＋閉じる/戻るボタン
- 説明文：短い説明（「購入リストで表示されるカテゴリの順序を並べ替えます」）
- リスト本体：各行に
  - 並べ替えハンドル（ドラッグ領域、アクセシブルに）  
  - カテゴリ名（`Category.name`）  
  - 表示サンプルバッジ（小さく、色や件数のサンプル）  
  - （省略）削除や編集は別画面に委ねる
- フッタ：`キャンセル`（操作を破棄）・`保存`（確定）・`リセット`（既定順に戻す）ボタン

UX 詳細
- 並べ替え方法：長押しまたはハンドルドラッグで行のドラッグ。ドラッグ中はシャドウ＋ホバーで移動先を強調。  
- 即時プレビュー：保存前でも購入リスト画面を開いたときの表示が確認できるよう、並び替え中はローカルプレビュー領域で順序を反映（小さなサンプルリスト）。  
- 保存方式：`保存` で `sort_order` を永続化（バルク更新）。`キャンセル` はローカル変更を破棄。`リセット` は `sort_order` を既定値（例：`sort_order` の小さい順）へ戻す。  
- 同期・競合：ローカルのみ（Drift）。同一端末の複数ビュー間は Provider の invalidate/notify で即時反映。将来クラウド同期がある場合は操作履歴/楽観的更新を検討。

データモデル（既存利用）
- 既存の `Category` に既に `sort_order` がある（data-model.md に記載）。並びは `sort_order` 昇順で決定する。  
- 実装は `sort_order` の整数値を更新するのみ。新カラム不要。

参照すべき既存コード（実装時に確認）
- 選択中の providers: providers.dart（一覧表示の state）  
- リポジトリ: weekly_shopping_repository.dart（カテゴリ読み書き関数を追加/流用）  
- ドメイン型: `Category` / `sort_order`（既存 DB スキーマを利用）

アクセシビリティ & ローカライズ
- ハンドルは十分なタップ領域（48px 相当）。キーボードナビ/スクリーンリーダー対応で行の移動操作を補助（例：上下に移動ボタン）。  
- 文字列は i18n 対応（既存の日本語ベース方針に合わせる）。

受け入れ基準（Acceptance Criteria）
- AC1: 7 個以上のカテゴリが存在してもドラッグで任意順に並べ替えられること。  
- AC2: `保存` を押すと `sort_order` が永続化され、購入リスト画面で同じ順序で表示されること。  
- AC3: `キャンセル` で保存前の順序に戻ること。  
- AC4: `リセット` で既定順に戻ること。  
- AC5: 並べ替え中の行は視覚的に識別でき、スクリーンリーダーで操作の開始／完了が通知されること。  
- AC6: 単体テスト／ウィジェットテストが追加され、CI で合格すること。

テスト案
- 単体（リポジトリ）テスト：
  - カテゴリの `sort_order` 一括更新関数が正しく DB を更新すること。  
- ウィジェットテスト：
  - 並べ替え操作（ドラッグ／フリックの代替としてテスト API で移動）で行が移動することを確認。  
  - `保存` 後に `weekly_shopping_repository.loadCategories()` の順序が期待通りであること。  
  - `キャンセル` で変更がロールバックされる UI 状態確認。  
- 手動 E2E（quickstart）：
  - 実機でドラッグ→保存→購入リストで順序反映を確認。

実装タスク（実装者向け、優先度順）
- 1. UI コンポーネント
  - 実装ファイル案：`lib/features/settings/presentation/category_order_screen.dart`（新規） — 並べ替えリストとボタン群を実装。  
  - 使用ウィジェット：`ReorderableListView`（簡潔）、またはカスタムドラッグでより細かい UX。
- 2. データ層
  - `WeeklyShoppingRepository` に `Future<void> updateCategoryOrder(List<CategoryOrderUpdate> updates)` を追加（バルク更新）。（参照: weekly_shopping_repository.dart）
- 3. State 管理
  - 画面はローカル state（`StateNotifier`）で編集中の順序を保持。保存時に repository を呼ぶ。保存後 `ref.invalidate(...)` で一覧を再読み込み。
- 4. テスト
  - 単体テスト（リポジトリの更新処理）、ウィジェットテスト（並べ替え＋保存フロー）。
- 5. ドキュメント
  - specs 下に quickstart 手順を追加（既定の quickstart.md に追記）、必要なら UI スクリーンショット例。

簡易タスク一覧（speckit 風）
- T1 [P1] 画面コンポーネント作成（`category_order_screen.dart`） — 並べ替え UI + 保存/キャンセル/リセット。  
- T2 [P1] リポジトリ関数追加：`updateCategoryOrder`（DB バルク更新）。  
- T3 [P1] StateNotifier 実装：編集中の順序を保持し、保存で repository 呼び出し。  
- T4 [P1] ウィジェットテスト：ドラッグ→保存→順序反映を検証（test）。  
- T5 [P2] 単体テスト：リポジトリの DB 更新ロジック（repository_test.dart に追加）。  
- T6 [P3] 手動検証・ドキュメント（quickstart 実機手順）。

実装上の注意点（短く）
- `ReorderableListView` は内部でインデックスで管理するため、保存時に各カテゴリへ新しい `sort_order` を再割り当てして DB に保存する。  
- 既存の `sort_order` が重複している場合は再割り当てで連続値（0..N-1）に整える。  
- 変更はまとめてトランザクション内で行う（Drift のトランザクションを利用）。

次に行うこと（短く）
1. 画面のウィジェット構成と状態設計を提示します。  
2. リポジトリ API と保存ロジックの疑似コードを示します。  
3. 必要なテストと quickstart 実行手順を提示します。

設計：カテゴリ並び順設定画面（詳細）

- 目的：購入リスト画面で表示されるカテゴリの順序をユーザーがドラッグで変更し、`sort_order` を永続化する。

画面ファイル（提案）
- 新規 UI: lib/features/settings/presentation/category_order_screen.dart
- State: lib/features/settings/state/category_order_notifier.dart
- リポジトリ追加: weekly_shopping_repository.dart

主要 UI（ウィジェット構成）
- `CategoryOrderScreen` (Stateful/ConsumerWidget)
  - AppBar: タイトル「カテゴリの並び順」＋戻る/閉じる
  - 説明文: 小さなヘルプテキスト
  - プレビュー（任意）: 小さなサンプル表示（省略可）
  - リスト本体: ReorderableListView.builder
    - 各行: ハンドルアイコン（ドラッグ用）、`Text(category.name)`、小バッジ（件数など）
  - フッタ: `キャンセル` / `リセット` / `保存` ボタン

UI 挙動（要点）
- 起動時に `CategoryOrderNotifier` が `WeeklyShoppingRepository.loadCategories()` を読み順序を昇順で取得。
- ユーザー操作でローカルリストを入れ替え（ReorderableListView が提供）。表示上は即時反映（プレビュー不要なら省略可）。
- `保存` 押下で Notifier が `updateCategoryOrder` を呼び、バルク更新。成功時に `ref.invalidate(...)` して一覧を再取得。
- `キャンセル` は Notifier のローカル変更を破棄して画面を閉じる。
- `リセット` は既定順（例: `sort_order` 昇順）を再ロードして表示を戻す。

状態設計（StateNotifier）
- `CategoryOrderState`:
  - `List<CategoryEntry> items` （編集中の順序）
  - `bool isSaving`
  - `String? error`
- `CategoryOrderNotifier`（extends StateNotifier<CategoryOrderState>）
  - `load()` — 初期読み込み
  - `move(int fromIndex, int toIndex)` — ローカル操作
  - `reset()` — DB の既定順を再読み込み
  - `save()` — 永続化（呼び出し先: repository.updateCategoryOrder）

リポジトリ API（追加提案）
- シグネチャ:
  - class CategoryOrderUpdate { final int id; final int sortOrder; }
  - Future<void> updateCategoryOrder(List<CategoryOrderUpdate> updates)
- 実装方針（疑似コード）:
  - await database.transaction(() async {
      for (final u in updates) {
        await into(database.categories).update(
          CategoriesCompanion(sortOrder: Value(u.sortOrder)),
          where: (t) => t.id.equals(u.id),
        );
      }
    });
  - invalidate any caches if needed.

保存時の `sort_order` 付与ルール
- ReorderableListView の現在インデックス i に対して順に `sort_order = i`（または i*10 などの間隔）を割り当て、DB をトランザクションで一括更新。
- 既存重複があれば再割り当てで連続値に揃える。

アクセシビリティ
- ドラッグハンドルは 48x48px を確保。スクリーンリーダー向けに「移動モード開始」「移動先に挿入」等を announce（`Semantics` ウィジェットでラベル）。
- キーボード操作: 行を選択 → 上下移動ボタンで順序変更（補助実装）。

テスト計画（ファイル／内容）
- リポジトリ単体テスト
  - ファイル: weekly_buyer/test/repository_test.dart（既存）に `updateCategoryOrder` のトランザクション検証を追加
  - 検証: バルク更新後に `select categories order by sort_order` で期待順になること
- ウィジェットテスト
  - ファイル: weekly_buyer/test/category_order_widget_test.dart
  - シナリオ:
    - 初期読み込みで行が DB の `sort_order` に沿うこと
    - テスト API で `reorder` をシミュレート（`tester.drag` or `tester.reorder` パターン）して UI が変わること
    - `保存` を押して DB が更新されること（モック/実メモリ DB）
    - `キャンセル` で UI が元に戻ること
- Quick manual
  - 端末でドラッグ→保存→購入リスト画面で順序反映を確認

簡易実装タスク（speckit 形式）
- T1 [P1] 新規 UI `lib/features/settings/presentation/category_order_screen.dart` を実装（ReorderableListView + ボタン）。  
- T2 [P1] `WeeklyShoppingRepository.updateCategoryOrder` を実装（Drift トランザクションのバルク更新）。  
- T3 [P1] `CategoryOrderNotifier` を実装／Provider 登録。  
- T4 [P1] ウィジェットテストを追加（`weekly_buyer/test/category_order_widget_test.dart`）。  
- T5 [P2] リポジトリ単体テストを追加（repository_test.dart）。  
- T6 [P3] docs/quickstart を更新（手動検証手順）。

簡単な UI 疑似コード（抜粋）
- In `category_order_screen.dart`:
  - build:
    - final state = ref.watch(categoryOrderProvider);
    - return Scaffold(
        appBar: AppBar(...),
        body: Column(
          children: [
            Text('説明文'),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  final c = state.items[index];
                  return ListTile(
                    key: ValueKey(c.id),
                    leading: Icon(Icons.drag_handle),
                    title: Text(c.name),
                    trailing: Chip(label: Text('${c.sampleCount}')),
                  );
                },
                onReorder: (oldIndex, newIndex) => ref.read(categoryOrderProvider.notifier).move(oldIndex, newIndex),
              ),
            ),
            Row(children: [
              TextButton(onPressed: () => ref.read(categoryOrderProvider.notifier).reset(), child: Text('リセット')),
              Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('キャンセル')),
              ElevatedButton(onPressed: () async { await ref.read(categoryOrderProvider.notifier).save(); Navigator.pop(context); }, child: Text('保存')),
            ])
          ]
        )
      );

実装上の注意点（再掲）
- 保存はトランザクションで一括更新。UI 側は保存中フラグで二重押下や進行中表示対応。
- 既存一覧表示側は `ref.invalidate(...)` または repository の読み込み時に自動で新順序を取り込めるようにする。

試験実行コマンド（ローカル）
```bash
cd weekly_buyer
flutter test
flutter analyze
```

