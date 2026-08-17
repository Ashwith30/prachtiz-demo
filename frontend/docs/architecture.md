# Architecture Guidelines

This application uses a modular, feature-first Clean Architecture Lite structure.

## Directory Structure

Every vertical feature under `lib/features/` should be structured as follows:

```text
lib/features/[feature_name]/
├── constants/             # Feature-specific labels, keys, and assets
├── presentation/          # Views, pages, and sub-components
│   ├── pages/             # Whole page widgets loaded by the router
│   └── widgets/           # Sub-widgets only used inside this feature
├── domain/                # Data shapes and repository contracts
│   ├── models/            # Feature-specific entities/data classes
│   └── repositories/      # Abstract definitions of data handlers
└── data/                  # Implementations and data retrieval
    ├── dummy/             # In-memory mock data loaders
    └── repositories/      # Concrete repository implementations
```

## Rules for Dependencies

1. **Features should not import code from other features' presentation folders.**
2. If a model or utility is needed by **3 or more features**, it must be promoted to the `lib/core/` or `lib/shared/` directory.
3. Keep feature scopes focused. Avoid nesting sub-features deeply; prefer flat, independent folders under `lib/features/`.
