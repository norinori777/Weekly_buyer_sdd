# Implementation Plan: 曜日別商品登録

**Branch**: `006-weekday-item-registration`  | **Date**: 2026-04-19 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/006-weekday-item-registration/spec.md`

## Summary

This feature fixes the item-add flow so registrations are partitioned by weekday inside the active week. Today, item registration data is shared across the week, which causes Monday entries to appear when Tuesday is selected. The implementation must introduce weekday-specific persistence and weekday-specific filtering while keeping the existing shared week context, bottom-sheet add flow, and weekday selector behavior intact.

The current app already has a shared shell, a dedicated item-add destination, a reusable weekday header, and a reusable item entry form. The safest change is to extend the existing weekly shopping domain and repository so each saved item carries an explicit weekday association, then update the add screen to read and write against that weekday.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Week switching should feel immediate, and the selected weekday view should never show items from another weekday  
**Constraints**: Offline-capable, local-first data flow, no cloud sync for the first version, shared week context across destinations, weekday selection must remain stable during navigation  
**Scale/Scope**: Single mobile app with one shared weekly shopping domain and a small set of destination-level screens

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/006-weekday-item-registration/
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

**Structure Decision**: Keep the current feature-first Flutter layout and add weekday awareness to the weekly shopping data model. The implementation work should remain inside the existing weekly shopping feature, with the main changes centered on database schema, repository filtering, and the item-add destination's selected weekday handling.

## Phase 0: Research

### Decisions to Confirm

- Keep `MainShell` as the outer frame so the item-add destination continues to share the active week with the purchase list.
- Add an explicit weekday association to stored shopping items so each registration belongs to one weekday inside the week.
- Filter the add screen by the selected weekday so it only shows that weekday's registrations.
- Preserve the current bottom-sheet item entry flow and existing weekday selector behavior.
- Keep the selected weekday in shared session state so tab selection and swipe gestures stay in sync.

### Research Outcomes

- The current repository stores weekly items with a week scope and section scope, but no weekday scope, which explains why Tuesday can still show Monday entries.
- `loadWeek()` currently reads all items for the week and groups them only by category and section, so it must be updated to partition items by weekday.
- The current item-add destination already reads shared week state and draft state, which makes it the best place to synchronize the selected weekday with the save path.
- The existing `WeeklyListItems` table is the persistence boundary that needs a migration-safe extension for weekday-specific registration.

## Phase 1: Design and Data Shape

### UI Design

- Keep the item-add screen as a single destination with a weekday selector, weekday-scoped registration sections, and a bottom add action.
- Continue to let users switch weekdays by tapping or swiping the selector.
- Ensure the screen only renders the currently selected weekday's items.
- Keep the bottom-sheet add form and the item entry controls unchanged from the user's perspective.
- Keep the selected weekday visible and stable while the user adds multiple items.

### State Design

- Keep the selected week in a provider shared with the purchase list screen.
- Keep the selected weekday as session state so tap and swipe gestures stay in sync.
- Keep the current draft item entry state separate from persisted data so the form can survive brief navigation and sheet reopen behavior.
- Keep the selected weekday in the add path so saved items are written back to the right weekday.

### Data Design

- Extend the weekly list item record with a weekday association inside the active week.
- Update repository reads so only the selected weekday's items are shown in the item-add view.
- Update repository writes so each new item is stored against the currently selected weekday.
- Keep the week range as the outer partition and the weekday as the inner partition.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests for weekday selection, weekday-specific rendering, and item creation on multiple weekdays
- Repository tests for persistence separation across weekdays within the same week

## Risks and Mitigations

- Risk: Existing data may not have a weekday value. Mitigation: add a migration/default so older rows map to a safe initial weekday and remain readable.
- Risk: Weekday selection could still drift from save targets if the screen and repository read different sources of truth. Mitigation: keep the selected weekday in shared session state and pass it into save and load paths consistently.
- Risk: Filtering only in the UI could hide the bug temporarily but leave the data incorrect. Mitigation: enforce weekday separation in the repository and persisted data model, not just the presentation layer.
- Risk: The bottom-sheet form could still submit without a weekday. Mitigation: derive the weekday from the active screen context when saving.

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- New external API contracts
- Reworking the shared week shell or purchase list flow beyond the weekday-aware item registration fix