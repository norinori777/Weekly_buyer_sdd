# Research: 商品追加画面の削除機能

## Decision 1: Attach Delete to the Existing Add-Screen Rows

The item-add screen already shows the current weekday's registered items, so the delete affordance should live on those same rows instead of introducing a separate management screen.

## Decision 2: Delete by Item Row Id

The delete action should target the persisted shopping item row id. That avoids ambiguity when the same item name appears more than once in the same weekday or across different weekdays.

## Decision 3: Keep the Item Catalog Untouched

The user request is to delete the added item from the screen, not to remove the reusable catalog entry. The repository should therefore delete the weekly shopping row only and leave item masters intact.

## Decision 4: Refresh the Active Weekday Snapshot After Delete

After deletion, the screen should reload the active weekday data so the removed row disappears immediately and the empty state appears when needed.

## Decision 5: Use a Recognizable Close/Remove Icon

The right-edge control should look like a deliberate removal action rather than a generic navigation affordance. A small destructive close icon treatment is a good fit for a compact item row.
