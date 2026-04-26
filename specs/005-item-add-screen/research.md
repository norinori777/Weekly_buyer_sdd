# Research: 商品登録画面

## Decision 1: Keep the Existing Item-Add Destination

The app already has a dedicated `ItemAddDestination`, so the feature should extend that screen instead of introducing another add route. That keeps the shell behavior stable and avoids duplicating the shared week context.

## Decision 2: Add Swipe Navigation to the Weekday Selector

The weekday selector should support both tap selection and left/right swipe navigation. Tap remains the explicit selection mechanism, while swipe provides the requested rapid day switching across the current week.

## Decision 3: Move Item Entry Into a Bottom Sheet

The existing `ItemEntryForm` can be reused as the content of a modal bottom sheet. That keeps the entry controls consistent while matching the requested slide-up interaction.

## Decision 4: Keep Section Placement in the Repository Flow

Morning, afternoon, and evening should remain the display sections on the add screen, and the repository should still own where new items are persisted for the selected weekday and section.

## Decision 5: Keep Draft State in Session Providers

The selected weekday, the selected section, and the in-progress form values should stay in session state rather than in the database. That prevents partially entered values from mutating persisted shopping records.
