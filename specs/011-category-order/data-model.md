# Data Model: Category Order Settings

## Purpose

This feature changes the order in which categories are displayed on the purchase list screen. It does not introduce new persisted entities; it reuses the existing category ordering data.

## Core Entities

### Category

Category displayed in the purchase list and the category-order settings screen.

- `id`: Identifier
- `name`: Category name
- `sortOrder`: Display order used by the purchase list
- `isActive`: Whether the category is active

### CategoryOrderDraft

In-memory working order while the user edits the list.

- `items`: Ordered list of categories being edited
- `isDirty`: Whether the working order differs from the persisted order
- `isSaving`: Whether a save operation is in progress

### CategoryOrderUpdate

Persisted update payload for one category.

- `categoryId`: Category identifier
- `sortOrder`: New display order value

## Relationships

- `CategoryOrderDraft.items` is derived from the repository category list.
- `CategoryOrderUpdate` is generated from the final order of `CategoryOrderDraft.items`.
- `PurchaseListDisplayOrder` is derived from the persisted ascending `sortOrder` of `Category`.

## State Transitions

### Load Settings Screen

1. The screen reads categories ordered by `sortOrder` ascending.
2. The ordered list becomes the editable draft.

### Reorder

1. The user drags a category to a new position.
2. The draft list order updates immediately.
3. The persisted `Category.sortOrder` remains unchanged until save.

### Save

1. The draft list is converted into sequential `CategoryOrderUpdate` entries.
2. All updates are written in one transaction.
3. Purchase list providers reload the updated order.

### Reset

1. The draft list is rebuilt from the repository's ascending order.
2. If saved, the reset order becomes the persisted order.

### Cancel

1. The draft changes are discarded.
2. The screen closes without updating the database.

## Notes

- No new table or migration is required.
- `sortOrder` values should remain consistent and preferably contiguous after save.