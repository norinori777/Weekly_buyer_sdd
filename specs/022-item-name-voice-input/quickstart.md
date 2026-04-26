# Quickstart: 商品名音声入力

## Goal

商品追加画面の商品名欄から音声入力を開始し、認識結果を編集して保存できることを確認する。

## Validation Steps

1. アプリを起動する。
2. 商品追加画面を開く。
3. 商品名欄の音声入力起点を押す。
4. 商品名を話して、認識結果が欄に反映されることを確認する。
5. 反映された商品名を必要に応じて編集する。
6. そのまま商品を保存する。

## Test Commands

```bash
cd weekly_buyer
flutter analyze
flutter test test/widget_test.dart
```

## Expected Result

- 商品名欄に音声で入力した内容が表示される。
- 認識結果は保存前に修正できる。
- 音声入力が失敗しても、手入力で商品名入力を続けられる。
