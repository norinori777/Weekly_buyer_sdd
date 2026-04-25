# Quickstart: 「次も登録」ボタンと補足文の改善

## Goal
商品追加フォームで、連続登録用ボタンの文言と補足が分かりやすく表示されることを確認する。

## Prerequisites
- Flutter SDK が利用可能であること。
- `weekly_buyer` プロジェクトが開けること。

## Validate

```powershell
cd weekly_buyer
flutter analyze
flutter test
```

## Manual flow
1. 商品追加画面を開く。
2. 連続入力用のボタンが「次も登録」と表示されていることを確認する。
3. ボタンの下に「保存して続けて入力できます」と小さく表示されていることを確認する。
4. 通常の登録ボタンと役割が見分けやすいことを確認する。

## Expected results
- 連続登録のボタン名が短く分かりやすくなる。
- 補足文で保存後の挙動が理解しやすくなる。
- 既存の連続登録動作は変わらない。
