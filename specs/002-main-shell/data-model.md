# Data Model: Main Shell

## Purpose

This feature does not introduce new persisted business entities. It changes how the existing weekly shopping data is navigated and presented.

## Existing Persisted Data

- Weekly shopping list
- Shopping items
- Item master / reusable candidates
- Category ordering
- Undo-related shopping state handled by the repository flow

## New Session State

### MainShell State

- Selected destination: purchase list, item add, or settings
- Selected week context
- Draft add state for in-progress item entry
- Last active shopping destination for returning from settings

## Relationships

- The selected week context is shared by all destinations in the shell.
- Draft add state is tied to the active session, not persisted shopping records.
- Category and item data remain owned by the existing weekly shopping repository.

## Notes

Navigation state should remain separate from shopping records so that switching destinations does not mutate persisted list data.
