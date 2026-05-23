# Quickstart: 商品への購入日設定

**Feature**: `027-item-purchase-date`  
**Date**: 2026-05-23

## 変更ファイル一覧と作業順序

変更は依存関係の順（データ層 → ドメイン → 状態 → UI）に実施する。

---

## Step 1: データベーススキーマ更新

**ファイル**: `weekly_buyer/lib/app/app_database.dart`

### 1-a. `WeeklyListItems` テーブルにカラム追加

`updatedAt` カラムの直前に追加：

```dart
// 追加する行
DateTimeColumn get purchaseDate => dateTime().nullable()();
```

### 1-b. `schemaVersion` を 6 に変更

```dart
// 変更前
int get schemaVersion => 5;
// 変更後
int get schemaVersion => 6;
```

### 1-c. `onUpgrade` に case 6 追加

既存の migration switch 内に追加：

```dart
case 6:
  await migrator.addColumn(weeklyListItems, weeklyListItems.purchaseDate);
```

---

## Step 2: ドメインモデル更新

**ファイル**: `weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`

### 2-a. `ShoppingItemEntry` にフィールド追加

コンストラクタと `copyWith` に `purchaseDate: DateTime?` を追加する。

### 2-b. `AddItemRequest` にフィールド追加

コンストラクタに `this.purchaseDate` を追加する（nullable、デフォルト null）。

### 2-c. `formatPurchaseDate` ユーティリティ関数を追加

ファイル末尾に追加：

```dart
String formatPurchaseDate(DateTime date) => '${date.month}月${date.day}日';
```

---

## Step 3: 状態モデル更新

**ファイル**: `weekly_buyer/lib/app/app_state_providers.dart`

`ItemAddDraft` に `purchaseDate: DateTime?` フィールドと `copyWith` 対応を追加する。

---

## Step 4: リポジトリ更新

**ファイル**: `weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`

### 4-a. `addItem` — 挿入時に `purchaseDate` を渡す

```dart
WeeklyListItemsCompanion.insert(
  // 既存フィールド...
  purchaseDate: Value(request.purchaseDate),  // 追加
)
```

### 4-b. `_loadWeeklyListItems` — マッピングに `purchaseDate` を追加

```dart
ShoppingItemEntry(
  // 既存フィールド...
  purchaseDate: item.purchaseDate,  // 追加
)
```

### 4-c. `undoLatestPurchase` — `ShoppingItemEntry` 生成箇所に `purchaseDate` を追加

```dart
ShoppingItemEntry(
  // 既存フィールド...
  purchaseDate: row.purchaseDate,  // 追加
)
```

---

## Step 5: フォームUI更新

**ファイル**: `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_entry_form.dart`

### 5-a. `_ItemEntryFormState` に状態追加

```dart
DateTime? _purchaseDate;
```

`initState` で `widget.initialValue.purchaseDate` から初期化する。

### 5-b. 数量フィールドの後に購入日フィールドを追加

```dart
const SizedBox(height: 12),
GestureDetector(
  onTap: () async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _purchaseDate = picked);
      widget.onChanged?.call(/* draft に purchaseDate 含む */);
    }
  },
  child: AbsorbPointer(
    child: TextFormField(
      decoration: InputDecoration(
        labelText: '購入日（任意）',
        border: const OutlineInputBorder(),
        suffixIcon: _purchaseDate != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() => _purchaseDate = null);
                  widget.onChanged?.call(/* draft に purchaseDate: null */);
                },
              )
            : null,
      ),
      controller: TextEditingController(
        text: _purchaseDate != null ? formatPurchaseDate(_purchaseDate!) : '',
      ),
    ),
  ),
),
```

### 5-c. `onSubmit` / `onContinueAdd` 呼び出しに `purchaseDate` を含める

`AddItemRequest` 生成箇所に `purchaseDate: _purchaseDate` を追加する。

---

## Step 6: 商品追加画面のリスト表示更新

**ファイル**: `weekly_buyer/lib/features/weekly_shopping_list/presentation/item_add_destination.dart`

`_SectionPreviewCard` 内の `ListTile` のサブタイトル部分を更新：

```dart
// 変更前
subtitle: Text(
  '数量 ${item.quantity}',
  ...
),

// 変更後
subtitle: Text(
  item.purchaseDate != null
      ? '数量 ${item.quantity}　${formatPurchaseDate(item.purchaseDate!)}'
      : '数量 ${item.quantity}',
  ...
),
```

---

## Step 7: 購入リスト画面の表示更新

**ファイル**: `weekly_buyer/lib/features/weekly_shopping_list/presentation/purchase_list_destination.dart`

`_PurchaseItemTile` 内の `ListTile` のサブタイトルを更新：

```dart
// 変更前
subtitle: Text('数量 ${item.quantity}'),

// 変更後
subtitle: Text(
  item.purchaseDate != null
      ? '数量 ${item.quantity}　${formatPurchaseDate(item.purchaseDate!)}'
      : '数量 ${item.quantity}',
),
```

---

## Step 8: Drift コード生成

スキーマ変更後にコード生成を実行する：

```powershell
cd weekly_buyer
dart run build_runner build --delete-conflicting-outputs
```

---

## Step 9: テスト実行

```powershell
cd weekly_buyer
flutter test
flutter analyze
```

既存テストは `purchaseDate` が nullable でデフォルト `null` のため変更不要。  
ただし `ShoppingItemEntry` を直接生成しているテストは `purchaseDate` 引数の追加が必要な場合がある（コンパイルエラーで検出される）。

---

## 検証チェックリスト

- [ ] `flutter analyze` でエラーなし
- [ ] `flutter test` 全テスト PASS
- [ ] 商品追加フォームに「購入日（任意）」フィールドが表示される（数量の下）
- [ ] タップするとカレンダーピッカーが開く
- [ ] 日付選択後、フィールドに `M月D日` 形式で表示され × ボタンが出る
- [ ] × タップで日付がリセットされる
- [ ] 購入日なしでも商品追加できる
- [ ] 商品追加画面のリストで購入日あり商品に `数量 X　M月D日` が表示される
- [ ] 商品追加画面のリストで購入日なし商品は `数量 X` のみ表示される
- [ ] 購入リスト画面でも同様の表示条件が適用される
