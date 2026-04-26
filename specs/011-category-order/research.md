# Research: Category Order Settings

## Decision 1: Use the existing `sort_order` column as the single source of truth

The current schema already stores `Category.sort_order`, and the repository loads categories in ascending `sort_order` order. Reusing that column avoids schema changes and keeps the purchase list and the settings screen aligned.

## Decision 2: Keep reorder edits local until the user saves

The settings screen should maintain an in-memory working copy so users can drag, reset, cancel, and review the order before persisting it. This makes the interaction predictable and avoids partial saves.

## Decision 3: Persist order changes in one transaction

Saving the reordered categories should update all affected rows together, so the list cannot end up in a half-updated state. A single transaction also makes rollback behavior simpler if the save fails.

## Decision 4: Reload the purchase-list data after saving

The purchase list screen already derives its display order from the repository load path. Invalidating and reloading the affected providers after save is sufficient to reflect the new order across screens.

## Decision 5: Make reset restore the default ascending order

Because the default order is already represented by ascending `sort_order`, reset can rebuild the working copy from the repository and then save that order if the user confirms.

## Alternatives Considered

- Adding a new ordering table: unnecessary because `sort_order` already exists.
- Saving each drag move immediately: rejected because it increases the risk of accidental changes and makes cancel behavior harder to support.
- Separating purchase-list order from category order: rejected because the screen specifically controls the purchase-list category display order.