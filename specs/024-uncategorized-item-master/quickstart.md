# Quickstart: 未分類商品の商品マスター登録

## Goal

購入リスト画面で未分類 item を長押しし、カテゴリとひらがなを入力して商品マスターに登録できるようにする。

## Recommended Implementation Steps

1. `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart` に未分類 item 用の long-press ハンドラを追加する。
2. 既存の `item_editor_destination.dart` を使って、商品名を購入項目名で初期化した登録シートを開く。
3. `WeeklyShoppingRepository.addItemMaster` を呼び出して、入力されたひらがなとカテゴリで保存する。
4. 登録後に購入リストと候補一覧を再読み込みする。
5. widget test と repository test を追加して、導線と保存結果を確認する。

## Validation

```bash
cd weekly_buyer
flutter analyze
flutter test test/repository_test.dart test/category_item_settings_test.dart
flutter test test/widget_test.dart
```

## Acceptance Checks

- 未分類 item にのみ登録導線が出る。
- ひらがなが空欄だと登録されない。
- カテゴリ未選択では登録されない。
- 登録後の item が候補として再利用できる。