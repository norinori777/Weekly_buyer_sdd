# Research: 曜日別商品登録

## Decision 1: Add Weekday Scope to Stored Items

The existing weekly item record already carries the outer week scope and the section scope, but it does not distinguish Monday from Tuesday. The feature therefore needs a weekday association on each saved item so the same week can contain separate registrations for each weekday.

## Decision 2: Keep the Shared Week Context

The app should continue to use one active week across destinations. The bug is not about week selection; it is about the lack of weekday separation inside that week.

## Decision 3: Filter the Add Screen by Selected Weekday

The add screen should read only the items associated with the currently selected weekday. That ensures switching from Monday to Tuesday no longer surfaces Monday items.

## Decision 4: Preserve the Bottom-Sheet Add Flow

The current bottom-sheet entry path already provides a stable place to capture item name, quantity, and section. The only change needed is to attach the active weekday when saving.

## Decision 5: Keep Weekday Selection State in Session

Tap and swipe behavior on the weekday selector should continue to update the same session state. That prevents the selected weekday from drifting while the user switches between views.