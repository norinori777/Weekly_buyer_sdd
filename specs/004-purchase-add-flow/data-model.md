# Data Model: 購入・登録フロー

## Purpose

This feature does not introduce a new persisted business entity set. It corrects how the existing weekly shopping data is presented and how add/navigation state is handled.

## Existing Persisted Data

- Weekly shopping list records
- Weekly shopping items
- Categories and category ordering
- Item master / reusable candidates
- Purchase and undo state stored by the repository flow

## New Session State

### Main Shell State

- Selected destination: purchase list, item add, or settings
- Previous shopping destination for returning from settings
- Shared selected week context

### Item Add State

- Current draft item name
- Quantity text
- Candidate selection
- Selected input section if the existing section-based form remains visible
- Current add screen tab or day context if the corrected item-registration view needs it as session state

## Presentation State

### Purchase List Snapshot

- Category list for grouping weekly items
- Visible weekly items after purchased items are hidden
- Hidden purchased count for undo/feedback display
- Last purchased item for undo feedback

### Item Add Snapshot

- Shared selected week
- Candidate list
- Current draft item input
- The active day or registration context shown in the add screen

## Relationships

- The shared week context feeds both the purchase list snapshot and the item add snapshot.
- Draft add state is transient session state and should not be written directly into the shopping database.
- The repository remains the single source of persisted shopping items, candidates, categories, and undo state.
- Navigation state should remain separate from shopping data so destination switching does not change the persisted weekly list.

## Notes

- If the current section-based form is retained, it should be treated as an input dimension within the add flow, not as the primary navigation model for the purchase list.
