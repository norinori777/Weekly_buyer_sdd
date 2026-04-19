# Implementation Plan: 商品追加画面の削除機能

**Branch**: `007-item-add-delete`  | **Date**: 2026-04-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/007-item-add-delete/spec.md`

## Summary

The feature adds an explicit delete action to the item list shown on the item-add screen. Each registered item should expose a recognizable delete affordance at the right edge of its row, and tapping it should remove only that one item from the currently selected weekday's registrations. The screen should refresh immediately after deletion and preserve the active weekday context.

The current app already has a shared week selector, a weekday-scoped add screen, and a repository that writes and reloads weekly items. The safest change is to extend the existing item-add presentation layer with a per-row delete action and to add a repository delete method that removes the selected weekly list item by id, then refreshes the active snapshot.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Deletion should feel immediate and the visible weekday list should update without noticeable delay  
**Constraints**: Offline-capable, local-first data flow, no cloud sync for the first version, delete must affect only the currently selected weekday's item list  
**Scale/Scope**: Single mobile app with one shared weekly shopping domain and a small set of destination-level screens

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/007-item-add-delete/
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

**Structure Decision**: Keep the current feature-first Flutter layout and make deletion a focused enhancement in the existing add-screen presentation and repository layers. The implementation work should not introduce a new route or new persisted entity; it should remove weekly list items by id and then refresh the current weekday snapshot.

## Phase 0: Research

### Decisions to Confirm

- Keep the item-add screen as the place where the delete action appears, alongside the items already listed for the selected weekday.
- Use a small delete icon at the right edge of each item row so the action reads as removal rather than navigation.
- Delete only the selected row from the active weekday's registrations, leaving the reusable item catalog unchanged.
- Refresh the same weekday snapshot after deletion so the visible list updates immediately.
- Preserve the current weekday selection when deletion happens.

### Research Outcomes

- `ItemAddDestination` already renders the weekday-scoped items, which makes it the correct place to attach per-row delete affordances.
- The repository already owns item insertion and snapshot loading, so adding a delete method there keeps write logic centralized.
- Deletion should operate on the persisted weekly list item id rather than on name or category, because duplicate item names can exist.
- The current bottom-sheet add flow and shared weekday provider do not need to change for this feature; the delete action can reuse the existing snapshot and refresh path.

## Phase 1: Design and Data Shape

### UI Design

- Keep the item-add screen as a single destination with the week header, weekday-scoped registration cards, and the bottom add action.
- Add a recognizable delete control on the right end of each registered item row.
- Use an icon treatment that clearly signals removal, such as a small close or cancel mark with a destructive color cue.
- Keep the empty state visible when the current weekday has no items after deletions.
- Preserve the current row spacing and item labels so the new action does not make the list harder to scan.

### State Design

- Keep the selected week in shared session state.
- Keep the selected weekday as the source of truth for which items are shown and deleted.
- Keep draft add state separate from deletion state so closing or deleting items does not disturb the in-progress add form.
- Trigger a snapshot refresh after deletion so the UI stays in sync with the repository.

### Data Design

- Reuse the existing weekly list item record as the deletion target.
- Add a repository delete method that removes one item by its persisted id.
- Keep the week range and weekday association unchanged; deletion only removes the selected row.
- Do not introduce a new persisted entity for deletion state.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests for visible delete controls, one-item deletion, and same-week weekday isolation
- Repository tests for deleting a selected item and preserving the remaining items

## Risks and Mitigations

- Risk: A text-only close mark could look like a dismiss action instead of deletion. Mitigation: use a recognizable icon and destructive visual treatment.
- Risk: Deleting by name could remove the wrong duplicate item. Mitigation: delete by row id only.
- Risk: The list could fail to refresh after delete and leave stale rows visible. Mitigation: invalidate the weekday snapshot immediately after repository deletion.
- Risk: Deleting an item on one weekday could appear to affect another weekday if refresh is done against the wrong date. Mitigation: keep the current selected date as the refresh key.

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- New external API contracts
- Reworking the weekday selector or add form layout beyond the delete affordance on item rows
