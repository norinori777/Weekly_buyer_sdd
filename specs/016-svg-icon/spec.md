# Feature Specification: SVG アイコン統一

**Feature Branch**: `016-svg-icon`  
**Created**: 2026-04-25  
**Status**: Draft  
**Input**: User description: "assetsに置いたweekly_buyer.svgのアイコンにしてください。"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - SVG ブランドアイコンを表示する (Priority: P1)

利用者として、アプリのブランドアイコンが SVG の見た目で表示され、画面サイズに関わらずきれいに見えるようにしたい。

**Why this priority**: アイコンはアプリの印象を最初に伝える要素であり、意図した SVG の見た目が反映されないとブランド体験が崩れるためです。

**Independent Test**: アプリを起動し、ブランドアイコンが SVG デザインで表示されることを確認できる。異なる画面サイズでも見た目が崩れないことを確認できる。

**Acceptance Scenarios**:

1. **Given** アプリを起動した状態, **When** ブランドアイコンが表示される, **Then** SVG デザインのアイコンが表示される
2. **Given** 画面サイズが異なる端末でアプリを表示している状態, **When** ブランドアイコンを見る, **Then** アイコンの見た目が保たれる

---

### User Story 2 - 既存の見た目を壊さずに置き換える (Priority: P2)

利用者として、アイコンの差し替え後もアプリの他の表示や操作が変わらず、安心して使い続けたい。

**Why this priority**: アイコン変更は見た目の改善であり、他の機能に影響すると本来の価値を損なうためです。

**Independent Test**: アプリを起動し、アイコン以外の画面表示や操作が従来どおりであることを確認できる。

**Acceptance Scenarios**:

1. **Given** アイコンが SVG に変わった状態, **When** ユーザーが各主要画面を開く, **Then** アイコン以外の操作は従来どおり行える
2. **Given** アイコンが SVG に変わった状態, **When** ユーザーがアプリを再起動する, **Then** アイコンの表示が維持される

---

### Edge Cases

- アイコン表示サイズが小さくても、図形が判別できる。
- 画面サイズや解像度が変わっても、アイコンの比率が崩れない。
- アイコン差し替え後も、アプリの他の表示と操作に影響しない。

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display the application brand icon using the SVG asset designated for the app.
- **FR-002**: System MUST keep the brand icon visually consistent across supported screen sizes.
- **FR-003**: System MUST preserve the existing app behavior and navigation while changing the brand icon.
- **FR-004**: System MUST ensure the icon remains legible at the sizes where the app brand is shown.

### Key Entities *(include if feature involves data)*

- **Brand Icon**: The visual icon used to represent the app in its UI.
- **SVG Asset**: The vector artwork used as the brand icon source.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of acceptance test runs show the SVG brand icon in the app's designated icon location.
- **SC-002**: In manual verification, the icon remains recognizable at standard mobile screen sizes and orientations.
- **SC-003**: At least 90% of reviewers confirm that the icon change does not alter other app behavior or navigation.

## Assumptions

- The SVG artwork in assets is the intended replacement for the current app brand icon.
- The app keeps its existing screens and flows unchanged aside from the icon presentation.
- No new branding assets are introduced in this iteration.
