# Page: Loop Detail

Overrides `../MASTER.md` where more specific.

## User goal

See everything about one commitment, act on it (Followed up / Snooze / Done), and adjust dates without friction.

## Structure (top → bottom)

1. **App bar** — back button (48dp). No title duplication; the commitment title is the page header below.
2. **Header block** — direction icon + title 20/w600 (read-only in v1); derived-status pill under it using shared status color mapping (home.md).
3. **Meta card** (surface card, radius 12, 24dp padding):
   - **Due** row — calendar icon, "Due Friday, Aug 28" / "No due date"; tap → date picker (clear option included).
   - **Reminds** row — bell icon, computed next nudge text; tap → picker + quick chips (reuse capture chip set).
   - **Person** row — avatar-initials circle 32dp + name; tap → Person view. Hidden if person-less.
   - Rows ≥56dp, chevron trailing, whole-row tap targets.
4. **Notes** — section label "NOTES" (14/w600 uppercase muted), multiline field, autosave on 500ms debounce; helper "Saved" micro-text flashes on write.
5. **History timeline** — section label "HISTORY"; vertical list: event icon in 32dp tinted circle (`add_circle`=created, `send`=followed up, `check_circle`=done), event label + relative timestamp, connected by 2dp line. Newest first.

## Actions (bottom action bar)

Fixed above safe-area inset, three buttons:

| Action | Style | Result |
|---|---|---|
| **Followed up** | Filled tonal teal, ≥52dp | Logs event, advances reminder per cycle, snackbar "Reminder moved to …" |
| **Snooze** | Outlined | Quick sheet: 1d / 3d / custom |
| **Done** | Filled teal (primary) | Auto-archives: pops back to home, snackbar "Archived — Undo" (5s) |

- Buttons equal width, 12dp gaps, never stacked behind scroll (bar pinned).

## States

- Archived loop reopened from history/person view → actions bar replaced by single "Reopen" outlined button (un-archives as open with previous dates).
- Notes autosave failure (disk) → inline error text under notes; retry on next keystroke.

## Do / Don't

- ✅ All state-changing actions visible without scrolling when content is short.
- ❌ No destructive delete UI in v1 (soft-delete is internal only).
- ❌ Don't put status pill inside the app bar; it belongs next to the title it describes.
