# Feature Specification: Main Shell

**Feature Branch**: `002-main-shell-specify`  
**Created**: 2026-04-19  
**Status**: Draft  
**Input**: User description: "MainShell - BottomNavigationBar で 購入リスト / 商品追加 / 設定 を切り替える"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Switch Between Core Destinations (Priority: P1)

買い物をする人として、購入リスト、商品追加、設定をすばやく切り替えたい。画面を行き来しても、今見ている週の文脈を保ったまま操作を続けたい。

**Why this priority**: 主要な3画面を迷わず切り替えられないと、追加と確認の往復が増えて使いにくくなるため。

**Independent Test**: 購入リスト、商品追加、設定の3画面をそれぞれ1回の操作で開けることと、切り替え後も同じ週の表示が保たれることを確認できる。

**Acceptance Scenarios**:

1. **Given** アプリを起動した状態, **When** ユーザーが購入リスト・商品追加・設定のいずれかを選ぶ, **Then** 選んだ画面が表示される
2. **Given** 購入リスト画面を表示している状態, **When** ユーザーが商品追加画面へ切り替える, **Then** 直前に見ていた週の文脈が維持されたまま商品追加画面が表示される
3. **Given** 商品追加画面を表示している状態, **When** ユーザーが設定画面へ切り替える, **Then** 設定画面が表示され、再び戻ったときに同じ週の文脈が保たれる

---

### User Story 2 - Add Items Without Losing Context (Priority: P1)

買い物をする人として、購入リストを見ながらすぐに商品追加へ移動したい。入力の途中で画面を移動しても、戻ったときに迷わず続きから操作したい。

**Why this priority**: 追加と確認を繰り返す流れが自然だと、入力の手間が減って使用頻度が上がるため。

**Independent Test**: 購入リストから商品追加を開き、商品を入力してから購入リストへ戻るまでの流れを確認できる。

**Acceptance Scenarios**:

1. **Given** 購入リスト画面を表示している状態, **When** ユーザーが追加操作を選ぶ, **Then** 商品追加画面または追加用の入力導線がすぐ開く
2. **Given** 商品追加画面で入力途中の状態, **When** ユーザーが購入リストへ切り替える, **Then** 画面を戻したときに入力の続きが確認できる
3. **Given** 商品追加を完了した状態, **When** ユーザーが続けて追加するか購入リストへ戻るかを選ぶ, **Then** 選んだ次の操作に自然に進める

**Default Return Rule**: 商品追加を完了したあと、既定では購入リスト画面へ戻る。

---

### User Story 3 - Reach Settings Without Disrupting Shopping Flow (Priority: P2)

買い物をする人として、設定画面を必要なときだけ開きたい。普段の買い物操作を邪魔せずに、カテゴリや並び順の調整に移りたい。

**Why this priority**: 設定は主要操作ではないが、買い物の見やすさを支えるために迷わず開ける必要があるため。

**Independent Test**: 購入リストまたは商品追加から設定へ移動し、戻ったときに直前の画面に近い状態へ戻れることを確認できる。

**Acceptance Scenarios**:

1. **Given** 購入リスト画面を表示している状態, **When** ユーザーが設定を開く, **Then** 設定画面が表示される
2. **Given** 設定画面を表示している状態, **When** ユーザーが元の画面へ戻る, **Then** 直前に見ていた購入リストまたは商品追加の状態へ戻れる

**Shell Rule**: 設定画面は MainShell の一部として扱い、購入リスト・商品追加と同じトップレベルの切り替え先に含める。

---

### Edge Cases

- 画面切り替えの最中に入力途中の内容が消えないようにする。
- アプリを開いた直後は、ユーザーが迷いにくい既定の画面を表示する。
- 週の選択が変わっていないのに、画面切り替えのたびに別の週へ飛ばないようにする。
- 設定を開いたり閉じたりしても、購入リストや商品追加の表示状態が不自然に初期化されないようにする。
- 通信がなくても、画面切り替えは通常どおりできるようにする。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST present purchase list, item add, and settings as top-level destinations in a single main shell.
- **FR-002**: System MUST allow users to switch between the three destinations from a persistent navigation control.
- **FR-003**: System MUST keep the selected week context consistent when users move between purchase list, item add, and settings destinations.
- **FR-004**: System MUST provide a direct add action from the purchase list destination so users can start item entry without detouring through settings.
- **FR-005**: System MUST preserve in-progress item add state within the current session when users briefly leave the item add destination and return.
- **FR-006**: System MUST return users to the previously active shopping destination after they leave settings, unless they choose a different destination.
- **FR-007**: System MUST open the app to a predictable default destination so users can begin shopping without extra navigation.

### Key Entities *(include if feature involves data)*

- **Main Shell**: The shared app container that holds the core destinations and keeps navigation consistent.
- **Destination**: One of the top-level areas the user can open, including purchase list, item add, and settings.
- **Week Context**: The currently selected week that should remain stable while users move between shopping destinations.
- **Draft Add State**: The in-progress item entry state that may need to remain available when the user switches away and returns.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can open purchase list, item add, and settings from the main shell in one navigation action per destination.
- **SC-002**: At least 90% of test users can move from purchase list to item add and back without losing the selected week.
- **SC-003**: At least 90% of test users can reach settings from the main shell without asking for help.
- **SC-004**: In usability testing, at least 8 out of 10 users can start adding an item from the purchase list in two actions or fewer.
- **SC-005**: Users can return to the previous shopping destination from settings with no more than one additional action.

## Assumptions

- The app starts on the purchase list destination by default.
- Purchase list and item add share the same active week context.
- Settings are part of the same top-level shell, not a separate app flow.
- In-progress add input is preserved for the current session, but not required to survive an app restart.
- The first version prioritizes simple and predictable switching over advanced navigation behaviors.
