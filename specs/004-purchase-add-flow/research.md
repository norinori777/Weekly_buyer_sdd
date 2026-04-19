# Research: 購入・登録フロー

## Decision 1: Preserve the Existing Main Shell

Keep the current `MainShell` as the top-level frame. The app already has a shared shell, destination state, and persistent navigation control, so the best implementation path is to correct the destination responsibilities instead of replacing the navigation architecture.

## Decision 2: Make Purchase List Read-Only for Creation

The purchase list destination should show only the category-grouped weekly shopping list, left-swipe purchase completion, and undo feedback. It should not expose item creation controls or weekly/date headers. That keeps the shopping flow focused and matches the corrected spec.

## Decision 3: Make Item Add the Primary Entry Point for Creation

The item add destination should own the add flow that is opened from the bottom add action. The current section-based entry form can still be reused, but it should live under the item-add destination instead of being triggered directly from the purchase list.

## Decision 4: Keep Week Context in Shared Session State

The selected week should remain in a shared provider so both destinations load the same weekly snapshot. That prevents the purchase list and item add screens from drifting apart during navigation.

## Decision 5: Keep Persisted Shopping Data in the Repository

Weekly lists, shopping items, categories, item candidates, and undo state already live in the repository and database. Navigation state and draft add state should remain outside the database so screen switching does not mutate persisted shopping records.
