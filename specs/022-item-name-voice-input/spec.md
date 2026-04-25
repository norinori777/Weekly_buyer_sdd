# Feature Specification: 商品名音声入力

**Feature Branch**: `022-item-name-voice-input`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "商品追加画面の入力フォームの商品名を入力を音声入力可能とする。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 商品名を音声で入力する (Priority: P1)

買い物をする人として、商品追加画面の商品名欄に音声で入力し、手入力より少ない操作で商品名を入れたい。

**Why this priority**: 商品名入力は追加操作の中心であり、ここが音声入力できると入力の手間を最も減らせるため。

**Independent Test**: 商品追加画面で商品名欄から音声入力を開始し、話した内容が商品名欄に反映されることを確認できる。

**Acceptance Scenarios**:

1. **Given** 商品追加画面の商品名欄を表示している状態, **When** ユーザーが音声入力を開始して商品名を話す, **Then** 話した内容が商品名欄に入力される
2. **Given** 音声入力で商品名が入った状態, **When** ユーザーが内容を確認する, **Then** そのまま保存前に手で修正できる
3. **Given** 商品名欄が空の状態, **When** ユーザーが音声入力を中止する, **Then** 商品名欄は空のままか、直前の入力内容が失われない

---

### User Story 2 - 音声入力が使えないときも入力を続ける (Priority: P2)

買い物をする人として、音声入力が使えない状況でも、商品名の入力を止めずに続けたい。

**Why this priority**: 音声入力は便利だが、利用できない環境でも商品追加を完了できることが必要なため。

**Independent Test**: 音声入力を開始できない状態でも、商品名欄に手入力で商品名を入れられることを確認できる。

**Acceptance Scenarios**:

1. **Given** 音声入力が利用できない状態, **When** ユーザーが商品名欄を操作する, **Then** 手入力による商品名入力を続けられる
2. **Given** 音声入力が途中で失敗した状態, **When** ユーザーが入力を続ける, **Then** 既に入っていた商品名は失われない
3. **Given** 音声入力の結果が不明瞭な状態, **When** ユーザーが確認する, **Then** 修正してから登録できる

### Edge Cases

- 音声が認識できない場合は、ユーザーが再試行するか手入力に切り替えられる。
- 音声入力の結果が意図した商品名と異なる場合は、登録前に修正できる。
- 音声入力を途中でキャンセルしても、すでに入力済みの商品名は不用意に消えない。
- 商品名欄が空のままでは、音声入力後でも未入力状態として扱われる。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to start product-name input by voice from the item add screen.
- **FR-002**: System MUST place the spoken product name into the product name field as editable text.
- **FR-003**: System MUST allow users to review and edit the recognized product name before saving.
- **FR-004**: System MUST keep any existing product name text unchanged when voice input is canceled or fails.
- **FR-005**: System MUST allow users to continue entering the product name manually if voice input is unavailable.

### Key Entities *(include if feature involves data)*

- **Product Name Field**: The text entry used for the item being added.
- **Voice Input Session**: One attempt by the user to speak a product name into the field.
- **Recognized Text**: The transcribed product name shown to the user after voice input.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: At least 90% of test users can enter a product name by voice without assistance.
- **SC-002**: At least 90% of test users can confirm and correct the recognized product name before saving.
- **SC-003**: At least 95% of test users can continue product-name entry when voice input is unavailable.
- **SC-004**: In usability testing, the average time to complete product-name entry with voice is shorter than manual entry for the same task.

## Assumptions

- The feature applies only to the product name field in the item add form.
- Manual keyboard entry remains available at all times.
- Users can review and correct recognized text before saving the item.
- Voice input is used to transcribe the product name only and does not affect other fields.
