# Research: 商品への購入日設定

**Feature**: `027-item-purchase-date`  
**Date**: 2026-05-23

## 調査課題と結論

---

### 1. Flutter の日付ピッカー実装方法

**Decision**: `showDatePicker`（Flutter SDK 標準 Material 3 API）を使用する

**Rationale**:
- Flutter SDK に組み込み済みのため追加ライブラリ不要。Constitution III（技術スタック固定）に完全適合
- Material 3 スタイルのカレンダーダイアログが自動的に適用される
- `initialDate`、`firstDate`、`lastDate` による日付範囲制限が可能
- `locale: const Locale('ja')` を渡すと日本語表示になる（`flutter_localizations` は既存 pubspec に含まれていることを前提）

**API シグネチャ（参考）**:
```dart
final picked = await showDatePicker(
  context: context,
  initialDate: _purchaseDate ?? DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  locale: const Locale('ja'),
);
if (picked != null) {
  setState(() => _purchaseDate = picked);
}
```

**Alternatives considered**:
- `table_calendar` パッケージ: 高機能だが Constitution III に反するため却下
- テキスト直接入力: スペック Assumption で対象外と明記されているため却下

---

### 2. `M月D日` 形式への日付フォーマット

**Decision**: `intl` パッケージの `DateFormat` または Dart 組み込みの文字列補間で対応する

**Rationale**:
- `intl` パッケージは既存の pubspec.yaml に含まれている可能性が高い（Flutter 標準プロジェクトの依存として）
- `DateFormat('M月d日', 'ja').format(date)` で `5月23日` 形式が得られる
- あるいは `'${date.month}月${date.day}日'` の Dart 組み込み文字列補間でも同等の出力が得られる（`intl` 不要）

**推奨実装**（シンプルさ優先）:
```dart
String formatPurchaseDate(DateTime date) => '${date.month}月${date.day}日';
```

`weekly_shopping_models.dart` のトップレベル関数として追加する（既存の `_shortDate` 等と同様のパターン）

**Alternatives considered**:
- `DateFormat('M月d日')`: intl 依存が増えるが効果が同じのためオーバーエンジニアリング

---

### 3. Drift での nullable DateTimeColumn 追加とスキーマ移行

**Decision**: `dateTime().nullable()()` カラムを `WeeklyListItems` に追加し、`schemaVersion` を 5 → 6 に上げてマイグレーションを追加する

**Rationale**:
- Drift の `MigrationStrategy.onUpgrade` で `migrator.addColumn(table, column)` を呼ぶだけで列追加できる
- nullable カラムのため既存行の値は自動的に `null` になり、既存データは破壊されない
- Constitution V（データ再利用と拡張性）に適合：既存商品は `purchaseDate == null` として扱われ、表示側では非表示になる

**実装パターン**:
```dart
// app_database.dart
class WeeklyListItems extends Table {
  // ... 既存カラム ...
  DateTimeColumn get purchaseDate => dateTime().nullable()();
}

// schemaVersion
int get schemaVersion => 6;

// onUpgrade
case 6:
  await migrator.addColumn(weeklyListItems, weeklyListItems.purchaseDate);
```

**Alternatives considered**:
- デフォルト値あり（`withDefault`）: 購入日なしの概念が表現できないため却下
- 別テーブルに分離: 1:1 関係で必要性が薄く、複雑さが増すため却下

---

### 4. `ItemEntryForm` フォームへの日付ピッカーUI組み込み

**Decision**: 既存の `_ItemEntryFormState` に `DateTime? _purchaseDate` 状態を追加し、数量フィールドの後に専用の日付選択行を挿入する。`×` アイコンは `suffixIcon` として `InputDecoration` に設定する

**Rationale**:
- 既存フォームは `StatefulWidget` (`ConsumerStatefulWidget`) なので状態追加が容易
- `GestureDetector` + `AbsorbPointer` + `TextFormField` パターンで「タップで日付選択、テキスト直接入力不可」を実現できる
- `suffixIcon` による × ボタンは `date != null` のときのみ表示（FR-005 を満たす）
- `onChanged` コールバックで `ItemAddDraft.purchaseDate` を更新し、状態を上位へ伝達する

**UI レイアウト（イメージ）**:
```
[商品名テキストフィールド]
[数量フィールド]
[購入日 タップして選択  ×]  ← 新規追加（数量の次・最後）
[登録するボタン]
```

**Alternatives considered**:
- `StatelessWidget` 化: 既存コードが StatefulWidget のため変更が大きすぎる → 却下
- `showBottomSheet` でカレンダーを表示: Material 3 の `showDatePicker` ダイアログで十分

---

### 5. 既存テストへの影響

**Decision**: `AddItemRequest` と `ShoppingItemEntry` にオプショナルフィールド `purchaseDate` を追加した場合、既存テストの名前付きコンストラクタ引数には影響しない（nullable のデフォルトは `null`）

**Rationale**:
- Dart の named parameter はデフォルト値があれば呼び出し側の変更不要
- `purchaseDate` は `this.purchaseDate` で `null` がデフォルトになるため既存テストは無変更
- ただし `ShoppingItemEntry.copyWith` の signature は拡張が必要（`purchaseDate` パラメータ追加）

**Alternatives considered**:
- required にする: 既存テスト・コードの全呼び出し箇所修正が必要となるため却下

---

## 解決済み NEEDS CLARIFICATION

| ID | 問い | 解決内容 |
|----|------|---------|
| — | 日付ピッカー実装 | `showDatePicker`（SDK 標準）|
| — | フォーマット実装 | `'${date.month}月${date.day}日'` |
| — | スキーマ移行 | nullable カラム追加 + schemaVersion 6 |
| — | UI パターン | suffixIcon × ボタン + GestureDetector |
| — | 既存テスト影響 | nullable デフォルト null → 無変更 |
