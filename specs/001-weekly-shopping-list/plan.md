# Implementation Plan: Weekly Shopping List

**Feature Branch**: `001-weekly-buyer-specify`  
**Spec**: [spec.md](spec.md)  
**Status**: Draft  
**Target**: Flutter + Material 3 / Riverpod / Drift

## Plan Summary

Build the app as a small set of layered features: UI, state management, and local persistence. The first milestone is a weekly shopping flow that can show a week, add items through a bottom sheet, and keep purchased items stable through local storage. The add-item experience follows the provided screen image: a weekday switcher at the top, morning/afternoon/evening sections in the middle, and a bottom add action area. A day-independent "Other" list is treated as a separate section for items that do not belong to morning, afternoon, or evening.

## Product Shape

### Core Screen Model

- `DailyScreen`: main shopping entry screen for a selected week and day.
- `WeekHeader`: shows the current week label and weekday chips.
- `MealSectionList`: renders morning / afternoon / evening sections plus the `Other` list.
- `ItemRow`: renders item name, quantity, and purchase state.
- Bottom add action: opens a modal sheet for item entry or candidate selection.

### Add Screen Layout Requirement

The item add experience must match this structure:

- Top: weekday switcher with the current date and week context.
- Middle: separate sections for morning, afternoon, evening.
- Middle: separate `Other` section for day-independent items.
- Bottom: add operation area for adding items, choosing candidates, or registering a new item.

Implementation should prefer `ListView` and small widgets over heavy cards so that the screen can be composed and maintained easily.

## Architecture

### Presentation Layer

- Flutter Material 3 theme and app shell.
- Screen-level widgets for weekly list browsing and item entry.
- Section widgets for morning, afternoon, evening, and `Other`.

### State Layer

- Riverpod providers for selected week, selected day, active section, and add-sheet state.
- Notifiers for weekly list editing, candidate lookup, purchase toggles, and undo state.
- UI should not talk directly to Drift tables.

### Data Layer

- Drift database for categories, item master, weekly list, weekly list items, and recipe groups.
- Repository layer to hide SQL details from the UI and providers.
- Local-only storage for the first release.

## Data and Domain Decisions

- One weekly list is identified by the Monday-start week boundary.
- Items may belong to a day section or to the day-independent `Other` list.
- Purchased items should be hidden from the active shopping view until restored.
- Item master entries are reusable candidates and must be preserved once created.
- Category order must remain user-controlled.

## Milestones

### 1. App Shell and Navigation

- Set up the root `ProviderScope` and app theme.
- Replace the template counter screen with the weekly shopping shell.
- Add the main screen split into header, sections, and bottom action.

### 2. Local Database Foundation

- Create Drift tables and database wiring.
- Add repositories for weekly lists, items, categories, and reusable candidates.
- Implement initial seed behavior only if needed for empty-state testing.

### 3. Weekly Add Screen

- Build the `WeekHeader` with weekday chips.
- Build the morning / afternoon / evening sections.
- Add the `Other` section as a day-independent list.
- Add the bottom sheet for item creation and candidate selection.

### 4. Shopping Flow

- Add purchase toggle behavior and active-list hiding.
- Add undo for the most recent purchased item.
- Keep the view stable when switching weeks or sections.

### 5. Candidate Reuse and Item Master

- Search the reusable item catalog before creating a new item.
- Register a new item as reusable when it is not known.
- Reuse the same candidate in later additions.

### 6. Category Management

- Add category ordering controls in settings.
- Keep category sorting consistent in the shopping screen.

### 7. Verification

- Add widget tests for the add screen layout and section rendering.
- Add repository/database tests for week lookup, item creation, purchase state, and undo.
- Run analyze, format, and test checks before merging.

## Risks and Open Points

- The `Other` list must remain visually distinct from morning/afternoon/evening sections while still using the same add flow.
- Undo semantics must stay limited to the most recent purchase action so the shopping flow does not become confusing.
- The weekly keying strategy must stay aligned with the Monday-start clarification to avoid duplicate weeks.

## Validation Strategy

- `flutter pub get`
- `flutter analyze`
- `flutter test`
- Database and repository tests for weekly list behavior
- Widget tests for `WeekHeader`, section rendering, and the add sheet entry point

## Out of Scope for This Plan

- Cloud sync
- Shared editing
- Complex meal planning
- Widget integration
