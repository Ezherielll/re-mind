# Page: Home (Open Loops)

Overrides `../MASTER.md` where more specific.

## User goal

Answer "what's hanging right now?" in one glance, and make the single most urgent loop impossible to miss.

## Structure (top → bottom)

1. **Header** — in-content large title "Open loops" 28/w700 tracking -0.02em with live count badge ("7") in muted pill; search icon button (48dp) trailing → Search page. No drawer, no tabs.
2. **Filter chips** — sticky under header: `All · I owe · Waiting for`, single-select, selected = filled teal; each chip ≥44dp.
3. **Grouped list** — groups in fixed derived-status precedence (never user-sortable):
   1. **Follow-up due** — accent orange dot + label
   2. **Due** — destructive red dot + label
   3. **Upcoming** — secondary teal dot
   4. **On track** — muted gray-teal dot

   Group headers: 14/w600 uppercase, letter-spacing 0.05em, count suffix ("FOLLOW-UP DUE · 2"). Empty groups are omitted entirely.
4. **Rows** — min height 72dp:
   - Leading: **direction icon** (Material Symbols outlined): `north_east` = I owe, `south_west` = Waiting for, tinted by status color mapping below.
   - Title: one line, ellipsis, 16/w500.
   - Meta line: person chip (tap-through) · relative date ("due Fri", "reminds in 2d").
   - Trailing: status dot 10dp, color per mapping.
   - Row tap → Loop detail. Person chip tap → Person view only.
5. **Capture FAB** — extended FAB, accent orange `#EA580C` on white text, icon `add`, label "Capture"; bottom-right above safe area + gesture-bar inset.

## Status color mapping (shared vocabulary for all pages)

| Derived status | Light | Dark |
|---|---|---|
| Follow-up due | `#EA580C` | `#FB923C` |
| Due | `#DC2626` | `#F87171` |
| Upcoming | `#14B8A6` | `#2DD4BF` |
| On track | muted `#64748B`-teal | `#94A3B8` |

## States

- **Empty (no loops)**: centered — big "0" display numeral (display type allowed here, not in rows), body "Nothing hanging right now.", ghost button "Capture your first loop".
- **Sample mode** (first run, ticket T09): three sample rows carry a "Sample" tag chip; banner above list "These are examples — remove them" with one-tap clear-all.
- No loading spinner: local DB renders instantly; never show a blocking loader.

## Motion

- List group changes: AnimatedSwitcher 200ms fade+8dp slide.
- Chip selection: 150ms.
- Respect reduced-motion (`MediaQuery.disableAnimations`) — drop slides, keep fades.

## Do / Don't

- ✅ One screen answers everything; zero configuration visible.
- ❌ No bottom navigation bar (≤2 real destinations in v1).
- ❌ Never hero-scale typography inside rows (MASTER adaptation).
- ❌ Don't rely on color alone for status — icon shape + label always present (a11y).
