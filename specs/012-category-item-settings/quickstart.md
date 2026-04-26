# Quickstart: Category and Item Settings

## Goal
カテゴリと商品マスタの管理画面を確認し、削除禁止ルールと入力欄の簡素化を検証する。

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
1. 設定画面を開く。
2. カテゴリ管理画面からカテゴリを追加・編集・削除する。
3. 商品管理画面から商品を追加・編集・削除する。
4. 商品があるカテゴリは削除できないことを確認する。
5. 現在の購入週に含まれる商品は削除できないことを確認する。

## Expected results
- カテゴリ編集に色・説明欄は表示されない。
- 商品編集に数量入力欄は表示されない。
- 削除不可時に理由が表示される。
