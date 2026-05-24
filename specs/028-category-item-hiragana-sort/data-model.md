# Data Model: 購入リスト画面カテゴリ内商品のひらがな順ソート

**Date**: 2026-05-24  
**Feature**: [spec.md](spec.md)

## スキーマ変更

**DB スキーマ変更なし。** `item_masters.hiragana` カラムはすでに存在し、ソートはアプリ層で実施する。

---

## ドメインモデル変更

### `ShoppingItemEntry`（変更）

`lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`

| フィールド | 型 | 変更 | 説明 |
|-----------|-----|------|------|
| `id` | `int` | 既存 | |
| `weekday` | `int` | 既存 | |
| `section` | `ShoppingSection` | 既存 | |
| `name` | `String` | 既存 | 表示用商品名 |
| `quantity` | `int` | 既存 | |
| `isPurchased` | `bool` | 既存 | |
| `sortOrder` | `int` | 既存 | |
| `categoryId` | `int?` | 既存 | |
| `categoryName` | `String?` | 既存 | |
| `itemMasterId` | `int?` | 既存 | |
| `purchaseDate` | `DateTime?` | 既存 | |
| **`hiragana`** | **`String?`** | **追加** | 商品マスターから引き継いだひらがな読み（ソートキー） |

`copyWith` にも `hiragana` を追加（省略時は `this.hiragana` を維持）。

---

## リポジトリ変更

### `WeeklyShoppingRepository`（変更）

`lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`

#### `loadWeek` メソッド

`_loadItemMasters()` の結果からひらがなルックアップマップを構築し、`ShoppingItemEntry` の `hiragana` フィールドに設定する。

```dart
// 追加: itemMasterId -> hiragana のルックアップ
final hiraganaByMasterId = <int, String?>{
  for (final m in itemMasters) m.id: m.hiragana,
};

final entries = rawItems.map((item) => ShoppingItemEntry(
  // ... 既存フィールド ...
  hiragana: item.itemMasterId == null
      ? null
      : hiraganaByMasterId[item.itemMasterId],
)).toList();
```

#### `_groupEntriesByCategory` メソッド

グループ化後、各グループの `items` をひらがな昇順でソートする。

```dart
// ソートキー変換（カタカナ→ひらがな正規化 + 空キーを末尾へ）
String _sortKeyFor(ShoppingItemEntry entry) {
  final hiragana = entry.hiragana?.trim();
  if (hiragana == null || hiragana.isEmpty) return '\uFFFF${entry.name}';
  return '${_normalizeToHiragana(hiragana)}\t${entry.name}'; // タブで2段ソート
}

// カタカナ → ひらがな変換（U+30A1–U+30F6 → U+3041–U+3096）
String _normalizeToHiragana(String s) =>
    s.replaceAllMapped(RegExp(r'[\u30a1-\u30f6]'),
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60));
```

`ShoppingCategoryGroup` を生成する際に `items` をソート済みリストで渡す:

```dart
orderedGroups.add(
  ShoppingCategoryGroup(
    categoryId: category.key,
    categoryName: category.value,
    items: List.unmodifiable(
      [...items]..sort((a, b) => _sortKeyFor(a).compareTo(_sortKeyFor(b))),
    ),
  ),
);
```

---

## 状態遷移

ソートは `loadWeek` の結果（`WeeklyShoppingSnapshot.categoryGroups`）に反映され、そのまま `weeklyShoppingSnapshotProvider` 経由で購入リスト画面に届く。UI 側の変更は不要。

```
itemMasters (DB)
     ↓ _loadItemMasters()
hiraganaByMasterId (Map<int, String?>)
     ↓ entries mapping
ShoppingItemEntry.hiragana
     ↓ _groupEntriesByCategory → sort
ShoppingCategoryGroup.items (ひらがな昇順)
     ↓ weeklyShoppingSnapshotProvider
PurchaseListDestination → _CategoryGroupCard → items
```

---

## 検証規則

| 条件 | ソートキー | 結果 |
|------|----------|------|
| `hiragana = 'あいうえお'` | `'あいうえお\tX'` | 先頭付近 |
| `hiragana = 'アイウエオ'`（カタカナ） | `'あいうえお\tX'` | ひらがなと同等に扱う |
| `hiragana = ''` または `null` | `'\uFFFFX'` | 末尾 |
| ひらがな同一、`name` 異なる | `'あ\tA'` vs `'あ\tB'` | 商品名昇順 |
