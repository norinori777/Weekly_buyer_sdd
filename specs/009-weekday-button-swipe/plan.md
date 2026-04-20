# Implementation Plan: 曜日ボタン簡略化とスワイプ切替

**Branch**: `009-weekday-button-swipe`  | **Date**: 2026-04-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/009-weekday-button-swipe/spec.md`

## Summary

This feature refines the weekday switching UX on the product registration screen:

- Weekday selector buttons show weekday-only labels (e.g., "月", "火" …) and remove any numeric date from the button text.
- Users can switch weekdays not only by tapping, but also by swiping left/right on the weekday selector area.

The app already has a reusable weekday header and uses a selected-date state to drive which weekday’s registrations are shown. The safest change is to keep the current state model and data loading intact, and only update:

- The weekday button label formatting in the header widget.
- The swipe interaction behavior (verify it exists and matches the spec’s edge-case constraints).

No database changes are required.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Weekday switching should feel immediate and not add noticeable jank  
**Constraints**: Offline-capable, local-first; keep the selected weekday within the week bounds; no new week-picking UI  
**Scale/Scope**: One Flutter app with a small set of destination-level screens

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/009-weekday-button-swipe/
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
│   │   └── providers.dart
│   └── features/
│       └── weekly_shopping_list/
│           ├── domain/
│           │   └── weekly_shopping_models.dart
│           └── presentation/
│               ├── item_add_destination.dart
│               └── week_header.dart
└── test/
    └── widget_test.dart
```

**Structure Decision**: Keep weekday selection driven by the shared selected-date provider. Implement label simplification and swipe handling in the existing `WeekHeader` widget so the change is localized to presentation.

## Phase 0: Research

### Decisions to Confirm

- Keep weekday tap selection behavior unchanged.
- Ensure swipe left/right changes the selected weekday by exactly one day.
- Confirm swipes at the first/last day do not move outside the current week.
- Remove numeric date display from weekday buttons while preserving a clear selected state.

### Research Outcomes

- The weekday selector is implemented in `WeekHeader`, which already owns the tap interactions and has a single place to format chip labels.
- Weekday-specific content is already driven by the selected date, so changing the selected date via swipe is sufficient to switch the registrations view.

## Phase 1: Design and Data Shape

### UI Design

- Keep the week-range label at the top of the header as-is.
- Weekday selector chips display weekday-only text ("月".."日").
- Selected chip styling remains unchanged.
- The selector area remains swipeable left/right.

### State Design

- Continue using a single selected-date state.
- Tap and swipe both update the same selected-date state.

### Data Design

- No persisted schema changes.
- No change to how weekly snapshots are loaded.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests:
  - Weekday chip labels contain no digits.
  - Swiping the header changes the selected chip to the adjacent weekday.
  - Swiping beyond week bounds does not move selection outside the current week.

## Risks and Mitigations

- Risk: Swipe sensitivity causes accidental weekday changes. Mitigation: keep a velocity/distance threshold and verify edge cases.
- Risk: Removing date from chips reduces clarity. Mitigation: keep the week-range label and the selected-state highlight.
- Risk: Gesture conflicts with scrollable content. Mitigation: keep the gesture surface limited to the header/selector area.

## Out of Scope for This Plan

- Adding a week picker UI
- Changing which week is active by default
- Showing month/day on weekday buttons
- Multi-week browsing/history
- Cloud sync
