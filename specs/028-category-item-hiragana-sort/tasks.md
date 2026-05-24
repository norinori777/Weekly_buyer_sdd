# Tasks: 購入リスト画面カテゴリ内商品のひらがな順ソート

**Input**: Design documents from `/specs/028-category-item-hiragana-sort/`  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Data Model**: [data-model.md](data-model.md) | **Research**: [research.md](research.md) | **Quickstart**: [quickstart.md](quickstart.md)

## Format: `[ID] [P?] [Story?] Description`

- **[P]**: 並列実行可能（別ファイル、未完了タスクへの依存なし）
- **[Story]**: 対応するユーザーストーリー（US1/US2）
- ファイルパスは各タスクに明記

---

## Phase 1: Setup（共通インフラ確認）

**Purpose**: 実装開始前のベースライン確認。既存プロジェクトのため新規セットアップは不要

- [X] T001 既存テストが PASS することをベースラインとして確認する（`cd weekly_buyer; flutter test`）

---

## Phase 2: Foundational（US1/US2 両方をブロックする前提条件）

**Purpose**: ドメインモデルへの `hiragana` フィールド追加。リポジトリ変更の前提となるため完了まで US1/US2 の実装を開始できない

**⚠️ CRITICAL**: Phase 2 が完了するまで US1/US2 の実装は開始できない

- [X] T002 `ShoppingItemEntry` に `final String? hiragana` フィールドを追加し（オプション引数・デフォルト null）、`copyWith` にも `hiragana` パラメータを追加して `hiragana: hiragana ?? this.hiragana` で返すよう更新する（`weekly_buyer/lib/features/weekly_shopping_list/domain/weekly_shopping_models.dart`）

**Checkpoint**: Phase 2 完了 — `ShoppingItemEntry` が `hiragana` フィールドを持つ。US1/US2 の実装を開始可能

---

## Phase 3: User Story 1 — カテゴリ内の商品がひらがな昇順で並ぶ（Priority: P1）🎯 MVP

**Goal**: 各カテゴリ内の商品を `hiragana` 昇順で表示する。カタカナ読みは正規化、未設定は末尾

**Independent Test**: DB に複数の商品（ひらがな読みがバラバラ）をカテゴリ付きで登録し `loadWeek` を呼び出して、`categoryGroups[0].items` がひらがな昇順であることを確認する

### Implementation for User Story 1

- [X] T003 [US1] `loadWeek` メソッド内の `_loadItemMasters()` 呼び出し直後に `final hiraganaByMasterId = <int, String?>{for (final m in itemMasters) m.id: m.hiragana};` を追加し、`ShoppingItemEntry` の生成箇所に `hiragana: item.itemMasterId == null ? null : hiraganaByMasterId[item.itemMasterId],` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T004 [P] [US1] クラス末尾にプライベートメソッド `String _normalizeToHiragana(String s) => s.replaceAllMapped(RegExp(r'[\u30a1-\u30f6]'), (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x60));` を追加する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T005 [US1] T004 完了後、クラス末尾にプライベートメソッド `_sortKeyFor(ShoppingItemEntry entry)` を追加する。`entry.hiragana?.trim()` が null または空の場合は `'\uFFFF${entry.name}'` を返し、そうでない場合は `'${_normalizeToHiragana(hiragana)}\t${entry.name}'` を返す（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T006 [US1] T005 完了後、`_groupEntriesByCategory` メソッド内のカテゴリグループを生成する `orderedGroups.add(...)` 箇所を更新し、`items: List.unmodifiable(items)` を `items: List.unmodifiable([...items]..sort((a, b) => _sortKeyFor(a).compareTo(_sortKeyFor(b))))` に変更する。未分類グループの `orderedGroups.add(...)` 箇所も同様に更新する（`weekly_buyer/lib/features/weekly_shopping_list/data/weekly_shopping_repository.dart`）
- [X] T007 [US1] `repository_test.dart` にテストを追加する。カテゴリを1つ作成し、ひらがな読みが `ぶろっこりー`・`あいうえお`・`きゃべつ` の3商品を順不同で登録し `loadWeek` を呼び出した後、`categoryGroups.single.items` の `name` 順が `['あいうえお商品', 'キャベツ', 'ブロッコリー']`（ひらがな読み昇順）になっていることを確認する。また、ひらがな未設定の商品が末尾に配置されることも確認する（`weekly_buyer/test/repository_test.dart`）

