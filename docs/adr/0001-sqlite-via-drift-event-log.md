# 0001. SQLite via Drift with event log and sync-ready columns

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

The app is local-first with relational needs: Person ↔ Commitment joins, derived-urgency grouping and sorting, and person views. It must survive years of schema evolution, back up as a single file, and keep a plausible path to future cloud sync without building sync now. Isar was rejected (uncertain maintenance, v4 in limbo); Hive/ObjectBox rejected (weak relational querying, weak migrations).

## Decision

Use **Drift over SQLite** as the only persistence layer. From day one:

- an **event-log table** records created / followed-up / done events, powering history and giving the "Followed up" action meaning;
- every mutable row carries `updatedAt` and `deletedAt` (soft delete) so a future sync engine has the metadata it needs.

## Consequences

- More boilerplate and a codegen step compared to NoSQL options — accepted for query power and migration discipline.
- Schema changes must go through versioned Drift migrations from the first release.
- Sync-ready columns are cheap insurance, not a commitment to build sync.
- Backup = copy one database file; aligns with the manual JSON export (ADR-0004).
