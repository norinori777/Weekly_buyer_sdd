# Data Model: 未分類商品の商品マスター登録

## Overview

この機能は新しい永続テーブルを追加しない。既存の purchase list item から、既存の item master 登録 API を通じて再利用可能な商品マスター項目を作成する。

## Entities

### Purchase List Item

- Purpose: 週次の購入リストに表示される個別項目。
- Relevant fields: `id`, `name`, `categoryId`, `categoryName`, `itemMasterId`, `isPurchased`, `weekday`, `section`, `quantity`.
- Validation for this feature: `categoryId == null` の場合のみ長押し登録の対象にする。

### Product Master Entry

- Purpose: 次回以降の入力で再利用できる商品定義。
- Relevant fields: `id`, `name`, `hiragana`, `categoryId`, `categoryName`, `defaultQuantity`.
- Validation for this feature: `name` と `hiragana` は空欄不可。`categoryId` は選択されたカテゴリまたは null だが、今回の登録フローではカテゴリ選択必須。

### Category

- Purpose: 商品を分類する既存のカテゴリ。
- Relevant fields: `id`, `name`, `sortOrder`, `isActive`.
- Validation for this feature: 登録フロー開始時に少なくとも 1 件のカテゴリが存在すること。

### Uncategorized Registration Draft

- Purpose: 長押しから登録完了までの一時状態。
- Fields: `sourceItemId`, `sourceItemName`, `selectedCategoryId`, `hiraganaInput`, `referenceDate`.
- Validation for this feature: `sourceItemId` は未分類 item に紐づくこと。`hiraganaInput` は空欄不可。`selectedCategoryId` は必須。

## Relationships

- A Purchase List Item can create zero or one Product Master Entry through this flow.
- A Product Master Entry belongs to one Category or remains uncategorized only if the user explicitly chooses that path in other features; for this feature the category is required.
- A Registration Draft is derived from exactly one Purchase List Item.

## State Transitions

1. `purchase-list item (uncategorized)` -> `registration draft`
2. `registration draft` -> `product master entry created`
3. `registration draft` -> `canceled`

## Notes

- No schema migration is needed.
- The registered item becomes available through the existing candidate loading/search flow after save.