# Research: 購入リスト画面カテゴリ内商品のひらがな順ソート

**Date**: 2026-05-24  
**Feature**: [spec.md](spec.md)

## 調査結果

### 1. 既存ソート実装の確認

**Decision**: `_groupEntriesByCategory` でソートを追加する方式を採用  
**Rationale**: アイテムのグルーピングはすでにこのメソッドで行われており、ソートを同じ場所で実施するのが最小変更かつ責務が明確  
**Alternatives considered**:
- DB クエリに `ORDER BY` を追加する案 → `item_masters.hiragana` は別テーブルにあるため JOIN が必要になり、変更範囲が広がる。却下
- `ShoppingCategoryGroup` の `items` を immutable なまま Presentation 層でソートする案 → UI 層がドメインロジックを持つことになりコンスティテューション違反。却下

現在の DB クエリ（`loadWeek`）:
```dart
..orderBy([
  (table) => OrderingTerm(expression: table.sortOrder),
  (table) => OrderingTerm(expression: table.createdAt),
])
```
このクエリは `WeeklyListItems` の `sort_order` と `createdAt` で並べており、`item_masters.hiragana` による並べ替えには対応していない。

---

### 2. `hiragana` フィールドのデータ流通経路

**Decision**: `ShoppingItemEntry` に `hiragana` フィールドを追加し、`loadWeek` で `ItemCandidate` マップから設定する  
**Rationale**: `loadWeek` はすでに `_loadItemMasters()` で `List<ItemCandidate>` を取得しており（各 `ItemCandidate` が `hiragana` を持つ）、追加の DB クエリなしで情報を受け渡せる  
**Alternatives considered**:
- `Map<int, String?>` を `_groupEntriesByCategory` の引数で渡す案 → `ShoppingItemEntry` を変えなくて済む利点があるが、ドメインモデルが商品の属性を欠いた不完全な状態になる。却下

既存の `ShoppingItemEntry` に存在する `itemMasterId` フィールドを利用し、`hiraganaByMasterId[item.itemMasterId]` でひらがなを設定する。未分類商品（`itemMasterId == null`）は `hiragana: null` になり、末尾に配置する FR-003 の要件を満たす。

---

### 3. カタカナ → ひらがな正規化

**Decision**: Unicode コードポイントのシフトで変換する  
**Rationale**: Dart には標準の `Locale` ベースのかな正規化 API がないが、カタカナ（U+30A1–U+30F6）はひらがな（U+3041–U+3096）と 0x60 差のコードポイント対応があり、`String.replaceAllMapped` で実現できる  
**Alternatives considered**:
- `characters` パッケージや ICU を使う案 → 外部依存追加が必要で憲法 III（技術スタック固定）に反する。却下

```dart
String _normalizeToHiragana(String s) =>
    s.replaceAllMapped(RegExp(r'[\u30a1-\u30f6]'),
      (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60));
```

---

### 4. ソートアルゴリズムの安定性

**Decision**: Dart の `List.sort` は安定ソート（Dart SDK 2.0 以降）のため追加施策は不要  
**Rationale**: ひらがな読みが同一の商品が複数ある場合、`sort` の安定性により挿入順が保たれる。ただし FR-002 では商品名（表示名）をタイブレーカーとして要求しているため、`compareToHiragana` 関数で明示的に 2 段階比較を行う  
**Alternatives considered**:
- 1段階比較だけにする案 → FR-002 の要件「同音商品は一定の安定した順序」に形式上のみ対応。却下

---

### 5. ひらがな未設定商品の扱い

**Decision**: ソートキーが空（`null` または空文字）の商品は末尾に配置  
**Rationale**: FR-003 の要件に直接対応。空キーを `\uFFFF`（Unicode 最大値付近の文字）に置換してソートキーとする方式が実装シンプル  
**Alternatives considered**:
- 別途フィルタリングして末尾に追加する案 → コードが複雑になり保守性が下がる。却下

---

### 6. スコープ外の確認

- **漢字読み推定**: 商品名が漢字のみでひらがな未設定の場合、漢字読みの自動推定は **本機能のスコープ外**。spec の「Assumptions」に明記済み。
- **カテゴリ間の順序**: `_groupEntriesByCategory` は `categoryNames.entries` の順序（既存の `sort_order` 順）でカテゴリを並べており、本機能はこれを変更しない（FR-005）。
- **週間リスト項目追加画面**: 購入リスト画面のみが対象（spec FR-001）。
