# 0002. Riverpod for state management

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

UI must react to database changes automatically (open-loop list, person views), dependencies need simple injection, and a solo developer must be able to test logic without running the app. Bloc was rejected as too much ceremony for a single-list app; raw Provider/setState does not scale to notification scheduling plus repository layers.

## Decision

Use **Riverpod**. Drift watch streams are exposed through `StreamProvider`; repositories and services are wired via providers as the composition root. UI widgets never touch the database directly.

## Consequences

- Reactive screens fall out of Drift streams with minimal glue.
- Widget tests override providers via `ProviderContainer`.
- Moderate learning curve; mitigated by the largest community and docs of the current options.
