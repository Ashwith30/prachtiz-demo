# Shared Widget Library Specifications

Shared components represent the visual atoms of our design system. To maintain flexibility, they must adhere to these rules:

## Rules for Shared Widgets

1. **Keep widgets purely presentation-focused.** Shared widgets must not import state libraries, repositories, or read configs. They accept parameters and communicate events back via callbacks (e.g. `onPressed`, `onChanged`).
2. **Standard prefix:** Every shared widget starts with `App`.
3. **Responsive first:** Ensure components adjust their layouts based on constraints (e.g., table cells wrap or scroll, inputs size correctly on small layouts).

## Component Directory

Our base library includes:
- **`AppButton`**: Custom styling mapping to clinical themes, supporting multiple sizes and accent states.
- **`AppCard`**: Configurable border, shadows, color overlays, and glassmorphism.
- **`AppBadge`**: Color state badge (Success, Alert, Warning, Info).
- **`AppTextField`**: Input fields matching text standards with clear states.
- **`AppDropdown`**: Searchable/configurable dropdown overlay.
- **`AppDataTable`**: Highly readable grid table for listing clinical items.
