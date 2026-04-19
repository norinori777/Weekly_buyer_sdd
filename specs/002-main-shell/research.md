# Research: Main Shell

## Decision 1: Navigation Model

Use a single MainShell with a persistent bottom navigation control for purchase list, item add, and settings. This matches the feature spec and keeps the user in one consistent frame while switching destinations.

## Decision 2: Week Context Sharing

Keep the currently selected week in shared session state so purchase list, item add, and settings all operate on the same week without jumping to a different context.

## Decision 3: Add Flow

Preserve the existing fast add path from the purchase list as a direct action, and make the item-add destination the fuller entry point for structured input. This avoids blocking the current quick-add behavior while still meeting the new shell requirement.

## Decision 4: Settings Placement

Treat settings as a first-class destination inside the same shell instead of opening it as a separate flow. That keeps back-and-forth navigation predictable and prevents the shopping context from resetting.

## Decision 5: State Ownership

Keep destination state and draft add state in providers rather than in the database. Persisted shopping data should remain in the repository and database layer, while navigation state stays in the UI/session layer.
