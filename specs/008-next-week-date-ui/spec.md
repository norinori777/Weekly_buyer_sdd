# Feature Specification: 翌週日付表示と曜日ボタン簡略化

**Feature Branch**: `008-next-week-date-ui`  
**Created**: 2026-04-20  
**Status**: Draft  
**Input**: User description: "- 商品登録画面の画面上部の曜日の箇所ですが、各曜日に日付を含むボタンになっているが、曜日のみで良いです。\n- 商品登録画面に表示されている日付は、翌週の日付としてください。翌週の1週間分の買い物をするためのアプリのため。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Plan next week’s shopping by weekday (Priority: P1)

買い物をする人として、商品登録画面を開いたときに「翌週1週間」を前提に曜日ごとの登録内容を確認・登録したい。翌週分の買い物準備を迷わず進めたい。

**Why this priority**: このアプリの目的が「翌週の1週間分の買い物準備」であり、日付の週がズレると登録内容が意図と一致しなくなるため。

**Independent Test**: 商品登録画面を開き、画面に表示される日付（週の範囲や選択中の日付）が翌週のものになっていること、曜日切替で対応する翌週の日付に紐づく内容が表示されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 端末の日付が任意の日に設定されている状態, **When** ユーザーが商品登録画面を開く, **Then** 画面に表示される週の文脈は「翌週（月曜始まり〜日曜終わり）」として扱われる
2. **Given** 商品登録画面を表示している状態, **When** ユーザーが曜日ボタンで「水」を選択する, **Then** 表示中の登録内容は翌週の水曜日に紐づく内容へ切り替わる

---

### User Story 2 - Reduce clutter in weekday selector (Priority: P2)

買い物をする人として、画面上部の曜日切替は曜日だけが見えれば十分なので、日付が混ざって見づらくならないようにしたい。

**Why this priority**: ボタン内の情報量が多いと曜日切替が視認しづらく、誤タップや認知負荷につながるため。

**Independent Test**: 商品登録画面の上部を確認し、月〜日の各ボタン表示が曜日のみであること、選択操作が従来どおり行えることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品登録画面を表示している状態, **When** ユーザーが上部の曜日切替を確認する, **Then** 月〜日それぞれのボタン表示は曜日のみ（例: 「月」「火」…）で日付（数値）が表示されない
2. **Given** 曜日切替のボタンが表示されている状態, **When** ユーザーが任意の曜日を選択する, **Then** 選択状態の表示と内容の切替は従来どおり行われる

---

### Edge Cases

- 月末・年末をまたぐ週（例: 翌週が別月/別年に跨る）でも、翌週の月〜日の対応付けが崩れない。
- 端末のタイムゾーン/日付設定が変わった場合でも、翌週判定が端末の日付に追従して一貫する。
- 「その他」など曜日に紐づかない区分が存在する場合でも、月〜日ボタンの表示仕様（曜日のみ）に影響しない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST treat the "active week" on the product registration screen as the next calendar week (Monday start, Sunday end).
- **FR-002**: System MUST display dates on the product registration screen that correspond to the next calendar week context (not the current week).
- **FR-003**: System MUST render the weekday selector buttons for Monday–Sunday using weekday-only labels (no numeric date in the button label).
- **FR-004**: System MUST keep weekday switching behavior consistent: selecting a weekday shows the registrations for the corresponding day within the active week.
- **FR-005**: System MUST keep the mapping between weekday selection and the displayed date consistent within the next-week context.

### Key Entities *(include if feature involves data)*

- **Active Week**: The week context used by the product registration screen; for this feature it is the next calendar week (Monday–Sunday).
- **Weekday Selection**: The currently selected weekday (Mon–Sun, and optionally an "Other" bucket) used to scope displayed registrations.
- **Displayed Date**: Any date shown on the screen to communicate the selected day or week range to the user.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In acceptance testing, 100% of the displayed week contexts on the product registration screen correspond to the next calendar week (Monday–Sunday).
- **SC-002**: In acceptance testing, 100% of weekday buttons for Monday–Sunday display weekday-only labels with no numeric date characters.
- **SC-003**: At least 90% of test users can switch weekdays and correctly identify they are editing next week’s plan without confusion.

## Assumptions

- The app uses a fixed week definition: Monday as week start and Sunday as week end.
- The product registration screen already has a concept of an "active week" and weekday switching; this change only adjusts which week is active by default and what text appears in the weekday buttons.
- If the initial selected weekday is derived from "today", it continues to use the same weekday index but applied to the next-week context.
- Changing the week context does not introduce new navigation or week-picking UI in this iteration.
