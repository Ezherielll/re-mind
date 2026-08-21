# CONTEXT.md

Re:Mind is a personal commitment and follow-up management system. It tracks **two-way open loops** between the user and other people — promises the user made and outcomes the user is waiting on — so nothing stays unresolved after a conversation ends. Beachhead user: freelancers and solo professionals working in a personal (non-team) context. Local-first; data never leaves the device unless the user exports it.

## Naming

- **Display/brand name:** Re:Mind (with colon) — UI, store listing, marketing.
- **Identifier form:** ReMind / `re_mind` (colon-free) — package name, application ID, code identifiers, URLs, anywhere special characters are invalid.

This file is the canonical vocabulary of the project. Use these terms in issues, tests, refactors, and UI copy. Don't drift to synonyms.

## Glossary

### Open loop

A commitment that has been captured but not yet closed. The central object of the product; the home screen is a single prioritized list of all open loops. Closing a loop (**Done**) **auto-archives** it: it disappears from the home list but remains visible in the person view and in history. First-launch sample loops are marked as samples and removable in one tap.

### Commitment

The core entity: one promise or expectation, optionally linked to one **Person** (lazily created from free text, offered via autocomplete afterwards; a commitment without a Person is allowed but excluded from person views). Stored state is deliberately minimal:

- `direction` — outgoing | incoming
- `status` — open | done
- `dueDate?` — when the commitment itself is due
- `followUpAt?` — when the app should nudge

Everything else shown in the UI (urgency label, grouping) is **derived**, never stored. Each commitment carries free-form notes and an automatic event history (created / followed up / done, with timestamps).

### Direction

Which way a commitment points. Set once at capture via the direction toggle; it drives default follow-up triggers and the All / I owe / Waiting for filter chips.

- **Outgoing ("I owe")** — the user promised to deliver or do something for someone.
- **Incoming ("Waiting for")** — the user is waiting on something from someone.

### Derived status

Display-only urgency labels computed at render time from the current date versus stored dates. Never persisted; implemented as a single pure function (unit-tested). Precedence, highest first:

1. **Follow-up due** — open and `followUpAt <= now`
2. **Due** — open and `dueDate <= today`
3. **Upcoming** — open with a future `dueDate`
4. **On track** — open with no relevant dates reached

The home list sorts by this precedence inside the selected direction filter.

### Follow-up trigger

The stored `followUpAt` timestamp that decides when the app nudges. Set at capture through quick chips (Tomorrow / In 3 days / On due date / Custom) or left to deterministic defaults by direction:

- Outgoing → the day before `dueDate`, and again on `dueDate`
- Incoming → 3 days after capture

Tapping **Followed up** logs the event and schedules the next nudge (the snooze cycle). Triggers are deterministic and explainable — no AI or adaptive heuristics in v1.

### Digest

The single daily check-in notification at a user-chosen time summarizing open-loop state ("3 things hanging: 1 to chase today"), plus per-item alerts only for items due that same day. Actionable from the notification shade: Done / Followed up / Snooze 1 day. The digest is the primary retention mechanism and is calm by design — no per-item notification spam.

## Related decisions

Architectural and business rationale lives in `docs/adr/` (ADR-0001 … ADR-0010).
