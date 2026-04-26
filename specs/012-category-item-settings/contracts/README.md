# Contracts

This feature is internal to the Flutter app and does not expose an external API.

## Internal contracts to preserve
- `WeeklyShoppingRepository.deleteCategory(int categoryId)` blocks deletion when the category still has items.
- `WeeklyShoppingRepository.deleteItem(int itemId)` blocks deletion when the item exists in the current purchase week.
- Settings screens omit color, description, and quantity input fields.
