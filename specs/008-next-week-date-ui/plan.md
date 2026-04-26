# Implementation Plan: 翌週日付表示と曜日ボタン簡略化

**Branch**: `008-next-week-date-ui`  | **Date**: 2026-04-20 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/008-next-week-date-ui/spec.md`

## Summary

This feature aligns the product registration screen with the app’s core intent: planning the next week’s shopping. The active week context shown on the screen should be the next calendar week (Monday start, Sunday end), and the weekday selector at the top should display weekday-only labels (e.g., "月", "火" …) without embedding numeric dates.

The current app already uses a shared “selected date” to drive the loaded week range and weekday-scoped item sections. The safest approach is to:

- Update the default selected date to point to a date in next week so the loaded `WeekRange` becomes next week.
- Simplify the weekday button labels rendered by the header so they show only weekday text.

No database schema changes are required.

## Technical Context

**Language/Version**: Dart 3.11 / Flutter stable  
**Primary Dependencies**: Flutter Material 3, flutter_riverpod, drift, drift_flutter, riverpod_generator, build_runner  
**Storage**: Local SQLite via Drift  
**Testing**: flutter test, flutter analyze, widget tests, repository tests  
**Target Platform**: Android and other Flutter-supported targets in the existing mobile app workspace  
**Project Type**: Mobile app  
**Performance Goals**: Weekday switching and initial load should remain immediate; no noticeable latency introduced by next-week computation  
**Constraints**: Offline-capable, local-first data flow, shared week context across destinations, week definition is Monday–Sunday  
**Scale/Scope**: Single mobile app with one shared weekly shopping domain and a small set of destination-level screens

## Constitution Check

No project constitution file is present in `.specify/`, so there are no additional constitution gates to enforce in this workspace snapshot.

## Project Structure

### Documentation (this feature)

```text
specs/008-next-week-date-ui/
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
    ├── widget_test.dart
    └── repository_test.dart
```

**Structure Decision**: Keep the existing shared week/date provider as the single source of truth. Implement the next-week default at the provider boundary and simplify the weekday button labels inside the existing header widget.

## Phase 0: Research

### Decisions to Confirm

- Keep the existing shared selected-date provider as the source of truth for week context (avoid introducing a separate “item-add-only” week state).
- Define “next week” as the next calendar week based on the existing Monday–Sunday week definition.
- Simplify the weekday selector labels to weekday-only, while keeping the week-range label (header text) as-is.
- Ensure swipe/tap weekday selection behavior remains unchanged; only the label text changes.

### Research Outcomes

- `WeekHeader` currently formats weekday buttons with a combined label like "水 4/23"; this can be simplified to weekday-only without changing the interaction model.
- The week shown on the screen is derived from a reference date passed into the snapshot loader; adjusting the default reference date to next week shifts the whole view consistently.
- Existing week helpers (`startOfWeek`, `endOfWeek`, `formatWeekLabel`, `dateOnly`) already encode the Monday-start rule; next-week behavior can build on these.

## Phase 1: Design and Data Shape

### UI Design

- Week range label remains visible at the top of the header.
- Weekday selector buttons display only weekday text ("月".."日") with no numeric month/day.
- Selected state styling and wrap layout remain unchanged.
- Swipe gestures (left/right) continue to change the selected day inside the active week.

### State Design

- Default selected date should resolve to a date that falls within the next calendar week.
- Week range and per-weekday registration views derive from the selected date and remain consistent.
- Weekday-to-date mapping stays derived from the `WeekRange.start` + offset; the UI does not carry a separate mapping.

### Data Design

- No persisted schema changes.
- No changes to item identity or weekday association.
- Week context changes are presentation/state defaults only.

## Validation Strategy

- `flutter analyze`
- `flutter test`
- Widget tests:
  - Weekday selector chips show weekday-only labels (no digits, no “/”).
  - Initial screen load corresponds to next calendar week (week label reflects next week’s range).
- Optional unit tests for date helpers (if a new helper is introduced for “next-week reference date”).

## Risks and Mitigations

- Risk: “next week” definition ambiguity (e.g., next 7 days vs next calendar week). Mitigation: explicitly use Monday–Sunday next calendar week consistent with existing project decision.
- Risk: Timezone/DST boundary affects date-only computation. Mitigation: normalize with existing `dateOnly` helper and validate around month/year boundaries.
- Risk: Shared week default affects other destinations (purchase list). Mitigation: treat the app as next-week planning and keep a single shared context; if later requirements demand different defaults per screen, revisit in a separate feature.

## Out of Scope for This Plan

- Adding a week picker UI
- Showing numeric dates inside weekday buttons
- Introducing multi-week browsing/history
- Cloud sync or cross-device reconciliation
