# Implementation Plan: Main Shell

**Branch**: `002-main-shell-specify` | **Date**: 2026-04-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-main-shell/spec.md`

## Summary

The feature extends the current weekly shopping screen into a shared MainShell with three stable top-level destinations: purchase list, item add, and settings. The implementation should keep the currently selected week stable across destinations, preserve in-progress add state during a session, and keep purchase-list actions fast by exposing a direct add path from the list view.

The current app already boots through `ProviderScope` and shows a single weekly shopping page. This plan keeps that foundation, refactors the page into a shell with destination switching, and preserves the existing weekly list data flow while introducing persistent navigation state.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner
**Storage**: Local SQLite via Drift
**Testing**: flutter test, flutter analyze, widget tests, repository tests
**Target Platform**: Android and other Flutter-supported mobile/desktop targets in the existing app workspace
**Project Type**: Mobile app
**Performance Goals**: Destination switching should feel immediate and preserve the selected week without visible reloads; main shopping interactions should remain one or two taps away
**Constraints**: Offline-capable, local-first data flow, no cloud sync for the first version, preserve existing weekly shopping data behavior
**Scale/Scope**: Single mobile app with a small set of top-level destinations and one shared weekly context

## Constitution Check

No constitution file was present in `.specify/`, so there are no additional project-constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/002-main-shell/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── tasks.md
```

### Source Code (repository root)

```text
weekly_buyer/
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── providers.dart
│   │   └── weekly_buyer_app.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── data/
│           ├── domain/
│           └── presentation/
│               └── weekly_shopping_page.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: Keep the current feature-first Flutter layout and evolve `weekly_shopping_page.dart` into a MainShell-backed presentation layer while leaving the app bootstrap in `lib/app/` intact. The first implementation should add a shared destination shell and navigation state before splitting the screen into smaller destination-specific widgets.

## Phase 0: Research

### Decisions to Confirm

- Keep the purchase list as the default destination on launch.
- Use a shared week context that survives destination switching inside the session.
- Keep the existing add-sheet entry point as a fast path from the purchase list while also exposing the dedicated item-add destination.
- Treat settings as a first-class destination in the same shell rather than a separate flow.

### Research Outcomes

- Current bootstrap already uses `ProviderScope`, so navigation state can be introduced at the feature/provider layer without changing the entry point.
- Current UI already loads a selected week and opens an add sheet from the weekly page, so the new shell should reuse that data flow rather than replace it.
- The safest migration path is to preserve the existing weekly list repository and move only presentation and navigation state first.

## Phase 1: Design and Data Shape

### UI Design

- Introduce a `MainShell` widget that owns the top-level destination index.
- Keep purchase list, item add, and settings as persistent destinations in the same app frame.
- Preserve the week header and add-sheet behavior, but move destination-specific actions into smaller widgets.
- Keep purchase list interactions one tap away from add and undo behavior.

### State Design

- Store the selected destination in a provider so it survives rebuilds during the session.
- Store the selected week in shared state so destination switches do not reset the current week.
- Store in-progress add state separately from persisted shopping data so the add form can survive brief navigation away and back.

### Data Design

- Reuse the current weekly shopping snapshot and repository model for list content.
- Keep destination state out of the database; it is view state, not shopping data.
- Keep undo behavior tied to the most recent purchase action and surface it from the purchase-list destination.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget test coverage for destination switching, default destination, and week retention
- Repository tests remain focused on weekly list behavior, not navigation state

## Risks and Mitigations

- Risk: Splitting the current page too early could duplicate week-loading logic. Mitigation: keep the repository/snapshot source shared and move only the shell around it.
- Risk: Settings may become a separate navigation concept and break the shared week context. Mitigation: model settings as a top-level destination in the same shell from the start.
- Risk: Add-sheet behavior could drift from the new dedicated item-add destination. Mitigation: define the dedicated destination as a fuller add workspace and preserve the sheet as a quick action from purchase list.
