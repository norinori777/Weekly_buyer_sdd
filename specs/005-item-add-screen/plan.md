# Implementation Plan: 商品登録画面

**Branch**: `005-item-add-screen`  | **Date**: 2026-04-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/005-item-add-screen/spec.md`

## Summary

The feature corrects the dedicated item registration screen so it behaves like a week-based entry workspace: a weekday selector at the top, morning/afternoon/evening sections in the body, and a bottom add action that opens a slide-up input form. The weekday selector must support both tab selection and left/right swipe navigation, while the add flow must preserve the selected weekday and section context during the session.

The current app already has a shared shell, a dedicated item-add destination, a reusable weekday header, and a reusable item entry form. This plan keeps that presentation structure and refines the item-add flow rather than introducing a new architecture.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Weekday switching should feel immediate, the add sheet should open without noticeable delay, and registration should update the selected section promptly  
**Constraints**: Offline-capable, local-first data flow, no cloud sync for the first version, shared week context across destinations, weekday selector must support swipe gestures, item creation must occur through the bottom-sheet add flow  
**Scale/Scope**: Single mobile app with one shared weekly shopping domain and a small set of destination-level screens

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/005-item-add-screen/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
└── spec.md
```

### Source Code (repository root)

```text
weekly_buyer/
├── lib/
│   ├── app/
│   │   ├── app.dart
│   │   ├── app_database.dart
│   │   ├── providers.dart
│   │   └── weekly_buyer_app.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── data/
│           │   └── weekly_shopping_repository.dart
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── main_shell.dart
│               ├── purchase_list_destination.dart
│               ├── item_add_destination.dart
│               ├── item_entry_form.dart
│               ├── week_header.dart
│               └── settings_destination.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: Keep the current feature-first Flutter layout and refine the existing item-add presentation layer. The implementation work should keep the shared shell and repository boundaries intact while moving the item-add screen to a bottom-sheet driven workflow with swipeable weekday selection.

## Phase 0: Research

### Decisions to Confirm

- Keep `MainShell` as the outer frame so the item-add destination continues to share the active week with the purchase list.
- Treat the current `WeekHeader` as the reusable weekday selector, then add left/right swipe navigation on the selector area.
- Move item entry from the inline card into a bottom-sheet form opened from the bottom add action.
- Keep `ItemEntryForm` as the reusable field set for name, quantity, and section selection inside the bottom sheet.
- Keep the selected weekday and selected section in session state so the add flow stays stable while the user registers multiple items.

### Research Outcomes

- The current app already has the dedicated item-add destination and shared week provider, so the safest change is to extend that screen rather than create a new route.
- `weeklyShoppingSnapshotProvider` already provides the current week, section data, and candidates required for the add flow.
- The reusable form component can stay intact if it is moved into a modal bottom sheet and fed by session draft state.
- Swipe-based weekday switching should live in the header/selector layer so it does not leak into the repository or item entry logic.

## Phase 1: Design and Data Shape

### UI Design

- Keep the item-add screen as a single destination with three visible areas: weekday selector, morning/afternoon/evening sections, and a bottom add action.
- Add swipe left/right support to the weekday selector so the active day can be changed without tapping.
- Render morning, afternoon, and evening as separate sections that reflect the items stored for the selected weekday.
- Open the existing item entry form in a bottom sheet when the add action is tapped.
- After save, keep the user on the same item-add screen and update the relevant section immediately.

### State Design

- Keep the selected week in a provider shared with the purchase list screen.
- Keep the active weekday tab as session state so tap and swipe gestures stay in sync.
- Keep the current draft item entry state separate from persisted data so the form can survive brief navigation and sheet reopen behavior.
- Keep the selected section in the draft state so the form can restore the last active section between opens.

### Data Design

- Reuse the existing weekly shopping repository and database schema for persisted shopping data.
- Keep item creation, candidate reuse, and section placement in the repository layer.
- Do not add a new persisted entity for weekday tabs or form draft state; those are presentation/session concerns.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests for weekday selection, swipe-based navigation, bottom-sheet add flow, and section refresh after save
- Repository tests for item creation and reloading the selected week

## Risks and Mitigations

- Risk: Horizontal swipe handling could conflict with horizontal scrolling inside the selector. Mitigation: keep the gesture surface narrow and make tap selection still available.
- Risk: Moving the form into a bottom sheet could drop draft state on close. Mitigation: keep the draft in a provider and hydrate the form from it when reopened.
- Risk: The selected weekday and selected section could diverge if they are stored in different places. Mitigation: keep both in shared session state and update them together when appropriate.
- Risk: The add flow could duplicate repository logic if save and refresh are split across the sheet and screen. Mitigation: keep repository writes in the destination layer and use a single snapshot refresh path.

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- New external API contracts
- Reworking the persisted weekly shopping schema beyond what is needed for the corrected add flow
