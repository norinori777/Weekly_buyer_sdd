# Quickstart: 購入リスト画面カテゴリ内商品のひらがな順ソート

**Date**: 2026-05-24  
**Feature**: [spec.md](spec.md)

## 前提条件

- Flutter SDK（バージョンは `weekly_buyer/pubspec.yaml` 参照）
- `cd weekly_buyer` でアプリディレクトリに移動済み

---

## 変更ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart` | `ShoppingItemEntry` に `hiragana` フィールドを追加 |
| `lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart` | `loadWeek` でひらがな設定、`_groupEntriesByCategory` でソート追加 |
| `test/repository_test.dart` | カテゴリ内ひらがな順ソートの integration test を追加 |

---

## ビルド & 静的検査

```powershell
cd c:\work\AndroidApp\Weekly_buyer_sdd\weekly_buyer

# 静的解析
dart analyze

# フォーマット確認
dart format --output none --set-exit-if-changed lib/ test/
```

## テスト実行

```powershell
# 全テスト
flutter test

# リポジトリテストのみ
flutter test test/repository_test.dart
```

---

## 手動動作確認手順

### 事前準備

1. カテゴリ「野菜」を作成し、以下の商品を登録（設定 → カテゴリと商品）:
   - `たまねぎ` / ひらがな: `たまねぎ`
   - `キャベツ` / ひらがな: `きゃべつ`（カタカナのひらがな変換確認用）
   - `ブロッコリー` / ひらがな: `ぶろっこりー`
   - `アスパラ` / ひらがな未設定（末尾配置確認用）

2. 週間リストにすべての商品を追加する。

### 確認手順

1. 購入リスト画面を開く
2. 「野菜」カテゴリ内の商品順が以下になっていることを確認:

   ```
   1. キャベツ  （ひらがな: きゃべつ）
   2. たまねぎ  （ひらがな: たまねぎ）
   3. ブロッコリー（ひらがな: ぶろっこりー）
   4. アスパラ  （ひらがな未設定 → 末尾）
   ```

3. 商品を1件購入済みにした後、残りの商品もひらがな昇順を維持していることを確認する。

4. 新しい商品「いちご」（ひらがな: `いちご`）を追加し、「きゃべつ」と「たまねぎ」の間に表示されることを確認する。

---

## 回帰テスト観点

| テストケース | 期待結果 |
|------------|---------|
| 既存の購入済み操作（左フリック）| ソート順に影響しない |
| 元に戻す操作 | ひらがな順に再配置される |
| カテゴリ順設定画面からカテゴリ順を変更 | カテゴリ間の順序は変わるが、カテゴリ内のひらがな順は維持される |
| ひらがな未設定の商品が複数ある場合 | 末尾にまとめて表示され、その中は商品名昇順 |
