# Implementation Plan: 購入・登録フロー

**Branch**: `004-purchase-add-flow`  | **Date**: 2026-04-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-purchase-add-flow/spec.md`

## Summary

The feature corrects the navigation and screen responsibilities for the weekly shopping workspace. The purchase list screen becomes a read-only, category-grouped shopping view with left-swipe purchase completion and undo, while the item registration screen becomes the dedicated entry point for adding items through the bottom add action. The implementation must keep the shared week context stable across destinations and preserve the existing local-first shopping data flow.

The current app already has a `MainShell`, a purchase list destination, an item add destination, and shared Riverpod providers. This plan keeps that shell and refines the destination responsibilities rather than introducing a new app architecture.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Screen switching should feel immediate, and the shopping list should remain responsive while loading and filtering weekly data  
**Constraints**: Offline-capable, local-first data flow, no cloud sync for the first version, shared week context across destinations, purchase list must not expose item creation  
**Scale/Scope**: Single mobile app with one shared weekly shopping domain and a small set of top-level destinations

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/004-purchase-add-flow/
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
│               ├── settings_destination.dart
│               ├── item_entry_form.dart
│               └── weekly_shopping_page.dart
└── test/
    ├── repository_test.dart
    └── widget_test.dart
```

**Structure Decision**: Keep the current feature-first Flutter layout and refine the existing shell/destination split. The implementation work should correct screen responsibilities inside `weekly_shopping_list/presentation` and preserve the repository/provider boundaries already present in `lib/app` and `lib/features/weekly_shopping_list`.

## Phase 0: Research

### Decisions to Confirm

- Keep `MainShell` as the top-level frame and preserve purchase list as the default destination.
- Remove item creation from the purchase list screen so it becomes a read-only shopping view.
- Make the item registration screen the only primary path for adding items from the bottom add action.
- Keep the shared week context in session state so switching between purchase list and item registration does not reset the active week.
- Preserve the existing section-based item entry form, but place it under the corrected item-registration flow so day/week context and item input are not conflated.

### Research Outcomes

- The current app already has the right shell and provider scaffolding, so the safest change is to reassign responsibilities in the existing presentation layer.
- `loadWeek()` already returns the categories, weekly items, candidates, and undo data needed by both screens, so the repository can remain the single source of persisted shopping state.
- The current purchase list destination still exposes add behavior from section blocks; that behavior conflicts with the corrected spec and should be removed in favor of the dedicated item-add destination.
- The current item-add destination already owns draft state, week context, and the bottom add action path, which makes it the best place to expand the day/week registration flow.

## Phase 1: Design and Data Shape

### UI Design

- Keep `MainShell` as the shared app frame with stable destinations.
- Redesign the purchase list destination so it shows only the category-grouped weekly list, swipe-to-complete behavior, and undo feedback.
- Redesign the item add destination so it owns the week/day registration flow and the item entry form.
- Keep the existing form controls for item name, quantity, candidate selection, and meal-slot sectioning where they are still required by the current data model.
- Remove weekly header and per-section add triggers from the purchase list destination so the purchase view stays read-only for creation.

### State Design

- Keep the selected destination in a provider so the shell remains stable during rebuilds.
- Keep the selected week context in shared session state so both destinations read the same shopping week.
- Keep draft item entry state separate from persisted shopping records so in-progress add input survives short navigation changes without affecting storage.
- Keep the latest purchase action and undo trigger in repository-backed weekly snapshot state.

### Data Design

- Reuse the existing weekly shopping repository and database schema for persisted shopping data.
- Keep purchase completion, undo, category ordering, and candidate reuse in the existing repository layer.
- Do not move navigation or draft item state into the database; those are session concerns.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests for destination switching, purchase list read-only behavior, and add-screen entry path
- Repository tests for weekly data loading, purchase completion, and undo behavior

## Risks and Mitigations

- Risk: Purchase list and item registration responsibilities could still overlap if section-level add controls remain visible. Mitigation: remove all item-creation affordances from the purchase list destination.
- Risk: The current item entry form is section-oriented and can hide the corrected flow if it stays tied too closely to the list layout. Mitigation: keep the form reusable, but anchor it under the item-add destination instead of the purchase list.
- Risk: Shared week context could be lost if destination state and week state are coupled. Mitigation: keep them as separate providers.
- Risk: Undo behavior could become ambiguous if it is surfaced in multiple places. Mitigation: keep purchase undo primarily in the purchase list destination.

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- New external API contracts
- Reworking the persisted weekly shopping schema beyond what is needed for the corrected screen flow
