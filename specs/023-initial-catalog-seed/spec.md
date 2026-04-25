# Feature Specification: 初期カテゴリとひらがな名の投入

**Feature Branch**: `023-initial-catalog-seed`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "初期カテゴリに以下をセットするようにしてください。\nまた、ひらがな名も登録するように追加してください。\n\n```\n{\n  \"野菜\": [\n    \"キャベツ\", \"レタス\", \"トマト\", \"きゅうり\", \"にんじん\", \"玉ねぎ\", \"じゃがいも\", \"ほうれん草\", \"ブロッコリー\", \"ピーマン\", \"なす\", \"大根\", \"白菜\", \"かぼちゃ\", \"アスパラガス\", \"しいたけ\", \"しめじ\", \"えのき\", \"まいたけ\", \"エリンギ\", \"パプリカ\", \"ズッキーニ\", \"豆苗\", \"水菜\", \"プチトマト\"\n  ],\n  \"果物\": [\n    \"りんご\", \"バナナ\", \"みかん\", \"いちご\", \"ぶどう\", \"キウイ\", \"パイナップル\", \"桃\", \"梨\", \"さくらんぼ\"\n  ],\n  \"肉\": [\n    \"牛肉\", \"豚肉\", \"鶏むね肉\", \"鶏もも肉\", \"ひき肉\", \"ベーコン\", \"ハム\", \"ソーセージ\", \"ラム肉\", \"合いびき肉\", \"鶏ひき\"\n  ],\n  \"魚介\": [\n    \"鮭\", \"サバ\", \"マグロ\", \"イワシ\", \"アジ\", \"エビ\", \"カニ\", \"ホタテ\", \"イカ\", \"タコ\"\n  ],\n  \"卵・乳製品\": [\n    \"卵\", \"牛乳\", \"ヨーグルト\", \"チーズ\", \"バター\", \"生クリーム\", \"カッテージチーズ\", \"アイスクリーム\", \"飲むヨーグルト\"\n  ],\n  \"穀類・主食\": [\n    \"白米\", \"玄米\", \"食パン\", \"うどん\", \"そば\", \"パスタ\", \"シリアル\", \"オートミール\"\n  ],\n  \"飲料\": [\n    \"水\", \"緑茶\", \"ウーロン茶\", \"コーヒー\", \"紅茶\", \"オレンジジュース\", \"コーラ\", \"スポーツドリンク\"\n  ],\n  \"お菓子\": [\n    \"ポテトチップス\", \"チョコレート\", \"クッキー\", \"ビスケット\", \"キャンディ\", \"ガム\", \"せんべい\", \"プリン\"\n  ],\n  \"冷凍食品\": [\n    \"冷凍餃子\", \"冷凍チャーハン\", \"冷凍うどん\", \"冷凍ピザ\", \"冷凍コロッケ\", \"冷凍からあげ\", \"冷凍野菜ミックス\"\n  ],\n  \"調味料\": [\n    \"醤油\", \"味噌\", \"砂糖\", \"塩\", \"酢\", \"マヨネーズ\", \"オイスターソース\", \"油\", \"ごま油\"\n  ],\n  \"ベーカリー\": [\n    \"クロワッサン\", \"ロールパン\", \"フランスパン\", \"デニッシュ\", \"あんパン\", \"メロンパン\", \"カレーパン\", \"食パン（全粒粉）\", \"ベーグル\", \"マフィン\"\n  ],\n  \"大豆製品・発酵食品\": [\n    \"豆腐\", \"納豆\", \"キムチ\"\n  ]\n}\n```"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 初期カテゴリを正しい構成で用意する (Priority: P1)

買い物アプリを使う人として、初回起動時に必要なカテゴリと商品候補があらかじめ入っていて、すぐ使い始めたい。

**Why this priority**: 初期カテゴリが不足していると、候補表示やカテゴリ選択の土台が成立しないため。

**Independent Test**: 空のデータ環境でアプリを開き、指定されたカテゴリと各カテゴリ配下の商品が用意されることを確認できる。

**Acceptance Scenarios**:

1. **Given** まだ初期データが入っていない状態, **When** アプリを起動する, **Then** 指定されたカテゴリが用意される
2. **Given** まだ初期データが入っていない状態, **When** アプリを起動する, **Then** 各カテゴリに対応する商品候補が用意される
3. **Given** 既に初期データがある状態, **When** アプリを再起動する, **Then** 既存のカテゴリと商品候補は重複して増えない

---

### User Story 2 - 商品候補にひらがな名を持たせる (Priority: P1)

買い物アプリを使う人として、商品候補にひらがな名も登録されていて、読みから候補を見つけやすくしたい。

**Why this priority**: ひらがな名が入っていないと、読み検索や候補絞り込みの精度が上がらないため。

**Independent Test**: 初期投入された商品候補を確認し、各商品にひらがな名が登録されていることを確認できる。

**Acceptance Scenarios**:

1. **Given** 初期データが投入された状態, **When** ユーザーが商品候補の詳細を見る, **Then** 商品名とひらがな名が登録されている
2. **Given** ひらがな名を使って候補を探す画面を表示している状態, **When** ユーザーが候補の読みを入力する, **Then** 初期商品候補がひらがな名でも見つけられる
3. **Given** 初期商品候補を再投入しようとする状態, **When** 既存データがすでに存在する, **Then** 同じ商品候補にひらがな名が重複して追加されない

### Edge Cases

- 既存データが一部だけ入っている場合は、初期投入が不足分のみを補うかどうかを事前に明確にする。
- カテゴリ名が一覧と異なる既存データがある場合は、重複作成を避ける扱いを明確にする。
- ひらがな名が空の候補は新規初期データには含めない。
- 初期投入後にユーザーが編集した候補は、再起動で上書きしない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST create the specified initial categories when the app starts with an empty catalog.
- **FR-002**: System MUST create the specified item candidates under each initial category when the app starts with an empty catalog.
- **FR-003**: System MUST store a hiragana name for each seeded item candidate.
- **FR-004**: System MUST preserve existing category and item candidate records without duplicating them when initialization runs again.
- **FR-005**: System MUST keep the seeded hiragana names available for item lookup and display.

### Key Entities *(include if feature involves data)*

- **Initial Category**: A top-level grouping such as 野菜 or 果物 that organizes seeded item candidates.
- **Seeded Item Candidate**: A default item stored under an initial category, with a display name and hiragana name.
- **Catalog Initialization**: The startup process that creates the default categories and item candidates when the catalog is empty.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In a clean data environment, 100% of the specified categories are available after the first launch.
- **SC-002**: In a clean data environment, 100% of the specified item candidates are available under the correct categories after the first launch.
- **SC-003**: In verification tests, 100% of seeded item candidates include a hiragana name.
- **SC-004**: In verification tests, restarting the app does not create duplicate seeded categories or item candidates.

## Assumptions

- The feature applies only to the initial seed data created at app startup.
- Existing user-created categories and item candidates are not overwritten by the seed process.
- The seeded item list is intended to support item lookup and candidate suggestions.
- No manual administration screen for the initial seed data is required for this feature.