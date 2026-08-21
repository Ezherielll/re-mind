# 0009. Feature-first light layering, no heavy Clean Architecture

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

A solo developer must ship fast; full Clean Architecture (use cases, interactors, DTO mappers per layer) is ceremony without payoff at this codebase size — but some testable seams are non-negotiable because derived-status logic and scheduling are the product's brain.

## Decision

Light feature-first layout:

```
lib/
├── features/
│   ├── loops/        # home list, detail, history
│   ├── people/
│   ├── capture/
│   └── settings/
└── core/
    ├── db/           # Drift schema, DAOs, migrations
    ├── notifications/
    └── ...
```

Call chain: **UI → Riverpod controllers → repositories → Drift DAOs**. No use-case layer.

Testing posture: derived-status derivation is a pure function with full unit coverage; repository tests run Drift against an in-memory database; the capture flow gets a widget test; one happy-path integration test guards the core loop.

## Consequences

- Fast iteration with just enough architecture.
- Feature folders need discipline to avoid cross-feature imports (enforced by review/lints as the codebase grows).
- Refactoring cost stays low while the app is small; layering can deepen later if needed.
