# Page: Person View

Overrides `../MASTER.md` where more specific.

## User goal

Before contacting someone, scan everything hanging between us — and what we've already closed.

## Structure (top → bottom)

1. **Header** — back button; avatar-initials circle 56dp (teal fill, white initials 20/w600); name 20/w600; subtitle "3 open · 12 closed" 14/w400 muted.
2. **Open loops** — same row component and derived-status grouping as Home (reuse; do not fork the row widget). Group headers identical.
3. **Archived** — collapsed section header "Archived · 12" with expand/collapse chevron (48dp hit area); expanded shows same rows, dimmed 40%, status dot replaced by check icon.
4. No FAB here — capture stays on Home (single entry point).

## States

- Person with zero open loops: encouraging line "Nothing pending with Dana." + archived section (if any).
- Person-less commitments never surface here (CONTEXT.md rule).

## Interaction

- Row tap → Loop detail (same as home).
- Section collapse state is ephemeral (not persisted).

## Do / Don't

- ✅ Reuse Home's row/group widgets — one visual language for "a loop".
- ❌ No call/SMS/email action buttons in v1 (out of scope, spec).
- ❌ Don't show a mixed undifferentiated list — open vs archived separation is the page's point.
