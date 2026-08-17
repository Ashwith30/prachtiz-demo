# Design System Guidelines

This document details the visual tokens and design rules for the PraCHtiz practice management interface.

## 1. Colors

Our visual style focuses on a premium clinical aesthetic using a balanced combination of deep blues, forest greens, status alerts, and glassmorphism.

- **Primary Blue (`primary`):** `#273A91` - Primary brand and layout element color.
- **Secondary Dark (`secondary`):** `#1A2761` - Dark overlays, cards, header components.
- **Accent Green (`success`):** `#007A1F` - Active clinical statuses, positive metrics.
- **Accent Red (`danger`):** `#EF4444` - Warnings, cancellations, critical vital bounds.
- **Accent Orange (`warning`):** `#F59E0B` - Pending, waiting status, attention.
- **Background (`background`):** `#F4F7FB` - Soft gray-blue background.

## 2. Spacing

Always use spacing constants mapped to the `AppSpacing` tokens:

| Token | Size | Code Usage |
|---|---|---|
| `xs` | 4.0 | `AppSpacing.xs` |
| `sm` | 8.0 | `AppSpacing.sm` |
| `md` | 16.0 | `AppSpacing.md` |
| `lg` | 24.0 | `AppSpacing.lg` |
| `xl` | 32.0 | `AppSpacing.xl` |
| `xxl` | 48.0 | `AppSpacing.xxl` |

*Never hardcode sizes via `SizedBox(width: 15)` or custom paddings. Always use spacing steps.*

## 3. Typography

Fonts are driven by the Google Fonts package:
- **Headings & Primary Titles:** Poppins (Regular, Medium, Bold)
- **Body & Captions:** Inter (Regular, Medium, Semi-Bold)
- Font styles must be loaded via `AppTypography` text theme, not configured in-line.
