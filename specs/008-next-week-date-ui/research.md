# Research: 翌週日付表示と曜日ボタン簡略化

## Decision 1: Use a single shared next-week context

The app already shares a selected date across destinations to define the active week. Keeping a single shared definition avoids inconsistencies where one screen shows “next week” and another shows “this week”.

## Decision 2: Define next week as the next calendar week (Mon–Sun)

The project already fixed the week definition as Monday start and Sunday end. “Next week” should follow the same calendar week boundary rather than a rolling 7-day window.

## Decision 3: Update only the weekday button labels

The weekday selector is currently correct in interaction and selection behavior. The request is strictly about button content: remove embedded numeric dates and show weekday-only text.

## Decision 4: Shift week context by defaulting the reference date into next week

The screen’s week range is derived from a reference date via existing week helpers. Setting the default selected date into next week automatically moves the week label, weekday mapping, and loaded snapshot into the correct week.

## Decision 5: Avoid schema changes

The feature changes presentation and default state only. Persisted weekly list items remain keyed by the computed week start and weekday association.