**Checkpoint**: Phase 3 完了 — 購入リスト画面のカテゴリ内商品がひらがな昇順で表示される（US1 独立テスト可能）

---

## Phase 4: User Story 2 — 同じひらがな読みを持つ商品のタイブレーカー（Priority: P2）

**Goal**: ひらがな読みが同一の商品が複数ある場合に、商品名（表示名）の文字列昇順という安定した順序で表示する

**Independent Test**: 同じひらがな読みを持つ複数の商品を登録し、`loadWeek` を複数回呼び出して常に同じ商品名昇順になることを確認する

### Implementation for User Story 2

- [X] T008 [P] [US2] `repository_test.dart` にテストを追加する。同一カテゴリに `hiragana = 'あいうえお'` を持つ `name` が異なる2商品（例: `'商品Z'`・`'商品A'`）を登録し `loadWeek` を呼び出した後、`categoryGroups.single.items` の `name` 順が `['商品A', '商品Z']`（名前昇順）になっていることを確認する（`weekly_buyer/test/repository_test.dart`）

**Checkpoint**: Phase 4 完了 — 同音商品が商品名昇順で安定して並ぶ（US2 独立テスト可能）

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: 静的解析・テスト実行による品質確認

- [X] T009 [P] `flutter analyze` を実行してエラー・警告がゼロであることを確認する（`cd weekly_buyer; flutter analyze`）
- [X] T010 `flutter test` を実行してすべてのテストが PASS することを確認する（`cd weekly_buyer; flutter test`）
- [X] T011 [P] quickstart.md の手動動作確認手順に従い、購入リスト画面でひらがな昇順ソートが正しく動作することを確認する（`specs/028-category-item-hiragana-sort/quickstart.md`）

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: 依存なし — 即時開始可能
- **Foundational (Phase 2)**: Phase 1 完了後 — **US1/US2 すべてをブロック**
- **User Story 1 (Phase 3)**: Phase 2 完了後 — US2 と独立
- **User Story 2 (Phase 4)**: Phase 2 完了後 — US1 と独立（T006 と同ファイルだが異なる箇所）
- **Polish (Phase 5)**: Phase 3/4 すべて完了後

### User Story Dependencies

- **US1 (P1)**: Phase 2 完了後に開始可能 — US2 に依存しない（独立してテスト可能）
- **US2 (P2)**: Phase 2 完了後に開始可能 — US1 実装（T006）に論理的に依存するが、テストは US1 完了後に追加可能

### Within Phase 3 (User Story 1)

```text
T002 (domain model hiragana field)
  ├── T003 (loadWeek hiragana lookup)    # T002 後
  └── T004 (P) (_normalizeToHiragana)   # T002 と並列可能
        └── T005 (_sortKeyFor)          # T004 後
              └── T006 (_groupEntries sort) # T005 後
                    └── T007 (US1 test)     # T006 後
```

### Parallel Execution Opportunities

- **T004 と T002 は並列可能**: T004 は既存の `ShoppingItemEntry` に依存しない独立したヘルパーメソッド
- **T008 と T007 は並列可能**: 同じファイルだが異なるテストケース、T006 完了後であれば同時に記述可能
- **T009・T011 と T010 は並列可能**: T010 の実行結果を待つ間に T009/T011 を実施

---

## Implementation Strategy

### MVP Scope (US1 のみ)

US1（Phase 2 + Phase 3）が最小動作単位。T001 → T002 → T003+T004 → T005 → T006 → T010 を順に完了すると購入リスト画面でひらがな昇順ソートが動作する。US2（Phase 4）は任意の追加確認。

### 実装の注意点

- `ShoppingItemEntry` の `hiragana` はオプション引数（`this.hiragana`）とするため、`undoLatestPurchase` など他の `ShoppingItemEntry` 生成箇所は変更不要
- `_sortKeyFor` のタブ区切り（`\t`）はひらがな文字（U+3040–U+309F）の範囲外の制御文字（U+0009）であり、名前タイブレーカーとして安全に機能する
- `\uFFFF` は Unicode の最後近くの文字であり、すべてのひらがな・カタカナより後ろにソートされることが保証される

---

## Format Validation

- ✅ 全タスクに `- [ ]` チェックボックス
- ✅ 全タスクに `T###` 形式の ID（T001–T011）
- ✅ User Story フェーズのタスクに `[US1]` / `[US2]` ラベル
- ✅ 並列実行可能タスクに `[P]` ラベル（T004, T008, T009, T011）
- ✅ 全タスクに具体的なファイルパスを明記
