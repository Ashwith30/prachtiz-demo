# Naming Standards

To ensure a highly maintainable codebase, we strictly enforce naming rules for files, directories, classes, and variables.

## 1. Class and Widget Naming

- **Shared Widgets:** All globally reusable components inside `shared/widgets/` must be prefixed with `App` (e.g. `AppButton`, `AppCard`, `AppTextField`).
- **Feature-Specific Widgets:** Feature sub-elements must be prefixed with the feature name (e.g. `DashboardCalendarCard`, `PatientRow`).
- **View/Pages:** The top-level feature page loaded by routing should end in `Screen` (e.g. `DashboardScreen`, `PatientDetailsScreen`).

## 2. File and Directory Naming

- All folders and files must be in lowercase `snake_case` (e.g. `app_colors.dart`, `dashboard_screen.dart`).
- Files containing classes must match the class name in snake_case (e.g. `class AppButton` inside `app_button.dart`).

## 3. Route Naming

- Navigation paths use hierarchical lower-case paths:
  - Dashboard: `/`
  - Patients: `/patients`
  - Patient detail: `/patients/:id`
  - Invoices: `/invoices`
