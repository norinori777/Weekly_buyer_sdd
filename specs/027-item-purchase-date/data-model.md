# Data Model: 商品への購入日設定

**Feature**: `027-item-purchase-date`  
**Date**: 2026-05-23

## エンティティ変更一覧

---

### 1. WeeklyListItems テーブル（Drift）

**変更種別**: カラム追加

| カラム名 | 型 | NULL | デフォルト | 説明 |
|---------|-----|------|-----------|------|
| `purchase_date` | `DateTime` | ✅ nullable | `null` | ユーザーが設定した購入予定日（日付のみを使用） |

**スキーマバージョン**: 5 → **6**  
**マイグレーション**: `migrator.addColumn(weeklyListItems, weeklyListItems.purchaseDate)` をバージョン 6 の `onUpgrade` に追加

**既存データへの影響**: なし（nullable カラムのため、既存行は `purchase_date = NULL` として扱われる）

---

### 2. ShoppingItemEntry（ドメインモデル）

**変更種別**: フィールド追加

```
ShoppingItemEntry
├── id: int                     (変更なし)
├── weekday: int                (変更なし)
├── section: ShoppingSection    (変更なし)
├── name: String                (変更なし)
├── quantity: int               (変更なし)
├── isPurchased: bool           (変更なし)
├── sortOrder: int              (変更なし)
├── categoryId: int?            (変更なし)
├── categoryName: String?       (変更なし)
├── itemMasterId: int?          (変更なし)
└── purchaseDate: DateTime?     ← 新規追加（任意）
```

**バリデーション**: なし（null 許容、値があれば日付として有効）  
**copyWith**: `purchaseDate` パラメータを追加

---

### 3. AddItemRequest（ドメインモデル）

**変更種別**: フィールド追加

```
AddItemRequest
├── name: String                (変更なし)
├── quantity: int               (変更なし)
├── section: ShoppingSection    (変更なし)
├── itemMasterId: int?          (変更なし)
├── categoryId: int?            (変更なし)
└── purchaseDate: DateTime?     ← 新規追加（任意）
```

---

### 4. ItemAddDraft（状態モデル）

**変更種別**: フィールド追加

```
ItemAddDraft
├── name: String                (変更なし)
├── quantityText: String        (変更なし)
├── section: ShoppingSection    (変更なし)
├── selectedCandidateId: int?   (変更なし)
├── categoryId: int?            (変更なし)
└── purchaseDate: DateTime?     ← 新規追加（任意）
```

**copyWith**: `purchaseDate` パラメータを追加

---

## データフロー

```
[ItemEntryForm]
  ↓ ユーザーがカレンダーから日付選択 or クリア
[ItemAddDraft.purchaseDate] ← StateProvider 経由で更新
  ↓ 登録ボタン押下
[AddItemRequest.purchaseDate]
  ↓ WeeklyShoppingRepository.addItem()
[WeeklyListItems.purchase_date] in SQLite
  ↓ WeeklyShoppingRepository._loadWeeklyListItems()
[ShoppingItemEntry.purchaseDate]
  ↓ WeeklyShoppingSnapshot 経由
[UI: _SectionPreviewCard / _PurchaseItemTile]
  → purchaseDate != null の場合: '${date.month}月${date.day}日' を数量横に表示
  → purchaseDate == null の場合: 何も表示しない
```

---

## 状態遷移

| 状態 | 購入日フィールドの表示 | × ボタンの表示 |
|------|-------------------|--------------|
| 未入力（初期値） | 「購入日（任意）」プレースホルダー | 非表示 |
| 日付選択済み | `M月D日`（例: 5月23日） | 表示 |
| × 押下後 | 「購入日（任意）」プレースホルダー | 非表示 |

---

## ユーティリティ関数

### `formatPurchaseDate`

**追加場所**: `weekly_shopping_models.dart`（ファイル末尾のトップレベル関数群に追加）

```
入力: DateTime date
出力: String — 例 '5月23日'
ロジック: '${date.month}月${date.day}日'
```

既存の `_shortDate` 関数（`MM/DD` 形式）とは別に追加し、`M月D日` 形式に特化する。
