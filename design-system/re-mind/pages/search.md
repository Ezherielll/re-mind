# Page: Search

Overrides `../MASTER.md` where more specific.

## User goal

Find one old loop or person in seconds, mid-conversation.

## Presentation

- Full-screen page (not overlay) opened from Home header search icon; field autofocused on entry, keyboard up.
- Field: rounded 12dp, magnifier icon, live clear ("x") button when non-empty.

## Behavior

- **Debounce 200ms**, case-insensitive substring match over commitment titles/notes and person names.
- Results grouped: `PEOPLE` first (max 5, avatar + name + open-count), then `LOOPS` (Home row component, max 50 with "Showing 50 — refine search" footer if truncated).
- Query terms highlighted **w600** within result text (same size/color — never color-only emphasis).
- Empty query → both sections hidden; hint line "Search commitments and people".
- No results → centered muted line `No matches for "<query>"`.
- Back/clear resets instantly; no recent-searches storage in v1 (privacy posture).

## Motion & a11y

- Result list swaps via AnimatedSwitcher fade 150ms.
- Announce result count to screen readers after debounce settles ("12 results").

## Do / Don't

- ✅ One input, zero filter controls in v1.
- ❌ No fuzzy/scoring complexity — substring is predictable and explainable.
- ❌ Don't navigate on query change; navigation happens only on row tap.
